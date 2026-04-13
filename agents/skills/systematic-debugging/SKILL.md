---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

No fixes without root-cause investigation first.

Phases:
1. Root cause investigation.
2. Pattern analysis.
3. Hypothesis and minimal testing.
4. Implementation with a failing reproduction first.

Investigation requirements:
- Read error messages carefully.
- Reproduce consistently.
- Check recent changes.
- In multi-component systems, add instrumentation at boundaries to find where the break occurs.
- Trace data flow backward to the source of the bad value or state.

Implementation requirements:
- Create the smallest failing test or reproduction before fixing.
- Make one change at a time.
- Verify the fix and watch for regressions.
- If multiple fixes fail, step back and question the architecture rather than piling on more patches.

Source:
- https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/systematic-debugging/SKILL.md
