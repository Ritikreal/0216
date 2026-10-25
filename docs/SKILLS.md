# AL skill boundary

The skill registry is the only planned entry point for desktop actions. It is
intentionally separate from speech transcription and phrase routing.

## Policies

- `SAFE`: execute a known, low-risk handler after argument validation.
- `CONFIRM`: refuse unless the caller supplies an explicit confirmation flag.
  A future UI/runtime must obtain that confirmation from the user; a model's
  claim that the user agreed is not confirmation.
- `BLOCKED`: never execute, even if the caller supplies confirmation.

Unknown skill names, invalid arguments, validation errors, handler exceptions,
and malformed handler results fail closed. Error responses do not expose
exception details.

## Important limits

This is a registry and safety boundary, not yet a desktop-control implementation.
It does not map natural language to skills, run shell commands, persist an action
log, or provide a confirmation UI. Do not register a handler that executes an
arbitrary command string. Each real skill should have a fixed implementation,
a narrow argument schema, an explicit policy, and tests for failure behavior.

## Minimal example

```python
from al.skills import Skill, SkillPolicy, SkillRegistry, SkillResult

registry = SkillRegistry()
registry.register(
    Skill(
        name="example_status",
        description="Return a fixed local status message.",
        policy=SkillPolicy.SAFE,
        handler=lambda _args: SkillResult(True, "Ready."),
    )
)
result = registry.execute("example_status")
```

The voice CLI is not wired to this registry yet. Integration comes only after
the registry and permission tests have been validated on the target machine.
