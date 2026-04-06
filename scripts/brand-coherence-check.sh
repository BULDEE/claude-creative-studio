#!/usr/bin/env bash
# craftsman-ignore: SH002 — Check functions are self-contained quality gates, one per validation concern.
# Brand Coherence Check — Validate branding assets against brand.json.
# Quality gate to run before declaring branding complete.
#
# Usage:
#   bash scripts/brand-coherence-check.sh --brand /path/to/brand.json --branding-dir /path/to/branding/
#
# Options:
#   --brand <path>        Path to brand.json
#   --branding-dir <path> Path to branding/ directory
#   --help                Show this help
#
# Exit code: 0 if no errors, 1 if any errors found.

set -euo pipefail

BRAND_JSON=""
BRANDING_DIR=""

PASS=0
WARN=0
FAIL=0

usage() {
  head -14 "$0" | tail -12 | sed 's/^# \?//'
  exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --brand) BRAND_JSON="$2"; shift 2 ;;
    --branding-dir) BRANDING_DIR="$2"; shift 2 ;;
    --help|-h) usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$BRAND_JSON" ]]; then
  echo "Error: --brand is required." >&2; exit 1
fi
if [[ -z "$BRANDING_DIR" ]]; then
  echo "Error: --branding-dir is required." >&2; exit 1
fi
if [[ ! -f "$BRAND_JSON" ]]; then
  echo "Error: brand.json not found at $BRAND_JSON" >&2; exit 1
fi
if [[ ! -d "$BRANDING_DIR" ]]; then
  echo "Error: branding directory not found at $BRANDING_DIR" >&2; exit 1
fi

# JSON value extraction (jq preferred, grep fallback)
HAS_JQ=false
if command -v jq &>/dev/null; then
  HAS_JQ=true
fi

json_get() {
  local json_file="$1"
  local jq_path="$2"
  local grep_pattern="$3"

  if [[ "$HAS_JQ" == true ]]; then
    jq -r "$jq_path" "$json_file" 2>/dev/null || echo ""
  else
    grep -oE "$grep_pattern" "$json_file" | head -1 | sed 's/.*: *"//;s/".*//' || echo ""
  fi
}

report_pass() {
  echo "[COHERENCE] + $1"
  ((PASS++)) || true
}

report_warn() {
  echo "[COHERENCE] ? $1"
  ((WARN++)) || true
}

report_fail() {
  echo "[COHERENCE] x $1"
  ((FAIL++)) || true
}

# Lowercase a hex color for comparison
lc_hex() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

echo "[COHERENCE] Checking branding/ against brand.json..."

# Read brand.json values used by multiple checks
BRAND_PRIMARY=$(json_get "$BRAND_JSON" '.colors.primary.hex' '"primary".*"hex": *"[^"]*"')
BRAND_PRIMARY=$(lc_hex "$BRAND_PRIMARY")
BRAND_FONT=$(json_get "$BRAND_JSON" '.typography.display.family' '"display".*"family": *"[^"]*"')
BRAND_NAME=$(json_get "$BRAND_JSON" '.name' '"name": *"[^"]*"')

# Expected branding files list
EXPECTED_FILES=(
  "brand.json" "brand-tokens.css" "tailwind.preset.ts" "README.md"
  "logos/icon-flat-dark.png" "logos/icon-flat-light.png"
  "logos/icon-mono-black.png" "logos/icon-mono-white.png"
  "logos/lockup-dark.png" "logos/lockup-light.png"
  "logos/app-icon-ios.png" "logos/app-icon-chrome.png" "logos/favicon.ico"
  "social/og-image-1200x630.png" "social/avatar-square-512.png"
)

# Count present files and collect missing ones into MISSING array
count_expected_files() {
  FOUND_COUNT=0
  MISSING=()
  for f in "${EXPECTED_FILES[@]}"; do
    if [[ -f "$BRANDING_DIR/$f" ]]; then
      ((FOUND_COUNT++)) || true
    else
      MISSING+=("$f")
    fi
  done
}

# Check 3d renders and DA HTML, append to MISSING if absent
count_special_assets() {
  local renders=0
  if [[ -d "$BRANDING_DIR/3d" ]]; then
    renders=$(find "$BRANDING_DIR/3d" -type f 2>/dev/null | wc -l | tr -d ' ')
  fi
  if [[ $renders -ge 2 ]]; then
    ((FOUND_COUNT++)) || true
  else
    MISSING+=("3d/ (need >= 2 renders, found $renders)")
  fi

  local da_count
  da_count=$(find "$BRANDING_DIR" -maxdepth 1 -name "the-*.html" -type f 2>/dev/null | wc -l | tr -d ' ')
  if [[ $da_count -ge 1 ]]; then
    ((FOUND_COUNT++)) || true
  else
    MISSING+=("the-*.html (DA file)")
  fi
}

