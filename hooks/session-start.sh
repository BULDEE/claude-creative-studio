#!/usr/bin/env bash
# Session Start — Brand Context Detection
# Detects brand.json and image provider configuration at session startup.
# Read-only: no file modifications, no network calls.

set -euo pipefail

OUTPUT=""

# 1. Detect image provider
PROVIDER="${CREATIVE_STUDIO_IMAGE_PROVIDER:-gemini}"
case "$PROVIDER" in
  gemini)
    if [[ -n "${GEMINI_API_KEY:-}" ]]; then
      OUTPUT+="Image provider: Gemini (Nano Banana) ✓"$'\n'
    else
      OUTPUT+="⚠ Image provider: Gemini configured but GEMINI_API_KEY not set. Run /creative:setup-provider"$'\n'
    fi
    ;;
  openai)
    if [[ -n "${OPENAI_IMAGE_KEY:-}" ]]; then
      OUTPUT+="Image provider: OpenAI (gpt-image-1) ✓"$'\n'
    else
      OUTPUT+="⚠ Image provider: OpenAI configured but OPENAI_IMAGE_KEY not set. Run /creative:setup-provider"$'\n'
    fi
    ;;
  *)
    OUTPUT+="⚠ Unknown image_provider: $PROVIDER. Use 'gemini' or 'openai'."$'\n'
    ;;
esac

# 2. Detect brand.json in working directory
BRAND_JSON=""
for candidate in "brand.json" "branding/brand.json" "brandbook-final/brand.json" ".claude/brand.json"; do
  if [[ -f "$candidate" ]]; then
    BRAND_JSON="$candidate"
    break
  fi
done

if [[ -n "$BRAND_JSON" ]]; then
  BRAND_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$BRAND_JSON" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"//')
  if [[ -n "$BRAND_NAME" ]]; then
    OUTPUT+="Brand detected: $BRAND_NAME (from $BRAND_JSON)"$'\n'
  else
    OUTPUT+="brand.json found at $BRAND_JSON (no name field)"$'\n'
  fi

  # Check for branding/ folder
  if [[ -d "branding" ]]; then
    ASSET_COUNT=$(find branding -type f 2>/dev/null | wc -l | tr -d ' ')
    OUTPUT+="branding/ folder: $ASSET_COUNT assets"$'\n'
  fi
else
  OUTPUT+="No brand.json detected. Use /creative:brand-pipeline to create one."$'\n'
fi

# 3. Detect creative temperature
TEMP="${CREATIVE_STUDIO_CREATIVE_TEMPERATURE:-balanced}"
OUTPUT+="Creative temperature: $TEMP"$'\n'

# 4. Detect RAG database
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
RAG_DB="$PLUGIN_ROOT/creative-rag.db"
if [[ -f "$RAG_DB" ]]; then
  RAG_COUNT=$(sqlite3 "$RAG_DB" "SELECT COUNT(*) FROM pages;" 2>/dev/null || echo "0")
  OUTPUT+="RAG database: $RAG_COUNT indexed pages"$'\n'
else
  OUTPUT+="RAG: not configured (run 'npm run ingest' in plugin dir for brandbook references)"$'\n'
fi

# 5. Cost awareness
case "$PROVIDER" in
  gemini)
    OUTPUT+="Cost: Free tier (~500 images/day). Full pipeline uses ~40-50 images."$'\n'
    ;;
  openai)
    OUTPUT+="Cost: ~\$0.04-0.19/image. Full pipeline: ~\$2-8. Monitor at platform.openai.com"$'\n'
    ;;
esac

# Output
if [[ -n "$OUTPUT" ]]; then
  echo "# Creative Studio Context"
  echo ""
  echo "$OUTPUT"
fi

exit 0
