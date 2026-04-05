#!/usr/bin/env bash
# RAG Search — Query the creative knowledge database.
# Pure bash + sqlite3 (no Node dependency at search time).
#
# Usage:
#   bash scripts/search.sh <query> [options]
#
# Options:
#   --category <cat>   Filter by category (logo, grid, 3d, palette, typography, mockup, moodboard, ui, cover, icon, companion, poster)
#   --brand <name>     Filter by brand name
#   --step <step>      Filter by methodology step
#   --limit <n>        Max results (default: 5)
#   --db <path>        Database path (default: creative-rag.db)
#   --json             Output raw JSON instead of formatted text
#   --help             Show this help
#
# Examples:
#   bash scripts/search.sh "construction grid golden ratio"
#   bash scripts/search.sh "3D render frosted glass" --category 3d --limit 3
#   bash scripts/search.sh "typography specimen" --brand Daily

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DB_PATH="$ROOT_DIR/creative-rag.db"
QUERY=""
CATEGORY=""
BRAND=""
STEP=""
LIMIT=5
JSON_OUTPUT=false

usage() {
  head -19 "$0" | tail -17 | sed 's/^# \?//'
  exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --category) CATEGORY="$2"; shift 2 ;;
    --brand) BRAND="$2"; shift 2 ;;
    --step) STEP="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --db) DB_PATH="$2"; shift 2 ;;
    --json) JSON_OUTPUT=true; shift ;;
    --help|-h) usage ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) QUERY="$1"; shift ;;
  esac
done

if [[ -z "$QUERY" ]]; then
  echo "Error: No search query provided." >&2
  echo "Usage: bash scripts/search.sh <query> [--category <cat>] [--limit <n>]" >&2
  exit 1
fi

if [[ ! -f "$DB_PATH" ]]; then
  echo "Error: RAG database not found at $DB_PATH" >&2
  echo "Run 'npm run ingest' to create it." >&2
  exit 1
fi

if ! command -v sqlite3 &>/dev/null; then
  echo "Error: sqlite3 not found." >&2
  exit 1
fi

# Build WHERE clause for filters
FILTERS=""
if [[ -n "$CATEGORY" ]]; then
  FILTERS="$FILTERS AND p.category = '$CATEGORY'"
fi
if [[ -n "$BRAND" ]]; then
  FILTERS="$FILTERS AND p.brand_name LIKE '%$BRAND%'"
fi
if [[ -n "$STEP" ]]; then
  FILTERS="$FILTERS AND p.methodology_step = '$STEP'"
fi

# Escape single quotes in query for SQL
SAFE_QUERY="${QUERY//\'/\'\'}"

if [[ "$JSON_OUTPUT" == true ]]; then
  # JSON output mode
  sqlite3 -json "$DB_PATH" "
    SELECT p.id, p.source_file, p.page_number, p.category, p.brand_name,
           p.methodology_step, p.description, p.hex_colors, p.fonts_detected,
           p.grid_ratios, p.materials, p.quality_notes
    FROM pages_fts fts
    JOIN pages p ON p.id = fts.rowid
    WHERE pages_fts MATCH '$SAFE_QUERY'
    $FILTERS
    ORDER BY rank
    LIMIT $LIMIT;
  " 2>/dev/null
else
  # Formatted text output (readable by Claude)
  RESULTS=$(sqlite3 -separator '|' "$DB_PATH" "
    SELECT p.id, p.source_file, p.page_number, p.category, p.brand_name,
           p.methodology_step, p.description, p.hex_colors, p.materials, p.quality_notes
    FROM pages_fts fts
    JOIN pages p ON p.id = fts.rowid
    WHERE pages_fts MATCH '$SAFE_QUERY'
    $FILTERS
    ORDER BY rank
    LIMIT $LIMIT;
  " 2>/dev/null) || true

  if [[ -z "$RESULTS" ]]; then
    echo "No results for: $QUERY"
    if [[ -n "$CATEGORY" ]]; then echo "  (category filter: $CATEGORY)"; fi
    if [[ -n "$BRAND" ]]; then echo "  (brand filter: $BRAND)"; fi
    exit 0
  fi

  RESULT_NUM=0
  while IFS='|' read -r id source_file page_number category brand_name methodology_step description hex_colors materials quality_notes; do
    ((RESULT_NUM++))
    echo "[$RESULT_NUM] $brand_name — $category ($methodology_step)"
    echo "   Source: $source_file p.$page_number"
    echo "   Description: $description"
    if [[ -n "$hex_colors" && "$hex_colors" != "[]" ]]; then
      echo "   Colors: $hex_colors"
    fi
    if [[ -n "$materials" && "$materials" != "[]" ]]; then
      echo "   Materials: $materials"
    fi
    if [[ -n "$quality_notes" ]]; then
      echo "   Quality: $quality_notes"
    fi
    echo ""
  done <<< "$RESULTS"

  TOTAL=$(sqlite3 "$DB_PATH" "
    SELECT COUNT(*)
    FROM pages_fts fts
    JOIN pages p ON p.id = fts.rowid
    WHERE pages_fts MATCH '$SAFE_QUERY'
    $FILTERS;
  " 2>/dev/null || echo "?")

  echo "--- $RESULT_NUM of $TOTAL results (limit: $LIMIT) ---"
fi