# --- Check 1: File completeness ---
check_file_completeness() {
  count_expected_files
  count_special_assets
  local total=$(( ${#EXPECTED_FILES[@]} + 2 ))

  if [[ ${#MISSING[@]} -eq 0 ]]; then
    report_pass "File completeness: $FOUND_COUNT/$total files present"
  else
    report_fail "File completeness: $FOUND_COUNT/$total — missing: ${MISSING[*]}"
  fi
}

# Extract a CSS custom property value from a file
css_var_value() {
  local file="$1" var_name="$2"
  grep -oE "\\-\\-${var_name}: *[^;]+" "$file" | head -1 | sed 's/.*: *//' | tr -d ' '
}

# Compare two values, report via callback. Returns 0 if match, 1 if mismatch.
compare_values() {
  local label="$1" actual="$2" expected="$3" reporter="$4"
  if [[ -n "$expected" && -n "$actual" && "$actual" != "$expected" ]]; then
    "$reporter" "$label ($actual vs $expected)"
    return 1
  fi
  return 0
}

# --- Check 2: brand-tokens.css consistency ---
check_tokens_css() {
  local css_file="$BRANDING_DIR/brand-tokens.css"
  if [[ ! -f "$css_file" ]]; then
    report_fail "brand-tokens.css: file not found"; return
  fi

  local css_primary css_font ok=true
  css_primary=$(lc_hex "$(css_var_value "$css_file" "color-primary")")
  css_font=$(css_var_value "$css_file" "font-primary" | tr -d '"'\''')

  compare_values "brand-tokens.css: primary color mismatch" "$css_primary" "$BRAND_PRIMARY" report_fail || ok=false
  if [[ -n "$BRAND_FONT" && -n "$css_font" && "$css_font" != *"$BRAND_FONT"* && "$BRAND_FONT" != *"$css_font"* ]]; then
    report_fail "brand-tokens.css: font mismatch ($css_font vs $BRAND_FONT)"; ok=false
  fi
  if [[ "$ok" == true ]]; then
    report_pass "brand-tokens.css: colors and fonts match brand.json"
  fi
}

# Extract primary hex color from a file via grep
extract_primary_hex() {
  grep -iE 'primary.*#[0-9a-fA-F]+' "$1" | grep -oE '#[0-9a-fA-F]+' | head -1
}

# --- Check 3: tailwind.preset.ts consistency ---
check_tailwind_preset() {
  local tw_file="$BRANDING_DIR/tailwind.preset.ts"
  if [[ ! -f "$tw_file" ]]; then
    report_fail "tailwind.preset.ts: file not found"; return
  fi

  local tw_primary ok=true
  tw_primary=$(lc_hex "$(extract_primary_hex "$tw_file")")

  compare_values "tailwind.preset.ts: primary color mismatch" "$tw_primary" "$BRAND_PRIMARY" report_warn || ok=false
  if [[ -n "$BRAND_FONT" ]] && ! grep -qi "$BRAND_FONT" "$tw_file"; then
    report_warn "tailwind.preset.ts: font family '$BRAND_FONT' not found"; ok=false
  fi
  if [[ "$ok" == true ]]; then
    report_pass "tailwind.preset.ts: colors and fonts match brand.json"
  fi
}

# Check if an HTML file contains a value (case-insensitive)
html_contains() {
  local file="$1" value="$2"
  [[ -n "$value" ]] && grep -qi "$value" "$file"
}

# --- Check 4: DA HTML consistency ---
check_da_html() {
  local da_file
  da_file=$(find "$BRANDING_DIR" -maxdepth 1 -name "the-*.html" -type f 2>/dev/null | head -1)
  if [[ -z "$da_file" ]]; then
    report_warn "DA HTML: no the-*.html file found"; return
  fi

  local ok=true
  if [[ -n "$BRAND_NAME" ]] && ! html_contains "$da_file" "$BRAND_NAME"; then
    report_warn "DA HTML: brand name '$BRAND_NAME' not found"; ok=false
  fi
  if [[ -n "$BRAND_PRIMARY" ]] && ! html_contains "$da_file" "$BRAND_PRIMARY"; then
    report_warn "DA HTML: primary color $BRAND_PRIMARY not referenced"; ok=false
  fi
  if [[ -n "$BRAND_FONT" ]] && ! html_contains "$da_file" "$BRAND_FONT"; then
    report_warn "DA HTML: font '$BRAND_FONT' not referenced"; ok=false
  fi
  if [[ "$ok" == true ]]; then
    report_pass "DA HTML: brand name, colors, and fonts correct"
  fi
}

# --- Check 5: Orphaned files ---
check_orphaned_files() {
  local orphans=()
  while IFS= read -r -d '' file; do
    local name
    name=$(basename "$file")
    case "$name" in
      .DS_Store|Thumbs.db|*.tmp|*.bak|*~|*.swp) orphans+=("$name") ;;
    esac
  done < <(find "$BRANDING_DIR" -type f -print0 2>/dev/null)

  if [[ ${#orphans[@]} -eq 0 ]]; then
    report_pass "No orphaned files found"
  else
    report_warn "Orphaned files: ${orphans[*]} (recommend deletion)"
  fi
}

# --- Check 6: Logo file size sanity ---
check_logo_sizes() {
  local logos_dir="$BRANDING_DIR/logos"
  if [[ ! -d "$logos_dir" ]]; then
    report_warn "Logo sizes: logos/ directory not found"
    return
  fi

  local ok=true
  for png in "$logos_dir"/*.png; do
    [[ -f "$png" ]] || continue
    local size_bytes
    size_bytes=$(stat -f%z "$png" 2>/dev/null || stat --printf="%s" "$png" 2>/dev/null || echo "0")
    local name
    name=$(basename "$png")

    if [[ $size_bytes -lt 1024 ]]; then
      report_warn "Logo size: $name is ${size_bytes}B (< 1KB, possibly empty/corrupt)"
      ok=false
    fi
    if [[ $size_bytes -gt 10485760 ]]; then
      report_warn "Logo size: $name is $((size_bytes / 1048576))MB (> 10MB, suspicious)"
      ok=false
    fi
  done

  if [[ "$ok" == true ]]; then
    report_pass "Logo sizes: all within expected range"
  fi
}

# Run all checks
check_file_completeness
check_tokens_css
check_tailwind_preset
check_da_html
check_orphaned_files
check_logo_sizes

# Summary
echo ""
echo "[COHERENCE] Result: $PASS PASS | $WARN WARNING | $FAIL ERRORS"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
