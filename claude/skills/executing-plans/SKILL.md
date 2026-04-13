---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

Use a written implementation plan as the source of truth. Review it first, then execute tasks in order and stop on blockers.

Process:
1. Read the plan.
2. Review it critically and raise gaps before starting.
3. Track tasks as todo items.
4. Execute tasks exactly as written, including required verification.
5. When complete, hand off to `superpowers:finishing-a-development-branch`.

Stop and ask for help if:
- The plan has critical gaps.
- Instructions are unclear.
- Verification fails repeatedly.
- A dependency or environment blocker appears.

Notes:
- Prefer `superpowers:subagent-driven-development` when subagents are available.
- Do not start implementation on `main` or `master` without explicit consent.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/executing-plans/SKILL.md
