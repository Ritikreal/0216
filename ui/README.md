# AL Quickshell HUD preview

This is the first visual shell for AL on Arch Linux + Hyprland. It is intentionally a UI prototype: chat messages are local demo state, and the voice/runtime bridge is not connected yet.

## Install and run

Install Quickshell from your configured Arch repositories/AUR using your preferred package manager. Then, from the repository root:

```fish
quickshell -p ui/quickshell
```

If your installed Quickshell version uses a different CLI syntax, check `quickshell --help`.

## Controls

- `Ctrl+Space`: expand the HUD and toggle the preview listening indicator.
- `Escape`: collapse the HUD.
- Type into the chat box and press Enter to preview message layout.

## Design and safety boundaries

- Near-black glass panels with restrained cyan highlights.
- Compact core header and expandable conversation panel.
- Demo replies are not AI output.
- No microphone capture, shell execution, or desktop actions are wired into this UI.
- The next integration step is a documented local IPC contract with explicit runtime states and validated skill requests.
