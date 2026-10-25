from __future__ import annotations

import re


# Phase 2 intentionally only recognizes harmless commands. System-control skills
# and their safety policy are introduced in Phase 3.
def route(text: str) -> tuple[str, str]:
    normalized = re.sub(r"\s+", " ", text.lower()).strip(" .!?\\t\\n")
    if not normalized:
        return ("empty", "Sorry, I missed that.")

    if normalized in {"hello", "hi", "hi al", "hey", "hey al", "hello al", "good morning al", "good evening al"}:
        return ("reply", "Hey. I'm here. What's up?")

    if any(p in normalized for p in ("who are you", "what are you", "tell me about yourself")):
        return ("reply", "I'm AL, your local assistant. Still learning my way around your desktop, but I'm here.")

    if normalized in {"help", "what can you do", "what can you do right now"}:
        return ("reply", "Right now, I can listen and reply locally. Desktop controls are next.")

    if normalized in {"stop", "cancel", "never mind", "nevermind", "that's all", "thats all"}:
        return ("reply", "Got it.")

    if any(p in normalized for p in ("thank you", "thanks al", "thanks")):
        return ("reply", "Anytime.")

    if any(p in normalized for p in ("are you there", "you there", "can you hear me")):
        return ("reply", "Yep. Loud and clear.")

    # Keep unknown requests honest and concise. Never execute arbitrary text.
    return ("unknown", "I heard you. I can't do that yet.")
