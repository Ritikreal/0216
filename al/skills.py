"""Typed, fail-closed skill registry for AL.

This module defines the safety boundary only. It does not execute shell commands
or infer actions from arbitrary natural-language text.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any, Callable, Mapping


class SkillPolicy(str, Enum):
    SAFE = "safe"
    CONFIRM = "confirm"
    BLOCKED = "blocked"


@dataclass(frozen=True)
class SkillResult:
    ok: bool
    message: str
    data: Mapping[str, Any] | None = None


@dataclass(frozen=True)
class Skill:
    name: str
    description: str
    policy: SkillPolicy
    handler: Callable[[Mapping[str, Any]], SkillResult]
    validate: Callable[[Mapping[str, Any]], bool] = lambda _arguments: True


class SkillRegistry:
    """Register known skills and invoke only validated, permitted handlers."""

    def __init__(self) -> None:
        self._skills: dict[str, Skill] = {}

    def register(self, skill: Skill) -> None:
        if not skill.name or skill.name.strip() != skill.name:
            raise ValueError("Skill name must be non-empty and have no outer whitespace")
        if skill.name in self._skills:
            raise ValueError(f"Skill already registered: {skill.name}")
        self._skills[skill.name] = skill

    def describe(self) -> tuple[tuple[str, str, SkillPolicy], ...]:
        """Return stable metadata without exposing handlers."""
        return tuple(
            (skill.name, skill.description, skill.policy)
            for skill in sorted(self._skills.values(), key=lambda item: item.name)
        )

    def execute(
        self,
        name: str,
        arguments: Mapping[str, Any] | None = None,
        *,
        confirmed: bool = False,
    ) -> SkillResult:
        """Execute a registered skill only when its policy allows it."""
        skill = self._skills.get(name)
        if skill is None:
            return SkillResult(False, "Unknown skill.")

        args = {} if arguments is None else arguments
        if not isinstance(args, Mapping):
            return SkillResult(False, "Invalid arguments.")

        if skill.policy is SkillPolicy.BLOCKED:
            return SkillResult(False, "This skill is blocked.")
        if skill.policy is SkillPolicy.CONFIRM and not confirmed:
            return SkillResult(False, "Confirmation required.")
        try:
            valid = skill.validate(args)
        except Exception:
            return SkillResult(False, "Argument validation failed.")
        if not valid:
            return SkillResult(False, "Invalid arguments.")

        try:
            result = skill.handler(args)
        except Exception:
            # Do not leak stack traces or sensitive exception text to the caller.
            return SkillResult(False, "Skill failed safely.")
        if not isinstance(result, SkillResult):
            return SkillResult(False, "Skill returned an invalid result.")
        return result
