from __future__ import annotations

import argparse
import asyncio
import logging
import time
from pathlib import Path

from .audio import AudioCaptureError, record_until_silence
from .config import load_config
from .intent import route
from .speech import KokoroSpeaker, SpeechRecognizer


async def listen_once(cfg: dict, stt: SpeechRecognizer, tts: KokoroSpeaker):
    total_started = time.perf_counter()
    try:
        capture_started = time.perf_counter()
        audio = await record_until_silence(cfg)
        capture_seconds = time.perf_counter() - capture_started

        print("Transcribing locally…", flush=True)
        stt_started = time.perf_counter()
        text = await stt.transcribe(audio)
        stt_seconds = time.perf_counter() - stt_started

        print(f"You: {text or '(no transcript)'}", flush=True)
        kind, response = route(text)
        print(f"AL: {response}", flush=True)

        tts_started = time.perf_counter()
        spoken = await tts.speak(response)
        tts_seconds = time.perf_counter() - tts_started

        total_seconds = time.perf_counter() - total_started
        print(
            "Timing: "
            f"capture {capture_seconds:.2f}s | "
            f"STT {stt_seconds:.2f}s | "
            f"TTS {'played' if spoken else 'disabled/skipped'} "
            f"({tts_seconds:.2f}s) | total {total_seconds:.2f}s",
            flush=True,
        )
        if kind == "empty":
            print("Tip: try speaking a little closer to the built-in microphone.")
    except AudioCaptureError as e:
        print(f"Audio: {e}")
    except Exception as e:
        logging.exception("Voice turn failed")
        print(f"AL: This turn failed safely: {e}")


async def run(args):
    cfg = load_config(Path(args.config) if args.config else None)
    logging.basicConfig(
        level=getattr(
            logging, cfg["assistant"].get("log_level", "INFO").upper(), logging.INFO
        ),
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    stt = SpeechRecognizer(cfg)
    tts = KokoroSpeaker(cfg)

    # Persistent mode warms both local models before the first utterance.
    # --once stays lazy unless --warm is requested.
    should_warm = args.warm or not args.once
    if should_warm:
        print("Loading local speech recognition model…", flush=True)
        started = time.perf_counter()
        await asyncio.to_thread(stt.load)
        print(
            f"Speech recognition ready in {time.perf_counter() - started:.2f}s.",
            flush=True,
        )

        print("Loading local Kokoro voice…", flush=True)
        tts_started = time.perf_counter()
        try:
            await asyncio.to_thread(tts.load)
            print(
                f"Kokoro voice ready in {time.perf_counter() - tts_started:.2f}s. "
                "Both speech models stay loaded for this session.",
                flush=True,
            )
        except Exception as exc:
            # Keep listening/transcription usable even if local TTS setup fails.
            print(f"Local voice could not be preloaded: {exc}", flush=True)
            print("AL will still listen; spoken output may be unavailable.", flush=True)

    if args.once:
        await listen_once(cfg, stt, tts)
        return

    print("AL Phase 2 — persistent local push-to-talk runtime")
    print("Press Enter to record one utterance; type q then Enter to quit.")
    while True:
        choice = await asyncio.to_thread(input, "\n[Enter = talk / q = quit] ")
        if choice.strip().lower() == "q":
            break
        await listen_once(cfg, stt, tts)


def main():
    parser = argparse.ArgumentParser(prog="al", description="AL local-first voice MVP")
    parser.add_argument("--config", help="TOML config path")
    parser.add_argument(
        "--warm",
        action="store_true",
        help="Load local speech recognition and Kokoro models before listening",
    )
    parser.add_argument("--once", action="store_true", help="Record and process one utterance")
    args = parser.parse_args()
    try:
        asyncio.run(run(args))
    except KeyboardInterrupt:
        print("\nAL: Cancelled.")
    except Exception as e:
        print(f"AL startup error: {e}")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
