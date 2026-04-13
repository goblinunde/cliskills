---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical rigor and verification, not performative agreement or blind implementation
---

# Receiving Code Review

Treat review comments as technical input to evaluate, not instructions to accept blindly.

Response pattern:
1. Read the full feedback.
2. Restate or clarify unclear items.
3. Verify comments against the codebase.
4. Evaluate whether each suggestion is correct for this codebase.
5. Implement or push back with technical reasoning.
6. Test each fix.

Rules:
- No performative agreement.
- Do not partially implement a mixed set of comments if some are unclear.
- Be skeptical of external reviewer feedback until verified.
- Push back factually when a suggestion is wrong, conflicts with prior decisions, or violates YAGNI.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/receiving-code-review/SKILL.md
