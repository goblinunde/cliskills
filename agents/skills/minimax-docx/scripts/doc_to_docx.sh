#!/usr/bin/env bash
set -euo pipefail

detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    printf '%s' "${ID:-linux}"
    return
  fi
  printf 'linux'
}

find_soffice() {
  local candidates=(
    "$(command -v soffice 2>/dev/null || true)"
    "$(command -v libreoffice 2>/dev/null || true)"
    "/usr/lib64/libreoffice/program/soffice"
    "/usr/lib/libreoffice/program/soffice"
    "/opt/libreoffice/program/soffice"
    "/Applications/LibreOffice.app/Contents/MacOS/soffice"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

usage() {
  echo "Usage: $(basename "$0") <file.doc> [output_directory]"
  echo "Convert .doc to .docx using LibreOffice."
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

INPUT="$1"
OUTDIR="${2:-.}"

if [ ! -f "$INPUT" ]; then
  echo "Error: File not found: $INPUT"
  exit 1
fi

SOFFICE_BIN="$(find_soffice || true)"
if [ -z "$SOFFICE_BIN" ]; then
  DISTRO_ID="$(detect_distro)"
  echo "Error: soffice (LibreOffice) is required for .doc conversion but not found."
  case "$DISTRO_ID" in
    fedora|rhel|centos|rocky|alma) echo "Install LibreOffice: sudo dnf install -y libreoffice" ;;
    ubuntu|debian|linuxmint|pop)  echo "Install LibreOffice: sudo apt-get install -y libreoffice" ;;
    *)                            echo "Install LibreOffice with your system package manager." ;;
  esac
  exit 1
fi

BASENAME=$(basename "$INPUT" .doc)
mkdir -p "$OUTDIR"

echo "Converting: $INPUT -> $OUTDIR/$BASENAME.docx"
"$SOFFICE_BIN" --headless --convert-to docx --outdir "$OUTDIR" "$INPUT" >/dev/null 2>&1

OUTPUT="$OUTDIR/$BASENAME.docx"
if [ ! -f "$OUTPUT" ]; then
  echo "Error: Conversion failed. Output file not created: $OUTPUT"
  exit 1
fi

echo "Success: $OUTPUT"
