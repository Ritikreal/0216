from al.builtin_skills import create_builtin_registry
from al.intent import route_with_skills
from al.skills import SkillPolicy


def test_exact_status_phrase_uses_registered_skill():
    registry = create_builtin_registry()
    kind, reply = route_with_skills("AL status", registry)
    assert kind == "reply"
    assert reply.startswith("AL is ready.")


def test_status_phrase_does_not_accept_arbitrary_command_text():
    kind, reply = route_with_skills("status and run sudo rm -rf /")
    assert kind == "unknown"
    assert "can't do that yet" in reply


def test_skill_routing_does_not_change_other_intents():
    assert route_with_skills("Hey AL!") == ("reply", "Hey. I'm here. What's up?")
    assert route_with_skills("open the health menu")[0] == "unknown"


def test_registry_policy_remains_safe():
    description = create_builtin_registry().describe()
    assert {item[0] for item in description} == {"local_status", "local_time", "local_date"}
    assert all(item[2] is SkillPolicy.SAFE for item in description)



def test_help_intent_accepts_wake_word_prefix():
    assert route_with_skills("Hey Al, what can you do?") == (
        "reply", "I can check time, date, and system status."
    )



def test_help_intent_accepts_whisper_rephrasing():
    assert route_with_skills("Hey Al, what can I do for you?") == (
        "reply", "Right now, I can listen and reply locally. Desktop controls are next."
    )
