from al.skills import Skill, SkillPolicy, SkillRegistry, SkillResult


def test_unknown_skill_fails_closed():
    registry = SkillRegistry()
    result = registry.execute("open_terminal")
    assert not result.ok
    assert result.message == "Unknown skill."


def test_safe_skill_executes_with_valid_arguments():
    registry = SkillRegistry()
    registry.register(
        Skill(
            name="greet",
            description="Return a greeting.",
            policy=SkillPolicy.SAFE,
            validate=lambda args: set(args) <= {"name"}
            and isinstance(args.get("name"), str),
            handler=lambda args: SkillResult(True, f"Hello, {args['name']}!"),
        )
    )
    result = registry.execute("greet", {"name": "AL"})
    assert result == SkillResult(True, "Hello, AL!")


def test_invalid_arguments_do_not_execute_handler():
    called = False

    def handler(_args):
        nonlocal called
        called = True
        return SkillResult(True, "should not run")

    registry = SkillRegistry()
    registry.register(
        Skill(
            name="greet",
            description="Return a greeting.",
            policy=SkillPolicy.SAFE,
            validate=lambda args: isinstance(args.get("name"), str),
            handler=handler,
        )
    )
    result = registry.execute("greet", {"name": 123})
    assert not result.ok
    assert result.message == "Invalid arguments."
    assert not called


def test_confirm_policy_requires_explicit_confirmation():
    called = False

    def handler(_args):
        nonlocal called
        called = True
        return SkillResult(True, "done")

    registry = SkillRegistry()
    registry.register(
        Skill("change_setting", "Change a setting.", SkillPolicy.CONFIRM, handler)
    )
    result = registry.execute("change_setting")
    assert not result.ok
    assert result.message == "Confirmation required."
    assert not called

    assert registry.execute("change_setting", confirmed=True).ok
    assert called


def test_blocked_skill_never_runs():
    called = False

    def handler(_args):
        nonlocal called
        called = True
        return SkillResult(True, "unsafe")

    registry = SkillRegistry()
    registry.register(Skill("danger", "Blocked action.", SkillPolicy.BLOCKED, handler))
    result = registry.execute("danger", confirmed=True)
    assert not result.ok
    assert result.message == "This skill is blocked."
    assert not called


def test_duplicate_skill_names_are_rejected():
    registry = SkillRegistry()
    skill = Skill("greet", "Return a greeting.", SkillPolicy.SAFE, lambda _args: SkillResult(True, "hi"))
    registry.register(skill)
    try:
        registry.register(skill)
    except ValueError:
        pass
    else:
        raise AssertionError("duplicate skill registration should fail")
