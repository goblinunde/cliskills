---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

Execute a plan by dispatching a fresh implementer per task, then run two review gates after each task: spec compliance first, code quality second.

Core workflow:
1. Read the plan and extract the full task list.
2. Create todos for all tasks.
3. Dispatch an implementer subagent for one task.
4. Handle implementer outcomes: `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED`.
5. Run spec review.
6. If needed, have the implementer fix issues and re-run spec review.
7. Run code quality review.
8. If needed, have the implementer fix issues and re-run quality review.
9. Mark the task complete.
10. Repeat for the next task.
11. Finish with branch-completion workflow.

Rules:
- Fresh subagent per task.
- Do not skip either review gate.
- Do not start quality review before spec review passes.
- Do not move to the next task while either review still has open issues.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/subagent-driven-development/SKILL.md
