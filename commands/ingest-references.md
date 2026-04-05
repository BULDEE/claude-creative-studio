---
name: ingest-references
description: Indexes brandbook PDFs and image folders into the RAG database for creative reference during brand generation. Guides the user through folder selection and runs the ingestion pipeline.
disable-model-invocation: true
---

Guides the user through indexing their brandbook references into the creative RAG database.

## Prerequisites check

Before starting, verify:

1. **GEMINI_API_KEY** — required for Gemini Vision page analysis
   - If missing → redirect to `/creative:setup-provider`
2. **poppler** — required for PDF page extraction
   - Check: `command -v pdftoppm`
   - If missing → tell the user: `brew install poppler` (macOS) or `apt install poppler-utils` (Linux)
3. **Node dependencies** — required for the ingestion scripts
   - Check: `ls "${CLAUDE_PLUGIN_ROOT}/node_modules/.package-lock.json"` or similar
   - If missing → run `npm install` in the plugin directory

## Step 1: Detect and ask for reference folders

**Auto-detection** — scan these locations (in priority order) before asking:

1. **Project `.claude/` directory** (where Claude is running):
   ```bash
   find .claude/ -type d -name "*brand*" -o -name "*reference*" -o -name "*logo*" 2>/dev/null
   find .claude/ -name "*.pdf" -o -name "*.png" -o -name "*.jpg" 2>/dev/null | head -5
   ```
2. **Plugin knowledge directory**:
   ```bash
   ls "${CLAUDE_PLUGIN_ROOT}/knowledge/logo-references/"
   ls "${CLAUDE_PLUGIN_ROOT}/knowledge/brand-assets/"
   ```
3. **Project root** — look for common branding folders:
   ```bash
   find . -maxdepth 2 -type d \( -name "*brandbook*" -o -name "*branding*" -o -name "*brand-assets*" -o -name "*logo*references*" \) 2>/dev/null
   ```

If references are found, suggest them:
> "I found these folders that might contain brandbook references:
> - `.claude/brandbooks/` (3 PDFs, 42 images)
> - `knowledge/logo-references/` (9 PDFs)
>
> Want to index them? You can also provide additional folder paths."

If nothing is found, ask:

> "Where are your brandbook references? I can index:
> - **PDF brandbooks** (logo guidelines, brand books) — each page gets analyzed by Gemini Vision
> - **Image folders** (logos, mockups, UI screens, icons) — each image gets described and categorized
>
> Provide one or more folder paths. You can also drop files into:
> - `.claude/references/` in your project
> - `knowledge/logo-references/` in the plugin directory"

## Step 2: Validate folders

For each provided path:
1. Verify the folder exists
2. Count files by type:
   - PDFs: `find <path> -name "*.pdf" -type f | wc -l`
   - Images: `find <path> \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -type f | wc -l`
3. Estimate Gemini Vision calls:
   - PDFs: ~30 pages per PDF (estimate)
   - Images: 1 call per image
4. Report to the user:
   > "Found: X PDFs (~Y pages) and Z images. This will use approximately N Gemini Vision calls (free tier: 1,500/day). Estimated time: ~M minutes at 2s/call."

## Step 3: Configure ingestion options

Ask:
- **Delay between calls** (default: 2 seconds) — increase to 3-4s if the user is concerned about rate limits
- **Resume mode** — if a previous ingestion was interrupted, it automatically skips already-indexed pages

## Step 4: Run ingestion

Execute:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/ingest.sh" --delay [DELAY] [FOLDER_1] [FOLDER_2] ...
```

Monitor the output and relay progress to the user:
- `[1/9] Processing file.pdf (30 pages)...`
- Report errors immediately
- If rate-limited (exit code 2 from describe-page.mjs), inform the user and suggest increasing the delay

## Step 5: Verify results

After ingestion completes:
1. Report total indexed pages:
   ```bash
   sqlite3 "${CLAUDE_PLUGIN_ROOT}/creative-rag.db" "SELECT COUNT(*) FROM pages;"
   ```
2. Show category breakdown:
   ```bash
   sqlite3 "${CLAUDE_PLUGIN_ROOT}/creative-rag.db" "SELECT category, COUNT(*) FROM pages GROUP BY category ORDER BY COUNT(*) DESC;"
   ```
3. Show brand breakdown:
   ```bash
   sqlite3 "${CLAUDE_PLUGIN_ROOT}/creative-rag.db" "SELECT brand_name, COUNT(*) FROM pages GROUP BY brand_name ORDER BY COUNT(*) DESC;"
   ```
4. Test a sample search:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/search.sh" "logo construction grid" --limit 2
   ```

## Step 6: Confirm integration

Tell the user:
> "Your references are indexed. The RAG database will now be used automatically when generating:
> - **Logo concepts** — construction grids and ratio references
> - **3D renders** — material and lighting references from your brandbooks
> - **DA HTML** — moodboard and typography inspiration
> - **Brand pipeline** — calibrated prompts based on professional examples
>
> You can search manually anytime: `bash scripts/search.sh "your query"`
> To add more references later, run this command again."

## Adding more references later

The ingestion is idempotent — running it again with the same folders skips already-indexed pages. New folders are additive.

To re-index everything from scratch:
```bash
rm "${CLAUDE_PLUGIN_ROOT}/creative-rag.db"
```
Then run this command again.

## Important

- Gemini Vision calls are **free** (within the 1,500/day limit)
- The RAG database (`creative-rag.db`) is local and gitignored
- No images are uploaded permanently — Gemini Vision processes them ephemerally
- The database contains **text descriptions**, not the images themselves
