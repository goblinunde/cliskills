#!/usr/bin/env python3
"""Interactive and scriptable dashboard for bundled and installed skills."""

from __future__ import annotations

import os
import re
import shlex
import subprocess
import sys
from collections import Counter
from pathlib import Path


REPO_ROOT = Path(os.environ.get("REPO_ROOT", Path(__file__).resolve().parents[1])).resolve()
SKILL_DIR = Path(os.environ.get("SKILL_DIR", "agents/skills")).expanduser()
CLAUDE_SKILL_DIR = Path(os.environ.get("CLAUDE_SKILL_DIR", "claude/skills")).expanduser()
INSTALL_DIR = Path(os.environ.get("INSTALL_DIR", os.path.join(Path.home(), ".codex", "skills"))).expanduser()
CLAUDE_INSTALL_DIR = Path(
    os.environ.get("CLAUDE_INSTALL_DIR", os.path.join(Path.home(), ".claude", "skills"))
).expanduser()
INSTALL_MODE = os.environ.get("INSTALL_MODE", "fail")
ACTION = os.environ.get("ACTION", "").strip()
SKILL = os.environ.get("SKILL", "").strip()
MAKE_BIN = os.environ.get("MAKE_BIN", "make")
LIST_FORMAT = os.environ.get("LIST_FORMAT", "table").strip() or "table"
VALID_MODES = ("fail", "overwrite", "keep")
VALID_LIST_FORMATS = ("table", "ids")
STATUS_LABELS = ("match", "match+extras", "missing", "differs")
LIST_DESCRIPTION_WIDTH = 96
DASHBOARD_DESCRIPTION_WIDTH = 72


def resolve_repo_path(path: Path) -> Path:
    if path.is_absolute():
        return path.resolve()
    return (REPO_ROOT / path).resolve()


SKILL_DIR = resolve_repo_path(SKILL_DIR)
CLAUDE_SKILL_DIR = resolve_repo_path(CLAUDE_SKILL_DIR)


def load_skill_ids(root: Path) -> list[str]:
    if not root.is_dir():
        return []
    return sorted(entry.name for entry in root.iterdir() if entry.is_dir() and not entry.name.startswith("."))


def collect_files(root: Path) -> list[str]:
    if not root.is_dir():
        return []
    return sorted(str(path.relative_to(root)) for path in root.rglob("*") if path.is_file())


def compare_tree(src: Path, dst: Path) -> str:
    if not dst.exists():
        return "missing"
    if not dst.is_dir():
        return "differs"

    src_files = collect_files(src)
    dst_files = collect_files(dst)
    dst_set = set(dst_files)

    for rel in src_files:
        dst_file = dst / rel
        if rel not in dst_set or not dst_file.is_file():
            return "differs"
        if (src / rel).read_bytes() != dst_file.read_bytes():
            return "differs"

    extras = sorted(set(dst_files) - set(src_files))
    return "match+extras" if extras else "match"


