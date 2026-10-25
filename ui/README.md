# AL Quickshell HUD

A cinematic, local-first desktop HUD for Arch Linux + Hyprland. The UI uses native Quickshell/QML components rather than a browser-based React stack, keeping it lightweight and desktop-native.

## Run

From the repository root:

```fish
quickshell -p ui/quickshell
```

If your installed Quickshell version uses different CLI syntax, check `quickshell --help`.

## Current interface

- Compact top-edge island with an animated AL core and state indicator.
- Expandable workspace with Overview, Chat, Capabilities, Activity, and Settings.
- Overview with quick navigation, an animated core visualization, and honest runtime status labels.
- Local-only chat preview with success/error feedback. Messages are not sent to an AI model yet.
- Capabilities page that distinguishes existing CLI speech features from work not yet integrated into the HUD.
- Session activity stream and a clear-log action.
- Keyboard state previews: Ctrl+1 through Ctrl+6.
- Ctrl+Space toggles the expanded state and preview listening indicator; Escape collapses the workspace.

## Important truth about functionality

This is a UI layer and preview, not a connected assistant workspace yet. It does not start microphone capture, invoke the AI runtime, execute shell commands, or control the desktop. The state buttons only preview the HUD states. The capability labels identify that boundary rather than pretending integrations exist.

## Design intent

- Near-black, graphite, and restrained cyan/teal with occasional amber status.
- A distinctive animated core, compact typography, layered surfaces, and clear state hierarchy.
- Keyboard-first navigation and scrollable content to avoid clipping at smaller sizes.
- Native QML motion and controls instead of adding a web framework to Quickshell.

## Next integration work

1. Define a local IPC contract between the Python runtime and HUD.
2. Send real IDLE/LISTENING/THINKING/SPEAKING/ACTION/ERROR state updates to the HUD.
3. Connect conversation requests to a local model through a validated request interface.
4. Add permission-gated desktop skills and real system telemetry.
5. Test sizing, keyboard focus, accessibility, and performance on the target Hyprland session.
