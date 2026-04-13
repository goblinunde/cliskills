---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development

Write the test first. Watch it fail. Write the minimum code to pass. Then refactor.

Iron law:
- No production code without a failing test first.
- If code was written before the test, delete it and start over from the test.

Cycle:
1. Write one minimal failing test.
2. Run it and confirm it fails for the right reason.
3. Write the minimum code to make it pass.
4. Re-run the test and confirm green.
5. Refactor while keeping tests green.
6. Repeat for the next behavior.

Rules:
- Test one behavior at a time.
- Prefer real behavior over mock-heavy tests.
- Do not add extra features during the green step.
- Do not claim TDD if the red phase never happened.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/test-driven-development/SKILL.md
