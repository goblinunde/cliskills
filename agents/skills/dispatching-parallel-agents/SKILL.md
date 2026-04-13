---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# Dispatching Parallel Agents

Dispatch one agent per independent problem domain. Keep scopes isolated and self-contained.

Use when:
- Multiple failures have unrelated root causes.
- Multiple subsystems can be investigated independently.
- Parallel work will not touch shared state or overlapping files.

Do not use when:
- Failures are related.
- Understanding requires whole-system context.
- Agents would interfere with one another.

Per-agent prompt requirements:
- Narrow scope.
- Clear success condition.
- Explicit constraints.
- Explicit expected output.

Integration steps:
1. Group issues by independent domain.
2. Dispatch focused agents in parallel.
3. Review each result.
4. Check for conflicts and run full verification.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/dispatching-parallel-agents/SKILL.md
