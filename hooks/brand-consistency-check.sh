#!/usr/bin/env bash
# Brand Consistency Check — Claude Creative Studio
# Runs PostToolUse on Write|Edit to warn about brand inconsistencies.
# Read-only analysis: never blocks, only warns.

set -euo pipefail

# Read tool result from stdin
INPUT=$(cat)

# Extract file path from the tool result
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' 2>/dev/null | head -1 | sed 's/"file_path":"//;s/"$//' || echo "")

# Skip if no file path or not a relevant file type
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

WARNINGS=""

# Only check relevant file types
case "$FILE_PATH" in
  *.tsx|*.ts|*.css|*.json|*.md)
    ;;
  *)
    exit 0
    ;;
esac

# Check 1: Hardcoded hex colors in React/TS files (should use tokens)
if [[ "$FILE_PATH" == *.tsx || "$FILE_PATH" == *.ts ]]; then
  if [ -f "$FILE_PATH" ]; then
    # Look for inline hex colors not in comments or strings that look like token definitions
    HARDCODED=$(grep -nE '#[0-9A-Fa-f]{6}' "$FILE_PATH" 2>/dev/null | grep -v '\/\/' | grep -v 'tokens' | grep -v 'brand' | head -3 || true)
    if [ -n "$HARDCODED" ]; then
      WARNINGS="${WARNINGS}
[BRAND CHECK] Couleurs hex hardcodees detectees dans $FILE_PATH.
  Utiliser les design tokens (brand-tokens.css / tailwind.config.ts) au lieu de valeurs en dur.
  Lignes: $(echo "$HARDCODED" | head -3)"
    fi
  fi
fi

# Check 2: Inline styles with colors in TSX (should use Tailwind classes)
if [[ "$FILE_PATH" == *.tsx ]]; then
  if [ -f "$FILE_PATH" ]; then
    INLINE_COLORS=$(grep -nE 'style=\{.*color' "$FILE_PATH" 2>/dev/null | head -3 || true)
    if [ -n "$INLINE_COLORS" ]; then
      WARNINGS="${WARNINGS}
[BRAND CHECK] Styles inline avec couleurs dans $FILE_PATH.
  Preferer les classes Tailwind derivees des tokens brand.json."
    fi
  fi
fi

# Check 3: CSS custom properties not following naming convention
if [[ "$FILE_PATH" == *.css ]]; then
  if [ -f "$FILE_PATH" ]; then
    BAD_VARS=$(grep -nE '--[a-z]+-' "$FILE_PATH" 2>/dev/null | grep -v '\-\-color-\|\-\-font-\|\-\-radius-\|\-\-shadow-\|\-\-spacing-' | head -3 || true)
    if [ -n "$BAD_VARS" ]; then
      WARNINGS="${WARNINGS}
[BRAND CHECK] CSS custom properties hors convention dans $FILE_PATH.
  Convention: --color-*, --font-*, --radius-*, --shadow-*, --spacing-*"
    fi
  fi
fi

# Output warnings if any
if [ -n "$WARNINGS" ]; then
  echo "$WARNINGS"
fi

exit 0
