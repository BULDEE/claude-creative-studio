#!/usr/bin/env bash
# RAG Multimodal Ingestion Pipeline
# Indexes brandbook PDFs and image folders into a SQLite FTS5 database.
#
# Usage:
#   bash scripts/ingest.sh [options] <source-path> [<source-path>...]
#
# Options:
#   --db <path>       Database path (default: creative-rag.db)
#   --resume          Skip already-indexed pages (default behavior)
#   --delay <seconds> Delay between Gemini calls (default: 2)
#   --help            Show this help
#
# Examples:
#   bash scripts/ingest.sh ~/Downloads/logo_master_brandbook/
#   bash scripts/ingest.sh ~/Downloads/brandbook_master/brandbook_complet_daily/
#   bash scripts/ingest.sh --delay 3 ~/Downloads/logo_master_brandbook/ ~/Downloads/brandbook_master/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DB_PATH="$ROOT_DIR/creative-rag.db"
DELAY=2
SOURCES=()
RAG_PAGES_DIR="$ROOT_DIR/.rag-pages"

# Folder name → category mapping (bash 3.2 compatible, no declare -A)
folder_to_category() {
  local name="$1"
  case "$name" in
    *[Aa]ffiche*) echo "poster" ;;
    *[Bb]rand*[Bb]ook*|*[Gg]uideline*|*[Vv]isuel*) echo "brandbook" ;;
    *[Cc]ompanion*) echo "companion" ;;
    *UI*|*ui*) echo "ui" ;;
    *[Ii]con*) echo "icon" ;;
    *[Ll]ogo*|*LOGO*|*[Ff]ichiers*source*) echo "logo" ;;
    *[Tt]ypographi*|*[Ff]ont*) echo "typography" ;;
    *commentaire*|*[Cc]ommentaire*) echo "commentary" ;;
    *[Mm]oodboard*) echo "moodboard" ;;
    *[Bb]rief*) echo "brief" ;;
    *) echo "other" ;;
  esac
}

usage() {
  head -17 "$0" | tail -15 | sed 's/^# \?//'
  exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --db) DB_PATH="$2"; shift 2 ;;
    --resume) shift ;; # Default behavior, kept for compat
    --delay) DELAY="$2"; shift 2 ;;
    --help|-h) usage ;;
    *) SOURCES+=("$1"); shift ;;
  esac
done

