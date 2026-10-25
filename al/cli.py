from __future__ import annotations
import argparse
import asyncio
import logging
from pathlib import Path
from .config import load_config, DEFAULT_CONFIG
from .audio import record_until_silence, AudioCaptureError
from .speech import SpeechRecognizer, PiperSpeaker
from .intent import route

async def listen_once(cfg: dict, stt: SpeechRecognizer, tts: PiperSpeaker):
    try:
        audio = await record_until_silence(cfg)
        print("Transcribing locally…", flush=True)
        text = await stt.transcribe(audio)
        print(f"You: {text or '(no transcript)'}")
        kind, response = route(text)
        print(f"AL: {response}")
        await tts.speak(response)
    except AudioCaptureError as e:
        print(f"Audio: {e}")

async def run(args):
    cfg = load_config(Path(args.config) if args.config else None)
    logging.basicConfig(level=getattr(logging, cfg["assistant"].get("log_level", "INFO").upper(), logging.INFO),
                        format="%(asctime)s %(levelname)s %(name)s: %(message)s")
    stt = SpeechRecognizer(cfg)
    tts = PiperSpeaker(cfg)
    if args.warm:
        print("Loading local speech model into memory…", flush=True)
        await asyncio.to_thread(stt.load)
        print("Speech model ready. No network fallback is configured.")
    if args.once:
        await listen_once(cfg, stt, tts)
        return
    print("AL Phase 2 MVP — local push-to-talk test loop")
    print("Press Enter to record one utterance; type q then Enter to quit.")
    while True:
        choice = await asyncio.to_thread(input, "\n[Enter = talk / q = quit] ")
        if choice.strip().lower() == "q":
            break
        await listen_once(cfg, stt, tts)

def main():
    parser = argparse.ArgumentParser(prog="al", description="AL local-first voice MVP")
    parser.add_argument("--config", help="TOML config path")
    parser.add_argument("--warm", action="store_true", help="Load speech model before listening")
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
