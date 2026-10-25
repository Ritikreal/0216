from __future__ import annotations

import re

from .builtin_skills import create_builtin_registry
from .skills import SkillRegistry


def route(text: str) -> tuple[str, str]:
    normalized = re.sub(r"\\s+", " ", re.sub(r"[,!?\\.]+", " ", text.lower())).strip()
    if not normalized:
        return ("empty", "Sorry, I missed that.")

    if normalized in {"hello", "hi", "hi al", "hey", "hey al", "hello al", "good morning al", "good evening al"}:
        return ("reply", "Hey. I'm here. What's up?")

    if any(p in normalized for p in ("who are you", "what are you", "tell me about yourself")):
        return ("reply", "I'm AL, your local assistant. Still learning my way around your desktop, but I'm here.")

    if normalized in {
        "help", "help me", "please help me", "can you help", "can you help me",
        "what can you do", "what can you do right now",
        "what can i do for you", "hey al what can you do",
        "hey what can you do", "hey al what can you do right now",
        "hey al what can i do for you", "hey what can i do for you",
        "can you help me can you help me",
    }:
        return ("reply", "I can answer the time, date, and local system status. More desktop skills are coming next.")

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
    """Route narrowly allowlisted local information requests to registered skills."""
    normalized = re.sub(r"\\s+", " ", re.sub(r"[,!?\\.]+", " ", text.lower())).strip()
    tokens = normalized.split()

    status_tokens = {"status", "al", "i'll", "ill", "and", "en"}
    status_only = bool(tokens) and "status" in tokens and all(token in status_tokens for token in tokens)
    if normalized in {"status", "al status", "are you ready", "i'll status", "ill status", "and status", "en status"} or status_only:
        skill_name = "local_status"
    elif normalized in {"time", "what time is it", "what's the time", "whats the time", "tell me the time", "current time", "al time"}:
        skill_name = "local_time"
    elif normalized in {"date", "what's the date", "whats the date", "what is the date", "what's today's date", "whats todays date", "what day is it", "what is today's date", "today's date", "todays date", "al date"}:
        skill_name = "local_date"
    else:
        return route(text)

    active_registry = registry if registry is not None else create_builtin_registry()
    result = active_registry.execute(skill_name)
    if result.ok:
        return ("reply", result.message)
    return ("reply", "I couldn't check that local information safely.")
