# AL — Phase 2 voice-loop MVP

Local-first push-to-talk proof of concept for vanilla Arch + Hyprland + PipeWire. This stage deliberately does **not** install packages, control the desktop, execute shell commands, or use cloud APIs.

## What works in this MVP

- Records a bounded utterance from the default PipeWire/PortAudio input.
- Uses a simple RMS-energy silence detector.
- Transcribes with `faster-whisper` on CPU (model warms after first use; `--warm` preloads it).
- Routes a few safe local phrases without an LLM.
- Can speak through Piper if a local model path is configured.
- Has basic tests proving unknown commands are not executed.

## Install on Arch

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel python python-pip python-virtualenv portaudio pipewire pipewire-audio pipewire-pulse wireplumber piper git
```

`piper` packaging may differ by repository/AUR state. If `pacman` cannot find it, do not blindly install a similarly named package; check `pacman -Ss piper` and `yay -Ss piper`, inspect the package recipe, and install only after reviewing it. Piper is optional for transcription tests.

From this repository directory:

```bash
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e . pytest
mkdir -p ~/.config/al ~/.local/bin ~/.local/state/al
install -m 0644 config/settings.toml ~/.config/al/settings.toml
```

Install a wrapper so the CLI can be run from any directory:

```bash
cat > ~/.local/bin/al <<'SH'
#!/usr/bin/env bash
exec "$HOME/Projects/al/.venv/bin/al" "$@"
SH
chmod 0755 ~/.local/bin/al
```

If you cloned/extracted the project somewhere else, change the path in the wrapper accordingly. Add `~/.local/bin` to `PATH` if needed.

## First tests

```bash
.venv/bin/python -m pytest -q
wpctl status
python -c 'import sounddevice as sd; print(sd.query_devices())'
al --once
```

The first `faster-whisper` model load may download model files. This is the only network-dependent setup step in the default implementation. To keep the runtime strictly offline, prefetch the selected model while connected, verify its files, then disconnect; no cloud transcription fallback exists. The model cache is normally under `~/.cache/huggingface`.

## Configure speech

`config/settings.toml` defaults to `base.en`, CPU, and int8. For a smaller model try `tiny.en`; for better accuracy try `small.en` if latency and RAM permit. Edit `tts.model` to the absolute path of a locally installed Piper `.onnx` voice file. Piper voice files may need a matching `.onnx.json` sidecar.

## Current limitations — intentionally deferred

- The MVP uses Enter-to-talk in the terminal. The global `Super+A` shortcut and top-edge dynamic-island HUD are Phase 4 work, not falsely claimed as implemented here.
- Energy VAD is a baseline, not a robust neural VAD; tune `energy_threshold` for your laptop mic.
- The current Piper path generates a complete WAV before playback, so TTS is not yet streamed.
- There is no LLM or system-control skill yet. Those belong to later approved phases.
- The supplied systemd unit is a template. Review paths and permissions before enabling it; this terminal MVP should be tested first.
