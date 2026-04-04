#!/usr/bin/env python3
"""Normalize skill frontmatter to the subset accepted by Codex quick_validate."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ALLOWED_KEYS = {"allowed-tools", "description", "license", "metadata", "name"}
TOP_LEVEL_KEY = re.compile(r"^([A-Za-z0-9_-]+):")


def normalize_frontmatter(text: str) -> str:
    lines = text.splitlines(keepends=True)
    if len(lines) < 3 or lines[0].strip() != "---":
        return text

    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return text

    kept: list[str] = []
    keep_block = False

    for line in lines[1:end]:
        match = TOP_LEVEL_KEY.match(line)
        if match:
            keep_block = match.group(1) in ALLOWED_KEYS
            if keep_block:
                kept.append(line)
            continue

        if keep_block:
            kept.append(line)

    return "".join([lines[0], *kept, lines[end], *lines[end + 1 :]])


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: normalize_skill_for_quick_validate.py path/to/SKILL.md", file=sys.stderr)
        return 1

    path = Path(sys.argv[1])
    text = path.read_text(encoding="utf-8")
    path.write_text(normalize_frontmatter(text), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
