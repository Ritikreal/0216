# Local voice output for AL

This adds spoken replies without a cloud service. Piper generates speech locally, and AL plays the resulting WAV through PipeWire. The first setup needs an internet connection to install Piper and download the voice; normal runtime uses local files.

## 1. Install Piper in AL's virtual environment

From the AL project directory, with the existing venv:

```fish
cd ~/Projects/al-phase2/al-phase2
source .venv/bin/activate.fish
python -m pip install piper-tts
```

This is an optional local dependency. It does not use a paid API.

## 2. Download the voice files once

The default recommendation is **English (US) Ryan, medium quality**: a masculine voice with a good quality/size balance. The ONNX model is about 63 MB. Voice files are published in the [Piper voices repository](https://huggingface.co/rhasspy/piper-voices/tree/v1.0.0/en/en_US/ryan/medium); review the voice's model card/license before redistributing it.

```fish
mkdir -p ~/.local/share/al/voices
set voice_dir ~/.local/share/al/voices
curl -fL 'https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/medium/en_US-ryan-medium.onnx?download=true' -o $voice_dir/en_US-ryan-medium.onnx
curl -fL 'https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/medium/en_US-ryan-medium.onnx.json?download=true' -o $voice_dir/en_US-ryan-medium.onnx.json
```

The `.onnx` model and matching `.onnx.json` sidecar are both required. These commands download them explicitly; AL itself does not download voices at runtime.

## 3. Point AL at the local voice

Edit your personal settings file (not the repository template):

```fish
nano ~/.config/al/settings.toml
```

Under the existing `[tts]` section, set:

```toml
model = "/home/REPLACE_WITH_YOUR_LINUX_USERNAME/.local/share/al/voices/en_US-ryan-medium.onnx"
executable = "/home/REPLACE_WITH_YOUR_LINUX_USERNAME/Projects/al-phase2/al-phase2/.venv/bin/piper"
```

Replace `REPLACE_WITH_YOUR_LINUX_USERNAME` in both paths with your Linux username. Do not include angle brackets. Using the explicit venv path avoids depending on your shell's PATH when AL is launched later by a desktop shortcut or service.

## 4. Test Piper independently

```fish
echo 'Hello. I am AL. Your local assistant is online.' | .venv/bin/piper --model ~/.local/share/al/voices/en_US-ryan-medium.onnx --output_file /tmp/al-voice-test.wav
pw-play /tmp/al-voice-test.wav
```

If this works, run `al`, say a short phrase, and confirm that AL prints its response and then speaks it. The current implementation generates a complete WAV before playback, so the first spoken response may take longer than transcription. We can optimize perceived latency after this works reliably.

## Troubleshooting

- If `curl` fails, retry the download; no voice model is bundled with AL.
- If Piper reports a missing model/config, verify both files exist and the model path is absolute.
- If `pw-play` is missing, install the PipeWire utilities package for your Arch setup, or use `aplay` if available.
- If AL prints `TTS disabled/skipped`, check that `tts.model` points to the `.onnx` file and `tts.executable` points to the installed Piper executable.
- Runtime speech synthesis and playback remain local. No cloud transcription, cloud TTS, API key, or paid subscription is required.
