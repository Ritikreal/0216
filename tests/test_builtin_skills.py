from al.builtin_skills import create_builtin_registry
from al.skills import SkillPolicy


def test_builtin_registry_exposes_only_read_only_local_skills():
    descriptions = create_builtin_registry().describe()
    assert {item[0] for item in descriptions} == {"local_status", "local_time", "local_date"}
    assert all(item[2] is SkillPolicy.SAFE for item in descriptions)


def test_builtin_local_status_executes_without_arguments():
    result = create_builtin_registry().execute("local_status")
    assert result.ok
    assert result.message.startswith("AL is ready.")
    assert result.data == {"status": "ready"}


def test_builtin_local_status_rejects_arguments():
    result = create_builtin_registry().execute("local_status", {"command": "anything"})
    assert not result.ok
    assert result.message == "Invalid arguments."


def test_local_time_returns_local_time_and_structured_value():
    result = create_builtin_registry().execute("local_time")
    assert result.ok
    assert result.message.startswith("It's ")
    assert "time" in result.data


def test_local_date_returns_date_and_structured_value():
    result = create_builtin_registry().execute("local_date")
    assert result.ok
    assert result.message.startswith("Today is ")
    assert "date" in result.data
