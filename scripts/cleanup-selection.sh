#!/usr/bin/env bash
# craftsman-ignore: SH002 — Functions are phase-specific cleanup routines, self-contained by design.
# Cleanup unselected assets after a user decision in the brand pipeline.
# Called by the LLM after the user picks a direction, logo variant, 3D render, etc.
#
# Usage:
#   bash scripts/cleanup-selection.sh --phase <phase> --selected <selection> --project-dir <path> [--confirm]
#
# Phases:
#   direction  — User picked a brand direction (1, 2, 3...)
#   logo       — User picked logo variants to keep (comma-separated basenames)
#   3d         — User picked 3D renders to keep (comma-separated basenames)
#   carousel   — Cleanup draft carousel assets
#
# Examples:
#   bash scripts/cleanup-selection.sh --phase direction --selected 2 --project-dir ./my-brand
#   bash scripts/cleanup-selection.sh --phase logo --selected "icon-flat-dark,lockup-dark" --project-dir ./my-brand --confirm

set -euo pipefail

PHASE=""
SELECTED=""
PROJECT_DIR=""
CONFIRM=false

# Protected files that must never be deleted
PROTECTED_FILES="brand.json brand-tokens.css tailwind.preset.ts README.md"

usage() {
  head -16 "$0" | tail -14 | sed 's/^# \?//'
  exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase) PHASE="$2"; shift 2 ;;
    --selected) SELECTED="$2"; shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --confirm) CONFIRM=true; shift ;;
    --help|-h) usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Validate required args
if [[ -z "$PHASE" ]]; then
  echo "Error: --phase is required." >&2
  exit 1
fi
if [[ -z "$SELECTED" ]]; then
  echo "Error: --selected is required." >&2
  exit 1
fi
if [[ -z "$PROJECT_DIR" ]]; then
  echo "Error: --project-dir is required." >&2
  exit 1
fi

# Resolve to absolute path and verify it exists
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
  echo "Error: project directory does not exist: $PROJECT_DIR" >&2
  exit 1
}

# Safety: never delete outside the project directory
assert_inside_project() {
  local path="$1"
  local resolved
  resolved="$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path")"
  case "$resolved" in
    "$PROJECT_DIR"*) return 0 ;;
    *) echo "Error: refusing to delete outside project dir: $resolved" >&2; exit 1 ;;
  esac
}

# Check if a filename is protected
is_protected() {
  local basename
  basename="$(basename "$1")"
  for pf in $PROTECTED_FILES; do
    if [[ "$basename" == "$pf" ]]; then
      return 0
    fi
  done
  return 1
}

# Collect files/dirs to delete into DELETE_LIST array
# Each entry: "path|file_count|size_kb"
DELETE_LIST=()

# Calculate size of a path in KB
path_size_kb() {
  local path="$1"
  if [[ -d "$path" ]]; then
    du -sk "$path" 2>/dev/null | cut -f1
  elif [[ -f "$path" ]]; then
    local bytes
    bytes=$(stat -f%z "$path" 2>/dev/null || stat --printf="%s" "$path" 2>/dev/null || echo "0")
    echo $(( (bytes + 1023) / 1024 ))
  else
    echo "0"
  fi
}

