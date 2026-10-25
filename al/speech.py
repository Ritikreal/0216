from __future__ import annotations

import asyncio
import os
import re
import shutil
import subprocess
import tempfile
import time
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


class KokoroSpeaker:
    """Local Kokoro TTS with lazy model loading and PipeWire playback."""

    def __init__(self, cfg: dict):
        tts = cfg["tts"]
        self.model_path = Path(tts.get("model", "")).expanduser()
        self.voices_path = Path(tts.get("voices", "")).expanduser()
        self.voice = tts.get("voice", "af_heart")
        self.speed = float(tts.get("speed", 1.0))
        self.engine = None

    def load(self):
        if self.engine is not None:
            return

        if not self.model_path.is_file() or not self.voices_path.is_file():
            raise FileNotFoundError(
                "Kokoro model or voices file is missing. Check [tts] paths in "
                "~/.config/al/settings.toml."
            )

        try:
            from kokoro_onnx import Kokoro
        except ImportError as exc:
            raise RuntimeError(
                "Kokoro is not installed in AL's virtual environment. "
                "Install kokoro-onnx and soundfile."
            ) from exc

        # Some Kokoro ONNX exports declare speed as float while the current
        # package's newer-export path supplies int32. Choose the tensor type
        # from the model metadata so AL works with either export format.
        class CompatibleKokoro(Kokoro):
            def _create_audio(self, phonemes, voice, speed):
                from kokoro_onnx import MAX_PHONEME_LENGTH, SAMPLE_RATE

                phonemes = phonemes[:MAX_PHONEME_LENGTH]
                tokens = np.array(self.tokenizer.tokenize(phonemes), dtype=np.int64)
                voice = voice[len(tokens)]
                tokens = [[0, *tokens, 0]]
                input_names = {item.name: item.type for item in self.sess.get_inputs()}

                if "input_ids" in input_names:
                    speed_dtype = (
                        np.float32
                        if input_names.get("speed") == "tensor(float)"
                        else np.int32
                    )
                    inputs = {
                        "input_ids": tokens,
                        "style": np.array(voice, dtype=np.float32),
                        "speed": np.array([speed], dtype=speed_dtype),
                    }
                else:
                    inputs = {
                        "tokens": tokens,
                        "style": voice,
                        "speed": np.ones(1, dtype=np.float32) * speed,
                    }

                audio = self.sess.run(None, inputs)[0]
                return audio, SAMPLE_RATE

        self.engine = CompatibleKokoro(
            str(self.model_path),
            str(self.voices_path),
        )

    async def speak(self, text: str) -> bool:
        """Generate and play sentence-sized chunks so speech starts sooner."""
        if not text.strip():
            return False

        player = shutil.which("pw-play") or shutil.which("aplay")
        if not player:
            print("No pw-play or aplay found; skipping spoken output.")
            return False

        # Split only at sentence boundaries; keep ellipses inside the same chunk.
        chunks = [
            part.strip()
            for part in re.split(r"(?<=[!?])\s+|(?<!\.)\.(?!\.)\s+", text.strip())
            if part.strip()
        ]
        if not chunks:
            chunks = [text.strip()]

        def run() -> bool:
            try:
                self.load()
                import soundfile as sf
            except Exception as exc:
                print(f"Kokoro TTS unavailable: {exc}")
                return False

            generation_total = 0.0
            playback_total = 0.0
            first_audio = True

            for chunk in chunks:
                try:
                    generation_started = time.perf_counter()
                    audio, sample_rate = self.engine.create(
                        chunk,
                        voice=self.voice,
                        speed=self.speed,
                        lang="en-us",
                    )
                    generation_seconds = time.perf_counter() - generation_started
                    generation_total += generation_seconds
                except Exception as exc:
                    print(f"Kokoro TTS unavailable: {exc}")
                    return False

                # Play each completed sentence immediately rather than waiting
                # for the entire response to be synthesized into one large WAV.
                with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                    wav = tmp.name
                try:
                    sf.write(wav, audio, sample_rate)
                    playback_started = time.perf_counter()
                    result = subprocess.run(
                        [player, wav],
                        capture_output=True,
                        timeout=60,
                        check=False,
                    )
                    playback_seconds = time.perf_counter() - playback_started
                    playback_total += playback_seconds
                    if result.returncode != 0:
                        print(
                            "Audio playback failed:",
                            result.stderr.decode(errors="replace")[-500:],
                        )
                        return False
                    if first_audio:
                        print(
                            f"TTS first audio ready in {generation_seconds:.2f}s "
                            "(sentence chunking enabled).",
                            flush=True,
                        )
                        first_audio = False
                finally:
                    try:
                        os.unlink(wav)
                    except OSError:
                        pass

            print(
                f"TTS breakdown: generation {generation_total:.2f}s | "
                f"playback {playback_total:.2f}s | chunks {len(chunks)}",
                flush=True,
            )
            return True

        return await asyncio.to_thread(run)