if [[ ${#SOURCES[@]} -eq 0 ]]; then
  echo "Error: No source paths provided." >&2
  echo "Usage: bash scripts/ingest.sh <source-path> [<source-path>...]" >&2
  exit 1
fi

# Dependency checks
check_dep() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 not found. $2" >&2
    exit 1
  fi
}

check_dep "node" "Install Node.js 18+"
check_dep "sqlite3" "Install SQLite3"

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "Error: GEMINI_API_KEY not set. Run: /claude-creative-studio:setup-provider" >&2
  exit 1
fi

# Check node_modules
if [[ ! -d "$ROOT_DIR/node_modules" ]]; then
  echo "Installing dependencies..."
  (cd "$ROOT_DIR" && npm install)
fi

mkdir -p "$RAG_PAGES_DIR"

TOTAL_PROCESSED=0
TOTAL_STORED=0
TOTAL_SKIPPED=0
TOTAL_ERRORS=0

# craftsman-ignore: SH002 — shell orchestration functions are procedural by nature; each has a single responsibility
# process_image: describe + store one image. process_pdf: extract + loop pages. process_folder: walk + loop images.

process_image() {
  local image_path="$1"
  local source_name="$2"
  local page_num="$3"
  local category_hint="${4:-}"

  # Describe with Gemini Vision
  local description
  description=$(node "$SCRIPT_DIR/lib/describe-page.mjs" "$image_path" 2>/dev/null) || {
    local exit_code=$?
    if [[ $exit_code -eq 2 ]]; then
      echo "    Rate limited, waiting 10s..." >&2
      sleep 10
      description=$(node "$SCRIPT_DIR/lib/describe-page.mjs" "$image_path" 2>/dev/null) || {
        echo "    Failed after retry: $image_path" >&2
        ((TOTAL_ERRORS++)) || true
        return
      }
    else
      echo "    Failed: $image_path" >&2
      ((TOTAL_ERRORS++)) || true
      return
    fi
  }

  # Store in database
  local store_args=(--db "$DB_PATH" --source-file "$source_name" --page-number "$page_num" --image-path "$image_path")
  local result
  result=$(echo "$description" | node "$SCRIPT_DIR/lib/embed-store.mjs" "${store_args[@]}" 2>/dev/null) || {
    echo "    Store failed: $image_path" >&2
    ((TOTAL_ERRORS++)) || true
    return
  }

  if [[ "$result" == *"Skipped"* ]]; then
    ((TOTAL_SKIPPED++)) || true
  else
    ((TOTAL_STORED++)) || true
  fi
  ((TOTAL_PROCESSED++)) || true

  echo "    $result"
  sleep "$DELAY"
}

# Infer brand name from path
infer_brand_name() {
  local dir_path="$1"
  local basename
  basename=$(basename "$dir_path")

  # Try to extract brand name from common patterns
  if [[ "$basename" == *"daily"* || "$basename" == *"Daily"* ]]; then echo "Daily"
  elif [[ "$basename" == *"unia"* || "$basename" == *"UNIA"* ]]; then echo "UNIA"
  elif [[ "$basename" == *"thelab"* || "$basename" == *"TheLab"* ]]; then echo "TheLab"
  else echo "$basename"
  fi
}

# Infer category from folder name (uses folder_to_category function)
infer_category() {
  folder_to_category "$1"
}

# Process PDF files
process_pdf() {
  local pdf_path="$1"
  local pdf_name
  pdf_name=$(basename "$pdf_path")
  local extract_dir="$RAG_PAGES_DIR/${pdf_name%.pdf}"

  echo "  Extracting pages..."

  # Check if pdftoppm is available
  if ! command -v pdftoppm &>/dev/null; then
    echo "  Warning: pdftoppm not found. Install with: brew install poppler" >&2
    echo "  Skipping PDF: $pdf_name" >&2
    return
  fi

  local extract_result
  extract_result=$(bash "$SCRIPT_DIR/lib/extract-pages.sh" "$pdf_path" "$extract_dir" 2>/dev/null) || {
    echo "  Failed to extract: $pdf_name" >&2
    ((TOTAL_ERRORS++)) || true
    return
  }

  local page_count
  page_count=$(echo "$extract_result" | grep -o '"pages": [0-9]*' | grep -o '[0-9]*')
  echo "  Extracted $page_count pages"

  local page_num=1
  for page_img in "$extract_dir"/page-*.png; do
    [[ -f "$page_img" ]] || continue
    echo "  [$page_num/$page_count] $(basename "$page_img")"
    process_image "$page_img" "$pdf_name" "$page_num"
    ((page_num++))
  done
}

# Process image folder (brandbook_master structure)
process_folder() {
  local folder_path="$1"
  local brand_name
  brand_name=$(infer_brand_name "$folder_path")
  local source_name
  source_name=$(basename "$folder_path")

  echo "  Brand: $brand_name"

  local page_num=1
  # Walk all image files recursively, sorted
  while IFS= read -r -d '' img_file; do
    # Get parent folder for category hint
    local parent_dir
    parent_dir=$(basename "$(dirname "$img_file")")
    local category
    category=$(infer_category "$parent_dir")

    local ext="${img_file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    # Skip non-image files
    case "$ext" in
      png|jpg|jpeg|webp) ;;
      *) continue ;;
    esac

    echo "  [$page_num] $(basename "$img_file") [$category]"
    process_image "$img_file" "$source_name" "$page_num" "$category"
    ((page_num++))
  done < <(find "$folder_path" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 | sort -z)
}

echo "=== RAG Multimodal Ingestion ==="
echo "Database: $DB_PATH"
echo "Delay: ${DELAY}s between calls"
echo ""

SOURCE_NUM=0
SOURCE_TOTAL=${#SOURCES[@]}

for source in "${SOURCES[@]}"; do
  ((SOURCE_NUM++))
  echo "[$SOURCE_NUM/$SOURCE_TOTAL] Processing: $source"

  if [[ -f "$source" && "$source" == *.pdf ]]; then
    # Single PDF file
    process_pdf "$source"

  elif [[ -d "$source" ]]; then
    # Directory: check if it contains PDFs or is a brandbook folder
    pdf_count=$(find "$source" -maxdepth 1 -name "*.pdf" -type f 2>/dev/null | wc -l | tr -d ' ')

    if [[ $pdf_count -gt 0 ]]; then
      # Directory of PDFs (logo_master_brandbook)
      local_num=0
      for pdf in "$source"/*.pdf; do
        [[ -f "$pdf" ]] || continue
        ((local_num++))
        echo ""
        echo "  [$local_num/$pdf_count] $(basename "$pdf")"
        process_pdf "$pdf"
      done
    else
      # Brandbook folder with images (brandbook_master/*)
      process_folder "$source"
    fi

  else
    echo "  Warning: $source is not a valid file or directory, skipping" >&2
  fi

  echo ""
done

echo "=== Ingestion Complete ==="
echo "Processed: $TOTAL_PROCESSED"
echo "Stored: $TOTAL_STORED"
echo "Skipped (existing): $TOTAL_SKIPPED"
echo "Errors: $TOTAL_ERRORS"

if [[ -f "$DB_PATH" ]]; then
  TOTAL_DB=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM pages;" 2>/dev/null || echo "?")
  echo "Total pages in DB: $TOTAL_DB"
fi