# Count files in a path
path_file_count() {
  local path="$1"
  if [[ -d "$path" ]]; then
    find "$path" -type f 2>/dev/null | wc -l | tr -d ' '
  elif [[ -f "$path" ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# Add a path to the delete list (with safety checks)
queue_delete() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    return
  fi
  assert_inside_project "$path"
  if is_protected "$path"; then
    return
  fi
  local count
  count=$(path_file_count "$path")
  local size
  size=$(path_size_kb "$path")
  DELETE_LIST+=("$path|$count|$size")
}

# Extract the selected number from "Direction 2" or just "2"
extract_number() {
  local input="$1"
  echo "$input" | grep -oE '[0-9]+' | head -1
}

# Split comma-separated list into an array (bash 3.2 compatible)
split_csv() {
  local input="$1"
  local IFS=','
  read -ra RESULT <<< "$input"
  echo "${RESULT[@]}"
}

# Check if a value is in a space-separated list
in_list() {
  local needle="$1"
  shift
  for item in "$@"; do
    if [[ "$needle" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

# Phase: direction
cleanup_direction() {
  local num
  num=$(extract_number "$SELECTED")
  if [[ -z "$num" ]]; then
    echo "Error: could not extract direction number from '$SELECTED'" >&2
    exit 1
  fi

  local explore_dir="$PROJECT_DIR/brandbook-exploration"
  if [[ ! -d "$explore_dir" ]]; then
    echo "Error: brandbook-exploration/ not found in project directory." >&2
    exit 1
  fi

  # Queue unselected direction folders
  for dir in "$explore_dir"/direction-*/; do
    [[ -d "$dir" ]] || continue
    local dir_num
    dir_num=$(basename "$dir" | grep -oE '[0-9]+')
    if [[ "$dir_num" != "$num" ]]; then
      queue_delete "$dir"
    fi
  done

  # Queue preview HTML files
  for html_file in "$explore_dir"/directions-overview.html "$explore_dir"/direction-*-detail.html; do
    [[ -f "$html_file" ]] || continue
    queue_delete "$html_file"
  done
}

# Queue unselected PNGs in a logo directory
# Args: <directory> <keep_list...>
queue_unselected_logos() {
  local dir="$1"; shift
  local always_keep="construction-grid.svg icon.svg favicon.ico"

  for file in "$dir"/*.png; do
    [[ -f "$file" ]] || continue
    local basename_no_ext
    basename_no_ext="$(basename "$file" .png)"
    if in_list "$basename_no_ext" "$@"; then
      continue
    fi
    if in_list "$(basename "$file")" $always_keep; then
      continue
    fi
    queue_delete "$file"
  done
}

# Phase: logo
cleanup_logo() {
  local keep_list
  keep_list=$(split_csv "$SELECTED")

  local dirs_to_scan=(
    "$PROJECT_DIR/brandbook-final/assets/logo"
    "$PROJECT_DIR/branding/logos"
  )

  for dir in "${dirs_to_scan[@]}"; do
    [[ -d "$dir" ]] || continue
    queue_unselected_logos "$dir" $keep_list
  done
}

# Phase: 3d
cleanup_3d() {
  local keep_list
  keep_list=$(split_csv "$SELECTED")

  local dir_3d="$PROJECT_DIR/branding/3d"
  if [[ ! -d "$dir_3d" ]]; then
    echo "Error: branding/3d/ not found in project directory." >&2
    exit 1
  fi

  for file in "$dir_3d"/*; do
    [[ -f "$file" ]] || continue
    local basename_no_ext="${file##*/}"
    basename_no_ext="${basename_no_ext%.*}"

    if in_list "$basename_no_ext" $keep_list; then
      continue
    fi
    if is_protected "$file"; then
      continue
    fi
    queue_delete "$file"
  done
}

# Phase: carousel
cleanup_carousel() {
  local carousel_dir="$PROJECT_DIR/carousels"
  if [[ ! -d "$carousel_dir" ]]; then
    echo "Error: carousels/ not found in project directory." >&2
    exit 1
  fi

  # Delete draft files
  while IFS= read -r -d '' file; do
    queue_delete "$file"
  done < <(find "$carousel_dir" -name "*-draft*" -type f -print0 2>/dev/null)

  # Delete temporary folders (tmp*, temp*)
  while IFS= read -r -d '' dir; do
    queue_delete "$dir"
  done < <(find "$carousel_dir" -maxdepth 1 -type d \( -name "tmp*" -o -name "temp*" \) -print0 2>/dev/null)
}

# Run the appropriate phase
echo "[CLEANUP] Phase: $PHASE | Selected: $SELECTED"

case "$PHASE" in
  direction) cleanup_direction ;;
  logo)      cleanup_logo ;;
  3d)        cleanup_3d ;;
  carousel)  cleanup_carousel ;;
  *) echo "Error: unknown phase '$PHASE'. Valid: direction, logo, 3d, carousel" >&2; exit 1 ;;
esac

# Report what will be deleted
if [[ ${#DELETE_LIST[@]} -eq 0 ]]; then
  echo "[CLEANUP] Nothing to delete."
  exit 0
fi

TOTAL_FILES=0
TOTAL_KB=0

echo "[CLEANUP] Will delete:"
for entry in "${DELETE_LIST[@]}"; do
  IFS='|' read -r path count size <<< "$entry"
  local_path="${path#"$PROJECT_DIR/"}"
  if [[ -d "$path" ]]; then
    echo "  - $local_path ($count files, ${size}KB)"
  else
    echo "  - $local_path (${size}KB)"
  fi
  TOTAL_FILES=$((TOTAL_FILES + count))
  TOTAL_KB=$((TOTAL_KB + size))
done
echo "[CLEANUP] Total: $TOTAL_FILES files, ${TOTAL_KB}KB"

# Execute or prompt for confirmation
if [[ "$CONFIRM" != true ]]; then
  echo "[CLEANUP] Run with --confirm to execute deletion."
  exit 0
fi

# Actually delete
for entry in "${DELETE_LIST[@]}"; do
  IFS='|' read -r path _ _ <<< "$entry"
  if [[ -d "$path" ]]; then
    rm -rf "$path"
  elif [[ -f "$path" ]]; then
    rm -f "$path"
  fi
done

echo "[CLEANUP] Deleted $TOTAL_FILES files, freed ${TOTAL_KB}KB"

# Report remaining contents
case "$PHASE" in
  direction)
    remaining=$(ls "$PROJECT_DIR/brandbook-exploration/" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    echo "[CLEANUP] Remaining in brandbook-exploration/: $remaining"
    ;;
  logo)
    for dir in "$PROJECT_DIR/brandbook-final/assets/logo" "$PROJECT_DIR/branding/logos"; do
      if [[ -d "$dir" ]]; then
        local_dir="${dir#"$PROJECT_DIR/"}"
        remaining=$(ls "$dir" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
        echo "[CLEANUP] Remaining in $local_dir: $remaining"
      fi
    done
    ;;
  3d)
    remaining=$(ls "$PROJECT_DIR/branding/3d/" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    echo "[CLEANUP] Remaining in branding/3d/: $remaining"
    ;;
  carousel)
    remaining=$(ls "$PROJECT_DIR/carousels/" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    echo "[CLEANUP] Remaining in carousels/: $remaining"
    ;;
esac
