---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

No completion claims without fresh verification evidence.

Gate:
1. Identify the command that proves the claim.
2. Run the full command now.
3. Read the full output and exit status.
4. Confirm whether the output really supports the claim.
5. Only then state the result.

Applies before:
- Saying tests pass.
- Saying a bug is fixed.
- Saying a build succeeds.
- Committing, opening a PR, or marking work complete.

Rules:
- Previous runs are not enough.
- Partial checks are not enough.
- Confidence is not evidence.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/verification-before-completion/SKILL.md
