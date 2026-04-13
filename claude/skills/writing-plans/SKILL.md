---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

Write implementation plans for an engineer with almost no context. Plans must be concrete, complete, and broken into very small tasks.

Requirements:
- Save plans to `docs/superpowers/plans/YYYY-MM-DD-.md` unless user preferences override it.
- Map file responsibilities before task breakdown.
- Use exact file paths.
- Use bite-sized checklist steps.
- Include concrete code, commands, and expected outputs.
- Follow DRY, YAGNI, TDD, and frequent commits.

Each task should include:
- Files to create or modify.
- A failing test step.
- A step to verify the test fails.
- Minimal implementation.
- A step to verify the test passes.
- A commit step.

Rules:
- No placeholders like `TODO`, `TBD`, or vague directives such as "add error handling".
- Self-review the plan for coverage, placeholders, and naming consistency before handoff.
- After writing the plan, offer either subagent-driven execution or inline execution.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/writing-plans/SKILL.md
