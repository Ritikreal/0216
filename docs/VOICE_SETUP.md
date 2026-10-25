# Local voice output for AL

AL uses Kokoro ONNX for local speech synthesis. The selected voice is `af_heart`. Speech generation and playback run locally; no cloud TTS, API key, or subscription is used.

## 1. Install the runtime

From the AL project directory:

```fish
cd ~/Projects/al-phase2/al-phase2
source .venv/bin/activate.fish
python -m pip install -e .
```

## 2. Download the model and voice bundle once

```fish
mkdir -p ~/.local/share/al/kokoro
set voice_dir ~/.local/share/al/kokoro
curl -fL 'https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.1/kokoro-v1.0.int8.onnx' -o $voice_dir/kokoro-v1.0.onnx
curl -fL 'https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.1/voices-v1.0.bin' -o $voice_dir/voices-v1.0.bin
```

## 3. Configure your personal settings

Edit the user settings file (not the repository template):

```fish
nano ~/.config/al/settings.toml
```

Under `[tts]`, use these values, replacing `ritik` if your Linux home directory differs:

```toml
model = "/home/ritik/.local/share/al/kokoro/kokoro-v1.0.onnx"
voices = "/home/ritik/.local/share/al/kokoro/voices-v1.0.bin"
voice = "af_heart"
speed = 1.0
```

Keep only one `[tts]` section in the file. The model and voice bundle must both exist locally. The first spoken response loads the TTS model; later responses reuse it in memory.

## 4. Test

```fish
cd ~/Projects/al-phase2/al-phase2
source .venv/bin/activate.fish
python -m pip install -e .
al
```

Say "Hey AL" and then "Who are you?". AL prints its text response and speaks it through `pw-play` or `aplay`.

## Troubleshooting

- If AL says a Kokoro file is missing, check both paths in `~/.config/al/settings.toml`.
- If dependencies are missing, run `.venv/bin/python -m pip install -e .`.
- If playback fails, verify `pw-play` works independently.
- Runtime STT, TTS, and playback stay local. The model files are downloaded only during setup, never by AL at runtime.
