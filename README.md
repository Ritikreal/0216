# AL — Local-first voice assistant for Arch + Hyprland

AL is a local-first desktop assistant for Arch Linux, Hyprland, and Wayland. The project combines a Python voice-runtime prototype with a native Quickshell/QML HUD. The goal is a practical assistant with a handmade, Peter Parker-style engineering feel—not a generic sci-fi dashboard.

**Current status:** the CLI voice path and the HUD are separate prototypes. The HUD is not yet connected to the runtime, and its chat, state controls, and activity feed are previews rather than live assistant features.

- [HUD documentation](ui/README.md)
- [Project roadmap and phase exit gates](docs/ROADMAP.md)
- [Voice setup guide](docs/VOICE_SETUP.md)
- [UI/runtime contract](docs/UI_RUNTIME_CONTRACT.md)

## What exists today

### Local voice prototype

- Bounded microphone capture through PortAudio/PipeWire.
- RMS-energy speech detection with DC-offset removal.
- Local speech recognition using faster-whisper on CPU.
- A small set of safe, phrase-based responses; no general LLM conversation is implemented.
- Local Kokoro ONNX speech output, configured for the `af_heart` voice.
- Tests covering the rule that unknown commands are not executed.

The voice loop has previously captured and transcribed a short utterance on the target Arch laptop. Treat this as a development milestone, not a guarantee that every environment or utterance works reliably.

### Quickshell/QML HUD prototype

- Compact top-edge island with an animated AL core and state indicator.
- Expandable workspace with **Overview**, **Chat**, **Capabilities**, **Activity**, and **Settings** sections.
- Keyboard-triggered state previews and preview-only chat/activity behavior.
- Native QML/Quickshell rather than a browser-based UI framework.

The HUD currently does **not** start microphone capture, send messages to an AI model, execute desktop actions, or receive live runtime telemetry. See [ui/README.md](ui/README.md) for the current interface and limitations.

## Design direction

AL should feel like a personal, handmade piece of engineering: matte graphite and near-black surfaces, restrained sage/teal accents, clear labels, compact typography, and purposeful motion. Spider-Man / Peter Parker technology is an inspiration for the character of the interface, not a request to copy a film screen.

The UI is being developed in phases: first a consistent theme and reusable QML components, then a voice-reactive core and effects, then real runtime states and transcript/action feedback, followed by performance and accessibility validation. Planned features are not considered implemented until they are connected and tested.

## Principles and safety

- Audio capture, transcription, and configured speech output stay local at runtime. There is no cloud transcription fallback.
- Model files are downloaded as an explicit setup step and loaded from local cache at runtime.
- A language model must never be allowed to run arbitrary shell commands.
- Desktop operations must go through typed, validated skills with explicit **SAFE**, **CONFIRM**, or **BLOCKED** policies.
- Consequential actions require confirmation; prohibited or unsupported actions fail closed.
- The UI is a client of the runtime. It must not duplicate intent-routing or execute skills directly.
- Keep changes modular, testable, and reversible. Avoid unnecessary dependencies and duplicate model instances.
- Hardware performance claims require measurements on the target machine; CI or code inspection alone is not proof.

## Install on Arch Linux

Install the system packages:

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel python python-pip python-virtualenv portaudio pipewire pipewire-audio pipewire-pulse wireplumber git
```

From the repository directory:

```bash
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e . pytest
mkdir -p ~/.config/al ~/.local/bin ~/.local/state/al
install -m 0644 config/settings.toml ~/.config/al/settings.toml
```

Follow [the Kokoro voice setup guide](docs/VOICE_SETUP.md) to download the required local model and voice bundle. The first model download is a setup step; runtime inference is configured for local-only loading.

## Run the HUD

From the repository root, try:

```bash
quickshell -p ui/quickshell
```

Check `quickshell --help` if your installed version uses different command-line syntax. The HUD is currently a preview and is not a replacement for the CLI voice workflow.

## Test and diagnose

```bash
.venv/bin/python -m pytest -q
wpctl status
python -c 'import sounddevice as sd; print(sd.query_devices())'
al --once
```

The `config/settings.toml` defaults to faster-whisper `base.en`, CPU, and int8 compute. `tiny.en` may reduce latency at some cost to accuracy; `small.en` may improve accuracy at higher resource cost. Benchmark on the target laptop before changing defaults.

## Known gaps

- The voice workflow still uses the terminal Enter-to-talk path; no global push-to-talk hotkey is connected end-to-end.
- The HUD/runtime IPC bridge and live state updates still need implementation and end-to-end validation.
- HUD chat, state chips, and activity feed are preview-only.
- General local-model conversation and connected desktop-control skills are not implemented.
- Kokoro currently generates a complete WAV before playback.
- The systemd unit is a template; review its paths and environment before enabling it.
- UI frame rate, idle CPU use, and other performance figures have not yet been measured and verified.

## Development approach

Work in small, reviewable phases. Preserve the local-first design and the SAFE / CONFIRM / BLOCKED policy boundary. Validate QML syntax, Python tests, runtime behavior, and performance separately; do not describe planned UI elements as working integrations.

See the [roadmap](docs/ROADMAP.md) for phase goals and exit gates, and the [UI README](ui/README.md) for the HUD-specific status.