def strip_wrapping_quotes(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def normalize_description(value: str) -> str:
    value = strip_wrapping_quotes(value.strip())
    return " ".join(value.split())


def truncate_text(value: str, width: int) -> str:
    if len(value) <= width:
        return value
    if width <= 3:
        return value[:width]
    return value[: width - 3].rstrip() + "..."


def parse_openai_short_description(meta_file: Path) -> str:
    if not meta_file.is_file():
        return ""

    for line in meta_file.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("short_description:"):
            return normalize_description(stripped.split(":", 1)[1])
    return ""


def parse_frontmatter_description(skill_file: Path) -> str:
    if not skill_file.is_file():
        return ""

    lines = skill_file.read_text(encoding="utf-8").splitlines()
    if len(lines) < 3 or lines[0].strip() != "---":
        return ""

    end_idx = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end_idx = idx
            break
    if end_idx is None:
        return ""

    desc_prefix = "description:"
    block_markers = {">", "|", ">-", "|-", ">+", "|+"}

    for idx in range(1, end_idx):
        stripped = lines[idx].strip()
        if not stripped.startswith(desc_prefix):
            continue

        value = stripped[len(desc_prefix) :].strip()
        if value and value not in block_markers:
            return normalize_description(value)

        block_lines: list[str] = []
        for follow in lines[idx + 1 : end_idx]:
            if re.match(r"^[A-Za-z0-9_-]+:\s*", follow):
                break
            if follow.startswith(" ") or follow.startswith("\t"):
                block_lines.append(follow.strip())
                continue
            break

        return normalize_description(" ".join(block_lines))

    return ""


def skill_description(skill_root: Path, skill: str, width: int) -> str:
    skill_dir = skill_root / skill
    description = parse_openai_short_description(skill_dir / "agents" / "openai.yaml")
    if not description and (SKILL_DIR / skill).is_dir():
        description = parse_openai_short_description(SKILL_DIR / skill / "agents" / "openai.yaml")
    if not description:
        description = parse_frontmatter_description(skill_dir / "SKILL.md")
    if not description and (SKILL_DIR / skill).is_dir():
        description = parse_frontmatter_description(SKILL_DIR / skill / "SKILL.md")
    if not description:
        description = "(no short description found)"
    return truncate_text(description, width)


def build_skill_rows(skill_root: Path, skills: list[str], width: int) -> list[list[str]]:
    return [[skill, skill_description(skill_root, skill, width)] for skill in skills]


def print_skill_table(title: str, skill_root: Path, skills: list[str], width: int = LIST_DESCRIPTION_WIDTH) -> None:
    print(title)
    if not skills:
        print("  (none)")
        return
    print_table(["skill", "summary"], build_skill_rows(skill_root, skills, width))


def build_status_rows() -> tuple[list[str], list[str], list[str], list[list[str]]]:
    repo_skills = load_skill_ids(SKILL_DIR)
    codex_installed = load_skill_ids(INSTALL_DIR)
    claude_installed = load_skill_ids(CLAUDE_INSTALL_DIR)
    rows: list[list[str]] = []

    for skill in repo_skills:
        codex_status = compare_tree(SKILL_DIR / skill, INSTALL_DIR / skill)
        claude_status = compare_tree(CLAUDE_SKILL_DIR / skill, CLAUDE_INSTALL_DIR / skill)
        rows.append([skill, codex_status, claude_status, skill_description(SKILL_DIR, skill, DASHBOARD_DESCRIPTION_WIDTH)])

    return repo_skills, codex_installed, claude_installed, rows


def print_table(headers: list[str], rows: list[list[str]]) -> None:
    widths = [len(header) for header in headers]
    for row in rows:
        for idx, value in enumerate(row):
            widths[idx] = max(widths[idx], len(value))

    header_line = "  ".join(header.ljust(widths[idx]) for idx, header in enumerate(headers))
    divider = "  ".join("-" * widths[idx] for idx in range(len(headers)))
    print(header_line)
    print(divider)
    for row in rows:
        print("  ".join(value.ljust(widths[idx]) for idx, value in enumerate(row)))


def print_skill_list(title: str, skills: list[str]) -> None:
    print(title)
    if not skills:
        print("  (none)")
        return
    for skill in skills:
        print(f"  {skill}")


def print_dashboard() -> None:
    repo_skills, codex_installed, claude_installed, rows = build_status_rows()
    codex_counts = Counter(row[1] for row in rows)
    claude_counts = Counter(row[2] for row in rows)
    codex_only = sorted(set(codex_installed) - set(repo_skills))
    claude_only = sorted(set(claude_installed) - set(repo_skills))

    print("cliskills dashboard")
    print(f"Repository root:      {REPO_ROOT}")
    print(f"Codex source dir:     {SKILL_DIR}")
    print(f"Claude mirror dir:    {CLAUDE_SKILL_DIR}")
    print(f"Codex install dir:    {INSTALL_DIR}")
    print(f"Claude install dir:   {CLAUDE_INSTALL_DIR}")
    print(f"Default install mode: {INSTALL_MODE}")
    print()
    print(
        f"Bundled repo skills: {len(repo_skills)} | "
        f"Codex installed dirs: {len(codex_installed)} | "
        f"Claude installed dirs: {len(claude_installed)}"
    )
    print(
        "Codex status: "
        + ", ".join(f"{label}={codex_counts.get(label, 0)}" for label in STATUS_LABELS)
    )
    print(
        "Claude status: "
        + ", ".join(f"{label}={claude_counts.get(label, 0)}" for label in STATUS_LABELS)
    )
    print()
    print_table(["skill", "codex", "claude", "summary"], rows)
    print()
    print_skill_list("Installed-only Codex skills:", codex_only)
    print()
    print_skill_list("Installed-only Claude skills:", claude_only)


def print_dashboard_help() -> None:
    print("Dashboard actions")
    print("  show                 show repo/install status summary")
    print("  list-repo            list bundled repository skills")
    print("  list-codex           list installed Codex skills from the current install dir")
    print("  list-claude          list installed Claude skills from the current install dir")
    print("  install-codex-skill  install or update one repo skill into Codex")
    print("  install-claude-skill install or update one mirrored skill into Claude")
    print("  install-codex-all    install or update all repo skills into Codex")
    print("  install-claude-all   install or update all mirrored skills into Claude")
    print("  validate-skill       validate one skill and its Claude mirror")
    print("  validate-all         run full repository validation")
    print("  sync-claude          refresh the Claude mirror from the repo source tree")
    print("  help                 show this dashboard help")
    print()
    print("Core make targets")
    print("  make help")
    print("  make info")
    print("  make list")
    print("  make list-claude")
    print("  make list LIST_FORMAT=ids")
    print("  make validate")
    print("  make validate-skill SKILL=<id>")
    print("  make install INSTALL_MODE=fail|overwrite|keep")
    print("  make install-skill SKILL=<id>")
    print("  make install-claude")
    print("  make install-claude-skill SKILL=<id>")
    print("  make dashboard ACTION=<action> [SKILL=<id>] [INSTALL_MODE=fail|overwrite|keep]")


def run_make(target: str, extra_vars: dict[str, str] | None = None) -> int:
    command = [*shlex.split(MAKE_BIN), target]
    forwarded = {
        "INSTALL_MODE": INSTALL_MODE,
        "INSTALL_DIR": str(INSTALL_DIR),
        "CLAUDE_INSTALL_DIR": str(CLAUDE_INSTALL_DIR),
        "SKILL_DIR": str(SKILL_DIR),
        "CLAUDE_SKILL_DIR": str(CLAUDE_SKILL_DIR),
        "LIST_FORMAT": LIST_FORMAT,
    }
    if extra_vars:
        forwarded.update(extra_vars)

    for key, value in forwarded.items():
        command.append(f"{key}={value}")

    print(f"$ {' '.join(shlex.quote(part) for part in command)}", flush=True)
    completed = subprocess.run(command, cwd=REPO_ROOT, check=False)
    return completed.returncode


def require_skill(skill: str) -> str:
    if not skill:
        raise ValueError("This action requires SKILL=<skill-id>.")
    if not (SKILL_DIR / skill).is_dir():
        raise ValueError(f"Unknown repository skill: {skill}")
    return skill


def require_mode(mode: str) -> str:
    if mode not in VALID_MODES:
        raise ValueError(f"Unknown INSTALL_MODE: {mode}")
    return mode


def require_list_format(list_format: str) -> str:
    if list_format not in VALID_LIST_FORMATS:
        raise ValueError(f"Unknown LIST_FORMAT: {list_format}")
    return list_format


def print_skill_output(title: str, skill_root: Path, skills: list[str], list_format: str) -> None:
    if list_format == "ids":
        for skill in skills:
            print(skill)
        return
    print_skill_table(title, skill_root, skills)


def handle_action(action: str, skill: str, install_mode: str) -> int:
    require_mode(install_mode)
    require_list_format(LIST_FORMAT)

    if action in {"", "show"}:
        print_dashboard()
        return 0
    if action == "list-repo":
        print_skill_output("Bundled repository skills:", SKILL_DIR, load_skill_ids(SKILL_DIR), LIST_FORMAT)
        return 0
    if action == "list-claude-mirror":
        print_skill_output("Bundled Claude mirror skills:", CLAUDE_SKILL_DIR, load_skill_ids(CLAUDE_SKILL_DIR), LIST_FORMAT)
        return 0
    if action == "list-codex":
        print_skill_output(
            f"Installed Codex skills from {INSTALL_DIR}:",
            INSTALL_DIR,
            load_skill_ids(INSTALL_DIR),
            LIST_FORMAT,
        )
        return 0
    if action == "list-claude":
        print_skill_output(
            f"Installed Claude skills from {CLAUDE_INSTALL_DIR}:",
            CLAUDE_INSTALL_DIR,
            load_skill_ids(CLAUDE_INSTALL_DIR),
            LIST_FORMAT,
        )
        return 0
    if action == "help":
        print_dashboard_help()
        return 0
    if action == "sync-claude":
        return run_make("sync-claude")
    if action == "validate-all":
        return run_make("validate-all")
    if action == "validate-skill":
        return run_make("validate-skill", {"SKILL": require_skill(skill)})
    if action == "install-codex-skill":
        return run_make(
            "install-skill",
            {"SKILL": require_skill(skill), "INSTALL_MODE": install_mode},
        )
    if action == "install-claude-skill":
        return run_make(
            "install-claude-skill",
            {"SKILL": require_skill(skill), "INSTALL_MODE": install_mode},
        )
    if action == "install-codex-all":
        return run_make("install", {"INSTALL_MODE": install_mode})
    if action == "install-claude-all":
        return run_make("install-claude", {"INSTALL_MODE": install_mode})

    raise ValueError(f"Unknown ACTION={action!r}. Use ACTION=help to see supported values.")


def prompt(prompt_text: str) -> str:
    try:
        return input(prompt_text).strip()
    except EOFError:
        return ""


def prompt_skill() -> str | None:
    skill = prompt("Skill id (blank to cancel): ")
    if not skill:
        return None
    if not (SKILL_DIR / skill).is_dir():
        print(f"Unknown repository skill: {skill}")
        return None
    return skill


def prompt_mode(default_mode: str) -> str:
    mode = prompt(f"Install mode [fail/overwrite/keep] (default {default_mode}): ")
    mode = mode or default_mode
    if mode not in VALID_MODES:
        print(f"Unknown install mode: {mode}")
        return default_mode
    return mode


def interactive_loop() -> int:
    while True:
        print()
        print("Menu")
        print("  1. Refresh dashboard")
        print("  2. List bundled repository skills")
        print("  3. List installed Codex skills")
        print("  4. List installed Claude skills")
        print("  5. Install or update one Codex skill")
        print("  6. Install or update one Claude skill")
        print("  7. Install or update all Codex skills")
        print("  8. Install or update all Claude skills")
        print("  9. Sync Claude mirror")
        print(" 10. Validate one skill")
        print(" 11. Validate all")
        print(" 12. Help")
        print("  q. Quit")
        choice = prompt("Select: ").lower()

        if choice in {"q", "quit", "0"}:
            return 0
        if choice == "1":
            print()
            print_dashboard()
            continue
        if choice == "2":
            print()
            print_skill_table("Bundled repository skills:", SKILL_DIR, load_skill_ids(SKILL_DIR))
            continue
        if choice == "3":
            print()
            print_skill_table(f"Installed Codex skills from {INSTALL_DIR}:", INSTALL_DIR, load_skill_ids(INSTALL_DIR))
            continue
        if choice == "4":
            print()
            print_skill_table(
                f"Installed Claude skills from {CLAUDE_INSTALL_DIR}:",
                CLAUDE_INSTALL_DIR,
                load_skill_ids(CLAUDE_INSTALL_DIR),
            )
            continue
        if choice == "5":
            skill = prompt_skill()
            if skill:
                print()
                run_make("install-skill", {"SKILL": skill, "INSTALL_MODE": prompt_mode(INSTALL_MODE)})
            continue
        if choice == "6":
            skill = prompt_skill()
            if skill:
                print()
                run_make("install-claude-skill", {"SKILL": skill, "INSTALL_MODE": prompt_mode(INSTALL_MODE)})
            continue
        if choice == "7":
            print()
            run_make("install", {"INSTALL_MODE": prompt_mode(INSTALL_MODE)})
            continue
        if choice == "8":
            print()
            run_make("install-claude", {"INSTALL_MODE": prompt_mode(INSTALL_MODE)})
            continue
        if choice == "9":
            print()
            run_make("sync-claude")
            continue
        if choice == "10":
            skill = prompt_skill()
            if skill:
                print()
                run_make("validate-skill", {"SKILL": skill})
            continue
        if choice == "11":
            print()
            run_make("validate-all")
            continue
        if choice == "12":
            print()
            print_dashboard_help()
            continue

        print(f"Unknown selection: {choice}")


def main() -> int:
    try:
        if ACTION:
            return handle_action(ACTION, SKILL, INSTALL_MODE)

        print_dashboard()
        if sys.stdin.isatty() and sys.stdout.isatty():
            return interactive_loop()

        print()
        print_dashboard_help()
        return 0
    except KeyboardInterrupt:
        print("\nInterrupted.")
        return 130
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
