from __future__ import annotations
import asyncio
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
import numpy as np


class SpeechRecognizer:
    def __init__(self, cfg: dict):
        self.cfg = cfg["stt"]
        self.model = None

    def load(self):
        from faster_whisper import WhisperModel

        self.model = WhisperModel(
            self.cfg["model"],
            device=self.cfg["device"],
            compute_type=self.cfg["compute_type"],
            local_files_only=True,
        )

    async def transcribe(self, audio: np.ndarray) -> str:
        if self.model is None:
            await asyncio.to_thread(self.load)

        def run() -> str:
            segments, _info = self.model.transcribe(
                audio,
                language=self.cfg.get("language", "en"),
                beam_size=int(self.cfg.get("beam_size", 1)),
                # Our recorder already stops after silence. Whisper's extra VAD
                # can discard very short commands (e.g. "Hey AL") entirely.
                vad_filter=bool(self.cfg.get("vad_filter", False)),
                condition_on_previous_text=False,
            )
            return " ".join(seg.text.strip() for seg in segments).strip()

        return await asyncio.to_thread(run)


class PiperSpeaker:
    def __init__(self, cfg: dict):
        self.model = cfg["tts"].get("model", "").strip()
        self.executable = cfg["tts"].get("executable", "piper")

    async def speak(self, text: str) -> bool:
        if not self.model or not shutil.which(self.executable):
            return False
        if not Path(self.model).is_file():
            print(f"TTS disabled: Piper model not found: {self.model}")
            return False

        def run():
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                wav = tmp.name
            try:
                proc = subprocess.run(
                    [self.executable, "--model", self.model, "--output_file", wav],
                    input=text,
                    text=True,
                    capture_output=True,
                    timeout=30,
                    check=False,
                    env={**os.environ, "PIPER_NO_DOWNLOAD": "1"},
                )
                if proc.returncode != 0:
                    print("Piper failed:", proc.stderr[-500:])
                    return False

                # PipeWire's default player is used; no shell is involved.
                player = shutil.which("pw-play") or shutil.which("aplay")
                if not player:
                    print("No pw-play or aplay found; skipping spoken output.")
                    return False
                result = subprocess.run(
                    [player, wav],
                    capture_output=True,
                    timeout=45,
                    check=False,
                )
                return result.returncode == 0
            finally:
                try:
                    os.unlink(wav)
                except OSError:
                    pass

        return await asyncio.to_thread(run)
