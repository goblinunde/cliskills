#!/bin/sh
set -eu

mode="${1:-all}"

case "$mode" in
  source|repack|repack-deb|repack-binary|all)
    ;;
  *)
    echo "Usage: $0 [source|repack|repack-deb|repack-binary|all]" >&2
    exit 2
    ;;
esac

missing_core=0
cwd="$(pwd)"

say() {
  printf '%s\n' "$1"
}

check_present() {
  tool="$1"
  label="$2"
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'ok: %s -> %s\n' "$label" "$(command -v "$tool")"
  else
    printf 'missing: %s\n' "$label"
    missing_core=1
  fi
}

check_optional() {
  tool="$1"
  label="$2"
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'optional-ok: %s -> %s\n' "$label" "$(command -v "$tool")"
  else
    printf 'optional-missing: %s\n' "$label"
  fi
}

check_any() {
  label="$1"
  shift
  for tool in "$@"; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf 'ok: %s -> %s\n' "$label" "$(command -v "$tool")"
      return 0
    fi
  done
  printf 'missing: %s\n' "$label"
  missing_core=1
}

say "cwd: $cwd"
if [ -f /etc/os-release ]; then
  say "os-release:"
  sed 's/^/  /' /etc/os-release
fi
say "arch: $(uname -m)"

if command -v rpm >/dev/null 2>&1; then
  say "rpm-arch: $(rpm --eval '%{_arch}')"
  say "rpm-topdir: $(rpm --eval '%{_topdir}')"
fi

say "mode: $mode"
say "core checks:"
check_present rpm "rpm"
check_present rpmbuild "rpmbuild"
check_present rpmspec "rpmspec"

case "$mode" in
  source|all)
    check_present git "git"
    check_any "compiler (gcc or cc)" gcc cc
    check_present make "make"
    check_present patch "patch"
    check_optional rpmdev-setuptree "rpmdev-setuptree"
    check_optional spectool "spectool"
    check_optional rpmlint "rpmlint"
    ;;
esac

case "$mode" in
  repack|repack-binary|all)
    check_present tar "tar"
    check_optional cpio "cpio"
    check_optional fpm "fpm"
    check_optional rpmlint "rpmlint"
    ;;
esac

case "$mode" in
  repack-deb|all)
    check_present tar "tar"
    check_any "deb repack helper (dpkg-deb, alien, or fpm)" dpkg-deb alien fpm
    check_optional cpio "cpio"
    check_optional dpkg-deb "dpkg-deb"
    check_optional alien "alien"
    check_optional fpm "fpm"
    check_optional rpmlint "rpmlint"
    ;;
esac

if [ "$missing_core" -ne 0 ]; then
  say "result: missing required core tooling"
  exit 1
fi

case "$mode" in
  repack)
    say "note: use repack-deb for .deb-specific checks and repack-binary for archive-specific checks"
    ;;
esac

say "result: core tooling present"
