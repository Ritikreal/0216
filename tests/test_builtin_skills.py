from al.builtin_skills import create_builtin_registry
from al.skills import SkillPolicy


def test_builtin_registry_exposes_only_local_status():
    registry = create_builtin_registry()
    descriptions = registry.describe()
    assert len(descriptions) == 1
    name, description, policy = descriptions[0]
    assert name == "local_status"
    assert "runtime" in description.lower()
    assert policy is SkillPolicy.SAFE


def test_builtin_local_status_executes_without_arguments():
    result = create_builtin_registry().execute("local_status")
    assert result.ok
    assert result.message == "AL runtime is ready."
    assert result.data == {"status": "ready"}


def test_builtin_local_status_rejects_arguments():
    result = create_builtin_registry().execute("local_status", {"command": "anything"})
    assert not result.ok
    assert result.message == "Invalid arguments."
