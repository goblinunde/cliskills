#!/usr/bin/env python3
"""Manage allow_implicit_invocation policy across repo and local installs."""

from __future__ import annotations

import os
import re
import shlex
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(os.environ.get("REPO_ROOT", Path(__file__).resolve().parents[1])).resolve()
SKILL_DIR = (REPO_ROOT / os.environ.get("SKILL_DIR", "agents/skills")).resolve()
INSTALL_DIR = Path(os.environ.get("INSTALL_DIR", os.path.join(Path.home(), ".codex", "skills"))).expanduser()
CLAUDE_INSTALL_DIR = Path(
    os.environ.get("CLAUDE_INSTALL_DIR", os.path.join(Path.home(), ".claude", "skills"))
).expanduser()
SUPERPOWERS_LOCK = Path(os.environ.get("SUPERPOWERS_LOCK", str(REPO_ROOT / "vendor" / "superpowers.lock")))
MAKE_BIN = os.environ.get("MAKE_BIN", "make")
POLICY = os.environ.get("POLICY", "").strip()
SCOPE = os.environ.get("SCOPE", "").strip() or "repo"
SKILL = os.environ.get("SKILL", "").strip()
SKILLS_RAW = os.environ.get("SKILLS", "").strip()
GROUP = os.environ.get("GROUP", "").strip()

VALID_POLICIES = {"explicit": False, "implicit": True}
VALID_SCOPES = {"repo", "codex", "claude", "all"}
TOP_LEVEL_KEY = re.compile(r"^[A-Za-z0-9_-]+:\s*")


def load_superpowers_skills(lock_file: Path) -> list[str]:
    if not lock_file.is_file():
        return []

    skills: list[str] = []
    in_block = False
    for line in lock_file.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("SUPERPOWERS_SKILLS="):
            in_block = True
            continue
        if in_block and stripped == '"':
            break
        if in_block and stripped:
            skills.append(stripped)
    return skills


def repo_skills() -> list[str]:
    if not SKILL_DIR.is_dir():
        return []
    return sorted(entry.name for entry in SKILL_DIR.iterdir() if entry.is_dir())


def selected_skills() -> list[str]:
    selectors = [bool(SKILL), bool(SKILLS_RAW), bool(GROUP)]
    if sum(selectors) != 1:
        raise ValueError("Use exactly one selector: SKILL=<id>, SKILLS=\"a b\", or GROUP=superpowers|all")

    if SKILL:
        skills = [SKILL]
    elif SKILLS_RAW:
        skills = [item for item in SKILLS_RAW.split() if item]
    elif GROUP == "superpowers":
        skills = load_superpowers_skills(SUPERPOWERS_LOCK)
    elif GROUP == "all":
        skills = repo_skills()
    else:
        raise ValueError(f"Unknown GROUP={GROUP!r}. Supported groups: superpowers, all")

    if not skills:
        raise ValueError("No skills selected.")

    known = set(repo_skills())
    unknown = [skill for skill in skills if skill not in known]
    if unknown:
        raise ValueError(f"Unknown repository skill(s): {' '.join(unknown)}")
    return skills


def update_openai_yaml(path: Path, allow_implicit: bool) -> bool:
    if not path.is_file():
        return False

    lines = path.read_text(encoding="utf-8").splitlines()
    desired = "true" if allow_implicit else "false"

    policy_idx = None
    for idx, line in enumerate(lines):
        if line.strip() == "policy:":
            policy_idx = idx
            break

    changed = False
    if policy_idx is None:
        if lines and lines[-1].strip():
            lines.append("")
        lines.extend(["policy:", f"  allow_implicit_invocation: {desired}"])
        changed = True
    else:
        block_end = len(lines)
        for idx in range(policy_idx + 1, len(lines)):
            stripped = lines[idx].strip()
            if stripped and not lines[idx].startswith((" ", "\t")) and TOP_LEVEL_KEY.match(lines[idx]):
                block_end = idx
                break

        allow_idx = None
        for idx in range(policy_idx + 1, block_end):
            if lines[idx].lstrip().startswith("allow_implicit_invocation:"):
                allow_idx = idx
                break

        if allow_idx is None:
            lines.insert(policy_idx + 1, f"  allow_implicit_invocation: {desired}")
            changed = True
        else:
            replacement = f"  allow_implicit_invocation: {desired}"
            if lines[allow_idx] != replacement:
                lines[allow_idx] = replacement
                changed = True

    if changed:
        path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return changed


def apply_scope(scope: str, base_dir: Path, skills: list[str], allow_implicit: bool) -> tuple[int, int]:
    changed = 0
    skipped = 0

    for skill in skills:
        meta_file = base_dir / skill / "agents" / "openai.yaml"
        if not meta_file.is_file():
            print(f"Skipped {scope}:{skill} (missing {meta_file})")
            skipped += 1
            continue
        if update_openai_yaml(meta_file, allow_implicit):
            print(f"Updated {scope}:{skill} -> allow_implicit_invocation={str(allow_implicit).lower()}")
            changed += 1
        else:
            print(f"Unchanged {scope}:{skill}")
    return changed, skipped


def run_make(target: str) -> None:
    command = [*shlex.split(MAKE_BIN), target]
    completed = subprocess.run(command, cwd=REPO_ROOT, check=False)
    if completed.returncode != 0:
        raise RuntimeError(f"{' '.join(command)} failed with exit code {completed.returncode}")


def main() -> int:
    try:
        if POLICY not in VALID_POLICIES:
            raise ValueError("POLICY must be explicit or implicit")
        if SCOPE not in VALID_SCOPES:
            raise ValueError("SCOPE must be repo, codex, claude, or all")

        allow_implicit = VALID_POLICIES[POLICY]
        skills = selected_skills()

        total_changed = 0
        total_skipped = 0

        if SCOPE in {"repo", "all"}:
            changed, skipped = apply_scope("repo", SKILL_DIR, skills, allow_implicit)
            total_changed += changed
            total_skipped += skipped
            run_make("sync-claude")

        if SCOPE in {"codex", "all"}:
            changed, skipped = apply_scope("codex", INSTALL_DIR, skills, allow_implicit)
            total_changed += changed
            total_skipped += skipped

        if SCOPE in {"claude", "all"}:
            changed, skipped = apply_scope("claude", CLAUDE_INSTALL_DIR, skills, allow_implicit)
            total_changed += changed
            total_skipped += skipped

        print(
            f"Applied policy={POLICY} scope={SCOPE} across {len(skills)} selected skill(s); "
            f"changed={total_changed}, skipped={total_skipped}."
        )
        return 0
    except (ValueError, RuntimeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
