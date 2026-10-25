from __future__ import annotations
import tomllib
from pathlib import Path

DEFAULT_CONFIG = Path.home() / ".config/al/settings.toml"

def load_config(path: Path | None = None) -> dict:
    target = path or DEFAULT_CONFIG
    with target.open("rb") as f:
        return tomllib.load(f)
