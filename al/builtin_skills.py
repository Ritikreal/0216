"""Small built-in skills with fixed, local behavior."""
from __future__ import annotations

from collections.abc import Mapping
from typing import Any

from .skills import Skill, SkillPolicy, SkillRegistry, SkillResult


def create_builtin_registry() -> SkillRegistry:
    """Build the default registry; no desktop actions are registered yet."""
    registry = SkillRegistry()

    def local_status(_arguments: Mapping[str, Any]) -> SkillResult:
        return SkillResult(True, "AL runtime is ready.", {"status": "ready"})

    registry.register(
        Skill(
            name="local_status",
            description="Report that the AL runtime is available.",
            policy=SkillPolicy.SAFE,
            handler=local_status,
            validate=lambda arguments: not arguments,
        )
    )
    return registry
