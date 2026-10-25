from al.intent import route

def test_greeting():
    assert route("Hey AL!")[0] == "reply"

def test_unknown_is_not_executed():
    kind, _ = route("sudo rm -rf /")
    assert kind == "unknown"

def test_cancel():
    assert route("cancel")[1] == "Cancelled."


def test_help_reply_is_concise():
    kind, reply = route("What can you do?")
    assert kind == "reply"
    assert "give me a little time" not in reply.lower()
    assert len(reply.split()) <= 12


def test_unknown_reply_is_concise_and_safe():
    kind, reply = route("sudo rm -rf /")
    assert kind == "unknown"
    assert len(reply.split()) <= 8


def test_thanks():
    assert route("Thanks AL")[1] == "Anytime."


def test_presence_check():
    assert route("Are you there?")[1] == "Yep. Loud and clear."

