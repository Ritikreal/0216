from __future__ import annotations

import asyncio
import time

import numpy as np
import sounddevice as sd


class AudioCaptureError(RuntimeError):
    """A recoverable microphone-capture problem."""


def resolve_input_device(configured_name: str | None):
    """Resolve a PortAudio input by name; None uses the PipeWire default route."""
    if not configured_name:
        return None
    try:
        devices = sd.query_devices()
    except Exception as e:
        raise AudioCaptureError(f"Could not list audio devices: {e}") from e

    matches = [
        (index, device)
        for index, device in enumerate(devices)
        if int(device.get("max_input_channels", 0)) > 0
        and configured_name.casefold() in str(device.get("name", "")).casefold()
    ]
    if not matches:
        available = [
            str(device.get("name", "unknown"))
            for device in devices
            if int(device.get("max_input_channels", 0)) > 0
        ]
        raise AudioCaptureError(
            f"Configured audio route not found: {configured_name}. "
            f"Available inputs: {', '.join(available) or 'none'}"
        )
    return matches[0][0]


def rms_level(chunk: np.ndarray) -> float:
    """Return a stable RMS level for a floating-point audio block."""
    if chunk.size == 0:
        return 0.0
    return float(np.sqrt(np.mean(np.square(chunk, dtype=np.float64))))


def detection_threshold(noise_levels: list[float], configured: float,
                       multiplier: float) -> float:
    """Estimate quiet-room noise robustly without letting loud calibration outliers dominate."""
    # A median can be pulled upward when a short calibration window contains speech,
    # a bump, or other transient noise. The lower quartile better represents the
    # steady background in this short window.
    noise_floor = float(np.percentile(noise_levels, 25)) if noise_levels else 0.0
    return max(float(configured), noise_floor * float(multiplier))


async def record_until_silence(cfg: dict) -> np.ndarray:
    """Capture one local utterance with adaptive energy detection and bounded buffering."""
    a = cfg["audio"]
    rate = int(a["sample_rate"])
    block_seconds = float(a["block_seconds"])
    block = max(1, int(rate * block_seconds))
    silence_limit = float(a["silence_seconds"])
    max_duration = float(a["max_record_seconds"])
    configured_threshold = float(a["energy_threshold"])
    multiplier = float(a.get("threshold_multiplier", 1.5))
    calibration_seconds = float(a.get("calibration_seconds", 0.6))
    min_speech_seconds = float(a.get("min_speech_seconds", 0.12))
    debug_levels = bool(a.get("debug_levels", False))
    device_name = a.get("input_device_name", "").strip()
    input_device = resolve_input_device(device_name or None)

    loop = asyncio.get_running_loop()
    queue: asyncio.Queue[np.ndarray] = asyncio.Queue(maxsize=16)
    dropped_blocks = 0

    def enqueue(data: np.ndarray) -> None:
        nonlocal dropped_blocks
        try:
            queue.put_nowait(data)
        except asyncio.QueueFull:
            # Drop stale audio rather than letting latency grow without bound.
            dropped_blocks += 1

    def callback(indata, frames, time_info, status):
        # Copy because PortAudio owns/reuses the callback buffer.
        data = indata[:, 0].copy()
        loop.call_soon_threadsafe(enqueue, data)

    chunks: list[np.ndarray] = []
    try:
        with sd.InputStream(
            device=input_device,
            samplerate=rate,
            channels=int(a.get("channels", 1)),
            dtype="float32",
            blocksize=block,
            callback=callback,
        ):
            if device_name:
                print(f"Using audio input route: {device_name}", flush=True)
            print("Calibrating microphone — please stay quiet for a moment…",
                  flush=True)

            calibration: list[np.ndarray] = []
            deadline = time.monotonic() + calibration_seconds
            while time.monotonic() < deadline:
                try:
                    calibration.append(await asyncio.wait_for(queue.get(), timeout=2.0))
                except asyncio.TimeoutError as e:
                    raise AudioCaptureError(
                        "No microphone audio received during calibration. Check PipeWire input."
                    ) from e

            noise_levels = [rms_level(chunk) for chunk in calibration]
            threshold = detection_threshold(noise_levels, configured_threshold, multiplier)

            # Remove queued calibration blocks; the utterance starts after the prompt.
            while True:
                try:
                    queue.get_nowait()
                except asyncio.QueueEmpty:
                    break

            print(
                f"Listening… speak now. (threshold={threshold:.6f}; Ctrl+C cancels)",
                flush=True,
            )

            speech_started = False
            active_seconds = 0.0
            last_voice = time.monotonic()
            started = time.monotonic()

            while time.monotonic() - started < max_duration:
                try:
                    chunk = await asyncio.wait_for(queue.get(), timeout=2.0)
                except asyncio.TimeoutError as e:
                    raise AudioCaptureError(
                        "No microphone audio received while listening. Check PipeWire input."
                    ) from e

                level = rms_level(chunk)
                if debug_levels:
                    peak = float(np.max(np.abs(chunk))) if chunk.size else 0.0
                    print(f"Audio level: rms={level:.6f} peak={peak:.6f}", flush=True)

                now = time.monotonic()
                chunks.append(chunk)

                if level >= threshold:
                    active_seconds += len(chunk) / rate
                    last_voice = now
                    if active_seconds >= min_speech_seconds:
                        speech_started = True
                elif speech_started and now - last_voice >= silence_limit:
                    break

            if dropped_blocks:
                print(f"Audio note: dropped {dropped_blocks} stale audio block(s).",
                      flush=True)

            if not speech_started:
                if debug_levels:
                    raise AudioCaptureError(
                        "No sustained speech detected. Check the printed RMS/peak levels "
                        "against the configured threshold."
                    )
                raise AudioCaptureError(
                    "I didn't detect enough speech. Try a slightly longer phrase or enable "
                    "audio.debug_levels to inspect microphone levels."
                )

    except sd.PortAudioError as e:
        raise AudioCaptureError(f"Could not open microphone: {e}") from e

    if not chunks:
        raise AudioCaptureError("No audio was captured.")

    return np.concatenate(chunks).astype(np.float32, copy=False)
