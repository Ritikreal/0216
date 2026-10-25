"""Small built-in skills with fixed, local behavior."""
from __future__ import annotations

from collections.abc import Mapping
from datetime import datetime
from pathlib import Path
import os
import time
from typing import Any

from .skills import Skill, SkillPolicy, SkillRegistry, SkillResult


def _read_meminfo() -> tuple[int, int] | None:
    """Return (used MiB, total MiB) from Linux procfs, or None if unavailable."""
    try:
        values: dict[str, int] = {}
        for line in Path("/proc/meminfo").read_text(encoding="ascii").splitlines():
            key, raw, *_ = line.replace(":", "").split()
            if key in {"MemTotal", "MemAvailable"}:
                values[key] = int(raw)
        total = values["MemTotal"]
        available = values["MemAvailable"]
        return max(0, (total - available) // 1024), total // 1024
    except (OSError, ValueError, KeyError):
        return None


def _battery_percent() -> int | None:
    """Return a percentage from a readable battery sysfs entry, if present."""
    root = Path("/sys/class/power_supply")
    try:
        for entry in sorted(root.iterdir()):
            if (entry / "type").read_text(encoding="ascii").strip() != "Battery":
                continue
            capacity = int((entry / "capacity").read_text(encoding="ascii").strip())
            if 0 <= capacity <= 100:
                return capacity
    except (OSError, ValueError):
        return None
    return None


def create_builtin_registry() -> SkillRegistry:
    """Build fixed local-only skills; no shell or network actions are registered."""
    registry = SkillRegistry()

    def local_status(_arguments: Mapping[str, Any]) -> SkillResult:
        parts = ["AL is ready."]
        try:
            uptime_seconds = float(Path("/proc/uptime").read_text(encoding="ascii").split()[0])
            parts.append(f"System uptime is {int(uptime_seconds // 3600)} hours.")
        except (OSError, ValueError, IndexError):
            pass

        try:
            load = os.getloadavg()[0]
            parts.append(f"One-minute CPU load is {load:.2f}.")
        except (OSError, AttributeError):
            pass

        memory = _read_meminfo()
        if memory is not None:
            used, total = memory
            parts.append(f"Memory usage is {used} of {total} megabytes.")
        battery = _battery_percent()
        if battery is not None:
            parts.append(f"Battery is at {battery} percent.")
        message = " ".join(parts)
        return SkillResult(True, message, {"status": "ready"})

    def local_time(_arguments: Mapping[str, Any]) -> SkillResult:
        now = datetime.now().astimezone()
        message = f"It's {now.strftime('%-I:%M %p')}."
        return SkillResult(True, message, {"time": now.isoformat()})

    def local_date(_arguments: Mapping[str, Any]) -> SkillResult:
        now = datetime.now().astimezone()
        message = f"Today is {now.strftime('%A, %B')} {now.day}, {now.year}."
        return SkillResult(True, message, {"date": now.date().isoformat()})

    for skill in (
        Skill(
            name="local_status",
            description="Report local system uptime, CPU load, memory and battery when available.",
            policy=SkillPolicy.SAFE,
            handler=local_status,
            validate=lambda arguments: not arguments,
        ),
        Skill(
            name="local_time",
            description="Report the computer's local time.",
            policy=SkillPolicy.SAFE,
            handler=local_time,
            validate=lambda arguments: not arguments,
        ),
        Skill(
            name="local_date",
            description="Report the computer's local date.",
            policy=SkillPolicy.SAFE,
            handler=local_date,
            validate=lambda arguments: not arguments,
        ),
    ):
        registry.register(skill)
    return registry
