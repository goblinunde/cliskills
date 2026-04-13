---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification
---

# Using Git Worktrees

Create isolated workspaces on separate branches instead of working directly in the current tree.

Directory preference:
1. Existing `.worktrees/`
2. Existing `worktrees/`
3. A location specified by local instructions
4. Otherwise ask the user

Safety checks:
- If using a project-local worktree directory, confirm it is ignored by git before creating a worktree.
- If it is not ignored, fix `.gitignore` first.

After creation:
1. Create the worktree on a new branch.
2. Run project setup commands appropriate to the stack.
3. Run a clean baseline verification.
4. Report the path and baseline status.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/using-git-worktrees/SKILL.md
