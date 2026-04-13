---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

Verify first, then present structured integration options, then clean up appropriately.

Required order:
1. Run the project's full verification command.
2. If verification fails, stop and fix it before offering completion options.
3. Present structured choices such as local merge, PR, keep branch/worktree, or discard.
4. Require explicit confirmation before destructive cleanup.
5. Remove the worktree only for options that truly finish or discard the branch.

Rules:
- Never merge or create a PR without fresh passing verification.
- Never delete work without explicit confirmation.
- Keep worktrees for branches the user wants to preserve.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/finishing-a-development-branch/SKILL.md
