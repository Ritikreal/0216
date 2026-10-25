import asyncio
import time
import numpy as np
import sounddevice as sd


class AudioCaptureError(RuntimeError):
    pass


async def record_until_silence(cfg: dict) -> np.ndarray:
    """Capture one utterance locally, using a short noise calibration."""
    a = cfg["audio"]
    rate = int(a["sample_rate"])
    block_seconds = float(a["block_seconds"])
    block = max(1, int(rate * block_seconds))
    silence_limit = float(a["silence_seconds"])
    max_duration = float(a["max_record_seconds"])
    configured_threshold = float(a["energy_threshold"])

    loop = asyncio.get_running_loop()
    queue: asyncio.Queue[np.ndarray] = asyncio.Queue(maxsize=16)

    def enqueue(data: np.ndarray) -> None:
        try:
            queue.put_nowait(data)
        except asyncio.QueueFull:
            # Drop stale audio instead of building up latency.
            pass

    def callback(indata, frames, time_info, status):
        data = indata[:, 0].copy()
        loop.call_soon_threadsafe(enqueue, data)

    chunks: list[np.ndarray] = []
    try:
        with sd.InputStream(
            samplerate=rate,
            channels=1,
            dtype="float32",
            blocksize=block,
            callback=callback,
        ):
            # Calibrate before asking the user to speak.
            print("Calibrating microphone — please stay quiet for a moment…",
                  flush=True)
            calibration = []
            deadline = time.monotonic() + 0.6

            while time.monotonic() < deadline:
                try:
                    chunk = await asyncio.wait_for(queue.get(), timeout=2.0)
                except asyncio.TimeoutError:
                    raise AudioCaptureError(
                        "No microphone audio received. Check PipeWire input."
                    )
                calibration.append(chunk)

            noise_levels = [
                float(np.sqrt(np.mean(np.square(c)) + 1e-12))
                for c in calibration
            ]
            noise_floor = float(np.median(noise_levels))
            threshold = max(configured_threshold, noise_floor * 2.5)

            # Keep calibration audio out of the utterance.
            while not queue.empty():
                try:
                    queue.get_nowait()
                except asyncio.QueueEmpty:
                    break

            print(
                f"Listening… speak now. (threshold={threshold:.4f}; "
                "Ctrl+C cancels)",
                flush=True,
            )

            speech_started = False
            last_voice = time.monotonic()
            started = time.monotonic()

            while time.monotonic() - started < max_duration:
                try:
                    chunk = await asyncio.wait_for(queue.get(), timeout=2.0)
                except asyncio.TimeoutError:
                    raise AudioCaptureError(
                        "No microphone audio received. Check PipeWire input."
                    )

                chunks.append(chunk)
                energy = float(np.sqrt(np.mean(np.square(chunk)) + 1e-12))
                now = time.monotonic()

                if energy >= threshold:
                    speech_started = True
                    last_voice = now
                elif speech_started and now - last_voice >= silence_limit:
                    break

            if not speech_started:
                raise AudioCaptureError(
                    "I didn't detect speech. Try again or check microphone levels."
                )

    except sd.PortAudioError as e:
        raise AudioCaptureError(f"Could not open microphone: {e}") from e

    if not chunks:
        raise AudioCaptureError("No audio was captured.")

    return np.concatenate(chunks).astype(np.float32, copy=False)


