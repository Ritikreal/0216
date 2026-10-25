from al.builtin_skills import create_builtin_registry
from al.intent import route_with_skills
from al.skills import SkillPolicy


def test_exact_status_phrase_uses_registered_skill():
    registry = create_builtin_registry()
    kind, reply = route_with_skills("AL status", registry)
    assert kind == "reply"
    assert reply == "AL runtime is ready."


def test_observed_whisper_status_variants_use_safe_skill():
    for phrase in ("I'll status", "I'll status.", "and status", "EN status"):
        kind, reply = route_with_skills(phrase)
        assert kind == "reply"
        assert reply == "AL runtime is ready."


def test_repeated_status_only_transcript_uses_safe_skill():
    kind, reply = route_with_skills("Status. Status. Status.")
    assert kind == "reply"
    assert reply == "AL runtime is ready."


def test_status_phrase_does_not_accept_arbitrary_command_text():
    kind, reply = route_with_skills("status and run sudo rm -rf /")
    assert kind == "unknown"
    assert "can't do that yet" in reply


def test_skill_routing_does_not_change_other_intents():
    assert route_with_skills("Hey AL!") == ("reply", "Hey. I'm here. What's up?")
    assert route_with_skills("open the health menu")[0] == "unknown"


def test_registry_policy_remains_safe():
    description = create_builtin_registry().describe()
    assert len(description) == 1
    assert description[0][2] is SkillPolicy.SAFE
