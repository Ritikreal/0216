from __future__ import annotations
import re

# Phase 2 intentionally only recognizes harmless commands. System-control skills
# and their safety policy are introduced in Phase 3.
def route(text: str) -> tuple[str, str]:
    normalized = re.sub(r"\s+", " ", text.lower()).strip(" .!?\t\n")
    if not normalized:
        return ("empty", "I didn't catch that.")
    if normalized in {"hello", "hi al", "hey al", "hello al"}:
        return ("reply", "Hey. I'm here. What's up?")
    if any(p in normalized for p in ("who are you", "what are you")):
        return ("reply", "I'm AL. Your local assistant... mostly useful, occasionally charming, and still under construction.")
    if normalized in {"stop", "cancel", "never mind", "nevermind"}:
        return ("reply", "Cancelled.")
    if normalized in {"help", "what can you do"}:
        return ("reply", "Right now, I can hear you and respond locally. Desktop controls are next... give me a little time.")
    return ("unknown", "I heard you. That skill isn't available yet... but we're working on it.")
