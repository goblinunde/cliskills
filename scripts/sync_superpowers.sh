#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=${REPO_ROOT:-$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)}
LOCK_FILE=${LOCK_FILE:-"$REPO_ROOT/vendor/superpowers.lock"}
SUPERPOWERS_SOURCE_DIR=${SUPERPOWERS_SOURCE_DIR:-}
SUPERPOWERS_UPSTREAM_COMMIT=${SUPERPOWERS_UPSTREAM_COMMIT:-}
SUPERPOWERS_SKIP_LOCK_UPDATE=${SUPERPOWERS_SKIP_LOCK_UPDATE:-0}

if [[ ! -f "$LOCK_FILE" ]]; then
  echo "Missing lock file: $LOCK_FILE" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$LOCK_FILE"

if [[ -z "${SUPERPOWERS_SKILLS:-}" ]]; then
  echo "No SUPERPOWERS_SKILLS configured in $LOCK_FILE" >&2
  exit 1
fi

mapfile -t SKILLS < <(printf '%s\n' "$SUPERPOWERS_SKILLS" | sed '/^[[:space:]]*$/d')

cleanup() {
  if [[ -n "${TMPDIR_CREATED:-}" && -d "$TMPDIR_CREATED" ]]; then
    rm -rf "$TMPDIR_CREATED"
  fi
}
trap cleanup EXIT

if [[ -n "$SUPERPOWERS_SOURCE_DIR" ]]; then
  SRC_ROOT=$SUPERPOWERS_SOURCE_DIR
  UPSTREAM_SHA=${SUPERPOWERS_UPSTREAM_COMMIT:-local-source}
  echo "Using local superpowers source: $SRC_ROOT"
else
  TMPDIR_CREATED=$(mktemp -d)
  SRC_ROOT="$TMPDIR_CREATED/upstream/skills"
  echo "Cloning $UPSTREAM_REPO#$UPSTREAM_REF"
  git clone --depth 1 --branch "$UPSTREAM_REF" "$UPSTREAM_REPO" "$TMPDIR_CREATED/upstream" >/dev/null
  UPSTREAM_SHA=$(git -C "$TMPDIR_CREATED/upstream" rev-parse HEAD)
fi

if [[ ! -d "$SRC_ROOT" ]]; then
  echo "Missing upstream skill directory: $SRC_ROOT" >&2
  exit 1
fi

for skill in "${SKILLS[@]}"; do
  src_skill="$SRC_ROOT/$skill"
  dst_skill="$REPO_ROOT/agents/skills/$skill"

  [[ -f "$src_skill/SKILL.md" ]] || { echo "Missing upstream SKILL.md for $skill" >&2; exit 1; }
  [[ -d "$dst_skill" ]] || { echo "Missing local skill directory for $skill" >&2; exit 1; }
  [[ -f "$dst_skill/agents/openai.yaml" ]] || { echo "Missing local metadata for $skill" >&2; exit 1; }

  cp "$src_skill/SKILL.md" "$dst_skill/SKILL.md"
  echo "Updated $skill/SKILL.md"
done

if [[ "$SUPERPOWERS_SKIP_LOCK_UPDATE" != "1" ]]; then
  SYNCED_AT_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  {
    echo '# Managed by scripts/sync_superpowers.sh.'
    echo '# Only the allowlisted skills below are synchronized from upstream.'
    printf 'UPSTREAM_REPO="%s"\n' "$UPSTREAM_REPO"
    printf 'UPSTREAM_REF="%s"\n' "$UPSTREAM_REF"
    printf 'UPSTREAM_COMMIT="%s"\n' "$UPSTREAM_SHA"
    printf 'SYNCED_AT="%s"\n' "$SYNCED_AT_UTC"
    echo 'SUPERPOWERS_SKILLS="'
    printf '%s\n' "${SKILLS[@]}"
    echo '"'
  } > "$LOCK_FILE"
  echo "Updated $LOCK_FILE"
fi

make -C "$REPO_ROOT" sync-claude
make -C "$REPO_ROOT" validate-all
