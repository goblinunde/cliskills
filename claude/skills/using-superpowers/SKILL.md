---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

# Using Superpowers

Check for relevant skills before doing anything else. If there is even a small chance a skill applies, load it first. User instructions still outrank Superpowers skills.

Priority:
- User instructions
- Superpowers skills
- Default system behavior

Rules:
- Check for skills before clarifying questions, code exploration, or implementation.
- Process skills come first, then implementation skills.
- If a skill applies, use it; do not rationalize around it.

Core sequence:
1. Receive task.
2. Check whether any skill might apply.
3. Load the skill first.
4. Announce that the skill is being used.
5. Follow the skill exactly.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/using-superpowers/SKILL.md
