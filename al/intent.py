from __future__ import annotations
import re

# Phase 2 intentionally only recognizes harmless commands. System-control skills
# and their safety policy are introduced in Phase 3.
def route(text: str) -> tuple[str, str]:
    normalized = re.sub(r"\s+", " ", text.lower()).strip(" .!?\t\n")
    if not normalized:
        return ("empty", "I didn't catch that.")
    if normalized in {"hello", "hi al", "hey al", "hello al"}:
        return ("reply", "Hey. I'm here.")
    if any(p in normalized for p in ("who are you", "what are you")):
        return ("reply", "I'm AL. Local, mostly useful, and still under construction.")
    if normalized in {"stop", "cancel", "never mind", "nevermind"}:
        return ("reply", "Cancelled.")
    if normalized in {"help", "what can you do"}:
        return ("reply", "For now, I can hear you and respond locally. Desktop controls arrive in the next phase.")
    return ("unknown", "I heard you, but that skill isn't available yet.")
