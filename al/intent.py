from __future__ import annotations

import re

from .builtin_skills import create_builtin_registry
from .skills import SkillRegistry


# Phase 2 recognizes harmless phrases only. No arbitrary text becomes an action.
def route(text: str) -> tuple[str, str]:
    normalized = re.sub(r"\s+", " ", text.lower()).strip(" .!?\t\n")
    if not normalized:
        return ("empty", "Sorry, I missed that.")

    if normalized in {"hello", "hi", "hi al", "hey", "hey al", "hello al", "good morning al", "good evening al"}:
        return ("reply", "Hey. I'm here. What's up?")

    if any(p in normalized for p in ("who are you", "what are you", "tell me about yourself")):
        return ("reply", "I'm AL, your local assistant. Still learning my way around your desktop, but I'm here.")

    if normalized in {
        "help", "help me", "please help me", "can you help", "can you help me",
        "what can you do", "what can you do right now",
        "can you help me can you help me",
    }:
        return ("reply", "Right now, I can listen and reply locally. Desktop controls are next.")

    if normalized in {"stop", "cancel", "never mind", "nevermind"}:
        return ("reply", "Cancelled.")

    if normalized in {"that's all", "thats all"}:
        return ("reply", "Got it.")

    if any(p in normalized for p in ("thank you", "thanks al", "thanks")):
        return ("reply", "Anytime.")

    if any(p in normalized for p in ("are you there", "you there", "can you hear me")):
        return ("reply", "Yep. Loud and clear.")

    return ("unknown", "I heard you. I can't do that yet.")


def route_with_skills(
    text: str, registry: SkillRegistry | None = None
) -> tuple[str, str]:
    """Route exact, harmless status phrases through the typed skill registry."""
    normalized = re.sub(r"\s+", " ", text.lower()).strip(" .!?\t\n")
    # Normalize punctuation for repeated words, e.g. "Status. Status. Status."
    status_tokens = re.sub(r"[,!?\.]+", " ", text.lower())
    status_tokens = re.sub(r"\s+", " ", status_tokens).strip().split()
    # Only accept short, allowlisted status-only utterances. Never treat a
    # status word embedded in an arbitrary command as permission to act.
    status_only = bool(status_tokens) and "status" in status_tokens and all(
        token in {"status", "al", "i'll", "ill", "and", "en"} for token in status_tokens
    )
    if normalized in {
        "status", "al status", "are you ready", "al, status",
        "i'll status", "ill status", "and status", "en status",
    } or status_only:
        active_registry = registry if registry is not None else create_builtin_registry()
        result = active_registry.execute("local_status")
        if result.ok:
            return ("reply", result.message)
        return ("reply", "I couldn't check my local status safely.")
    return route(text)
