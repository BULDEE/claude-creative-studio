#!/usr/bin/env bash
# Extract pages from a PDF as PNG images using pdftoppm.
# Usage: extract-pages.sh <pdf-path> <output-dir>
# Output: JSON {"pages": N, "output_dir": "..."}

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <pdf-path> <output-dir>" >&2
  exit 1
fi

PDF_PATH="$1"
OUTPUT_DIR="$2"

if [[ ! -f "$PDF_PATH" ]]; then
  echo "Error: PDF not found: $PDF_PATH" >&2
  exit 1
fi

if ! command -v pdftoppm &>/dev/null; then
  echo "Error: pdftoppm not found. Install with: brew install poppler" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

pdftoppm -png -r 200 "$PDF_PATH" "$OUTPUT_DIR/page"

PAGE_COUNT=$(find "$OUTPUT_DIR" -name "page-*.png" -type f | wc -l | tr -d ' ')

echo "{\"pages\": $PAGE_COUNT, \"output_dir\": \"$OUTPUT_DIR\"}"
