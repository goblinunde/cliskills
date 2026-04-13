---
name: writing-skills
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
---

# Writing Skills

Treat skill authoring as test-driven documentation. First observe how an agent fails without the skill, then write the smallest skill that fixes those failures, then harden it against loopholes.

Core ideas:
- A skill is a reusable technique, pattern, or reference guide.
- `SKILL.md` frontmatter should contain only triggering conditions in `description`, not the workflow summary.
- Optimize for discovery, brevity, and practical reuse.

TDD-style workflow:
1. Run a baseline scenario without the skill and document failure patterns.
2. Write the minimal skill that addresses those failures.
3. Re-test with the skill.
4. Add explicit counters for new rationalizations.
5. Repeat until the skill is reliable.

Authoring rules:
- Use hyphenated names.
- Start descriptions with `Use when...`.
- Keep descriptions about when to use the skill, not how it works.
- Keep the skill self-contained unless heavy references or reusable tools are necessary.
- Test every skill before deploying it.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/writing-skills/SKILL.md
