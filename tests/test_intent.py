from al.intent import route

def test_greeting():
    assert route("Hey AL!")[0] == "reply"

def test_unknown_is_not_executed():
    kind, _ = route("sudo rm -rf /")
    assert kind == "unknown"

def test_cancel():
    assert route("cancel")[1] == "Cancelled."
