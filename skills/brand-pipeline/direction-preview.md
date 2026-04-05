# Direction Preview — Embedded Visual Companion

This file describes how to generate a self-contained direction preview page for Phase 1 of the brand pipeline. Lets users **visually compare** artistic directions in their browser before choosing.

## Prerequisites

- Python 3 (pre-installed on macOS and most Linux distributions)
- The embedded `preview-server.sh` script (included in this directory)

## Server Lifecycle

### Start

```bash
# Start the preview server with the generated HTML file
skills/brand-pipeline/preview-server.sh start /path/to/directions-overview.html

# Returns JSON:
# {"type":"server-started","port":52341,"url":"http://localhost:52341/directions-overview.html","pid":12345}
```

Tell the user to open the URL in their browser.

### Stop

```bash
skills/brand-pipeline/preview-server.sh stop
# Returns: {"type":"server-stopped"}
```

Always stop the server after the user has made their selection.

## Direction Preview Template

Write ONE self-contained HTML file using the Write tool. This is a **complete HTML document** (not a fragment).

### Overview Page — `directions-overview.html`

Write this file to the project's working directory (e.g., `brandbook-exploration/directions-overview.html`), then serve it with the preview server.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[BRAND_NAME] — Choose Your Direction</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
      background: #09090b; color: #fafafa;
      min-height: 100vh; padding: 48px 24px;
    }
    h1 { font-size: 28px; font-weight: 700; text-align: center; margin-bottom: 8px; }
    .subtitle { text-align: center; color: #71717a; font-size: 15px; margin-bottom: 40px; }
    .grid {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 24px; max-width: 1200px; margin: 0 auto;
    }
    .card {
      background: #18181b; border: 1px solid rgba(255,255,255,0.06);
      border-radius: 12px; overflow: hidden; cursor: pointer;
      transition: border-color 0.2s, transform 0.15s, box-shadow 0.2s;
    }
    .card:hover { border-color: rgba(255,255,255,0.15); transform: translateY(-2px); }
    .card.selected {
      border-color: #3b82f6; box-shadow: 0 0 0 2px rgba(59,130,246,0.3);
      transform: translateY(-2px);
    }
    .palette-strip { display: flex; height: 48px; }
    .palette-strip > div { flex: 1; }
    .mockup { padding: 24px; }
    .mockup-title { font-size: 20px; font-weight: 700; margin-bottom: 8px; }
    .mockup-tagline { font-size: 13px; margin-bottom: 16px; }
    .mockup-btn {
      display: inline-block; padding: 8px 20px; color: white;
      border-radius: 6px; font-size: 13px; font-weight: 600;
    }
    .card-body { padding: 20px; }
    .card-body h3 { font-size: 16px; font-weight: 600; margin-bottom: 8px; }
    .card-body p { font-size: 13px; color: #a1a1aa; line-height: 1.5; }
    .badges { margin-top: 12px; display: flex; gap: 6px; flex-wrap: wrap; }
    .badge {
      padding: 2px 10px; border-radius: 100px; font-size: 11px;
      border: 1px solid rgba(255,255,255,0.15); color: rgba(255,255,255,0.6);
    }
    .font-info {
      margin-top: 12px; font-family: monospace; font-size: 11px;
      color: rgba(255,255,255,0.4);
    }
    .selected-banner {
      display: none; text-align: center; margin-top: 32px; padding: 16px;
      background: rgba(59,130,246,0.1); border: 1px solid rgba(59,130,246,0.3);
      border-radius: 8px; color: #93c5fd; font-size: 14px;
    }
    .selected-banner.visible { display: block; }
  </style>
</head>
<body>
  <h1>Choose Your Brand Direction</h1>
  <p class="subtitle">Click a direction to select it. Each shows palette, typography, and a style preview.</p>

  <div class="grid">

    <!-- Direction 1 -->
    <div class="card" data-direction="1" onclick="selectDirection(this)">
      <div class="palette-strip">
        <div style="background: [PRIMARY_1]"></div>
        <div style="background: [SECONDARY_1]"></div>
        <div style="background: [ACCENT_1]"></div>
        <div style="background: [BG_1]"></div>
      </div>
      <div class="mockup" style="background: [BG_1]; color: [TEXT_1]; font-family: [FONT_1], system-ui;">
        <div class="mockup-title" style="color: [TEXT_1];">[BRAND_NAME]</div>
        <p class="mockup-tagline" style="color: [MUTED_1];">[DIRECTION_1_TAGLINE]</p>
        <div class="mockup-btn" style="background: [PRIMARY_1];">Get Started</div>
      </div>
      <div class="card-body">
        <h3>[DIRECTION_1_NAME]</h3>
        <p>[DIRECTION_1_DESCRIPTION]</p>
        <div class="badges">
          <span class="badge">[MOOD_1_KW1]</span>
          <span class="badge">[MOOD_1_KW2]</span>
          <span class="badge">[MOOD_1_KW3]</span>
        </div>
        <div class="font-info">[FONT_1] &middot; [FONT_BODY_1]</div>
      </div>
    </div>

    <!-- Direction 2 -->
    <div class="card" data-direction="2" onclick="selectDirection(this)">
      <div class="palette-strip">
        <div style="background: [PRIMARY_2]"></div>
        <div style="background: [SECONDARY_2]"></div>
        <div style="background: [ACCENT_2]"></div>
        <div style="background: [BG_2]"></div>
      </div>
      <div class="mockup" style="background: [BG_2]; color: [TEXT_2]; font-family: [FONT_2], system-ui;">
        <div class="mockup-title" style="color: [TEXT_2];">[BRAND_NAME]</div>
        <p class="mockup-tagline" style="color: [MUTED_2];">[DIRECTION_2_TAGLINE]</p>
        <div class="mockup-btn" style="background: [PRIMARY_2];">Get Started</div>
      </div>
      <div class="card-body">
        <h3>[DIRECTION_2_NAME]</h3>
        <p>[DIRECTION_2_DESCRIPTION]</p>
        <div class="badges">
          <span class="badge">[MOOD_2_KW1]</span>
          <span class="badge">[MOOD_2_KW2]</span>
          <span class="badge">[MOOD_2_KW3]</span>
        </div>
        <div class="font-info">[FONT_2] &middot; [FONT_BODY_2]</div>
      </div>
    </div>

    <!-- Direction 3 -->
    <div class="card" data-direction="3" onclick="selectDirection(this)">
      <div class="palette-strip">
        <div style="background: [PRIMARY_3]"></div>
        <div style="background: [SECONDARY_3]"></div>
        <div style="background: [ACCENT_3]"></div>
        <div style="background: [BG_3]"></div>
      </div>
      <div class="mockup" style="background: [BG_3]; color: [TEXT_3]; font-family: [FONT_3], system-ui;">
        <div class="mockup-title" style="color: [TEXT_3];">[BRAND_NAME]</div>
        <p class="mockup-tagline" style="color: [MUTED_3];">[DIRECTION_3_TAGLINE]</p>
        <div class="mockup-btn" style="background: [PRIMARY_3];">Get Started</div>
      </div>
      <div class="card-body">
        <h3>[DIRECTION_3_NAME]</h3>
        <p>[DIRECTION_3_DESCRIPTION]</p>
        <div class="badges">
          <span class="badge">[MOOD_3_KW1]</span>
          <span class="badge">[MOOD_3_KW2]</span>
          <span class="badge">[MOOD_3_KW3]</span>
        </div>
        <div class="font-info">[FONT_3] &middot; [FONT_BODY_3]</div>
      </div>
    </div>

  </div>

  <div id="banner" class="selected-banner">
    You selected <strong id="selected-name"></strong>. Return to the terminal to confirm your choice.
  </div>

  <script>
    function selectDirection(card) {
      document.querySelectorAll('.card').forEach(c => c.classList.remove('selected'));
      card.classList.add('selected');
      const name = card.querySelector('h3').textContent;
      document.getElementById('selected-name').textContent = name;
      document.getElementById('banner').classList.add('visible');
    }
  </script>
</body>
</html>
```

### Deep Dive Page — `direction-[N]-detail.html`

If the user wants to explore a direction deeper before committing, write a detail page:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[BRAND_NAME] — [DIRECTION_NAME] Detail</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
      background: #09090b; color: #fafafa;
      min-height: 100vh; padding: 48px 24px;
    }
    h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
    .subtitle { color: #71717a; font-size: 15px; margin-bottom: 32px; }
    .split { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; max-width: 1000px; }
    @media (max-width: 768px) { .split { grid-template-columns: 1fr; } }
    .panel {
      background: #18181b; border: 1px solid rgba(255,255,255,0.06);
      border-radius: 12px; overflow: hidden;
    }
    .panel-header {
      padding: 12px 20px; font-size: 12px; font-weight: 600;
      text-transform: uppercase; letter-spacing: 0.05em;
      color: #71717a; border-bottom: 1px solid rgba(255,255,255,0.06);
    }
    .swatch {
      padding: 16px 20px; font-family: monospace; font-size: 12px;
    }
    .accent-row { display: flex; }
    .accent-row > div {
      flex: 1; padding: 12px; font-size: 11px;
      font-family: monospace; text-align: center;
    }
    .typo-panel { padding: 24px; }
    .typo-brand { font-size: 28px; font-weight: 700; margin-bottom: 4px; }
    .typo-tagline { font-size: 16px; margin-bottom: 16px; }
    .typo-body { font-size: 13px; line-height: 1.6; margin-bottom: 16px; }
    .btn-row { display: flex; gap: 8px; }
    .btn-primary {
      padding: 8px 20px; color: white; border-radius: 6px;
      font-size: 13px; font-weight: 600; border: none;
    }
    .btn-secondary {
      padding: 8px 20px; background: transparent;
      border-radius: 6px; font-size: 13px; border: 1px solid;
    }
    .font-stack {
      margin-top: 16px; font-family: monospace; font-size: 12px;
      color: rgba(255,255,255,0.4);
    }
    .back-link {
      display: inline-block; margin-top: 32px; color: #3b82f6;
      text-decoration: none; font-size: 14px;
    }
    .back-link:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>[DIRECTION_NAME]</h1>
  <p class="subtitle">[DIRECTION_DESCRIPTION]</p>

  <div class="split">
    <!-- Left: Full palette -->
    <div class="panel">
      <div class="panel-header">Color Palette</div>
      <div class="swatch" style="background: [PRIMARY_900]; color: white;">Primary 900 &middot; [PRIMARY_900]</div>
      <div class="swatch" style="background: [PRIMARY_700]; color: white;">Primary 700 &middot; [PRIMARY_700]</div>
      <div class="swatch" style="background: [PRIMARY_500]; color: white;">Primary 500 &middot; [PRIMARY_500]</div>
      <div class="swatch" style="background: [PRIMARY_300]; color: #111;">Primary 300 &middot; [PRIMARY_300]</div>
      <div class="accent-row">
        <div style="background: [ACCENT_1]; color: white;">[ACCENT_1]</div>
        <div style="background: [ACCENT_2]; color: white;">[ACCENT_2]</div>
      </div>
    </div>

    <!-- Right: Typography + Mini UI -->
    <div class="panel">
      <div class="panel-header">Typography &amp; Style</div>
      <div class="typo-panel" style="background: [BG]; color: [TEXT]; font-family: [FONT_DISPLAY], system-ui;">
        <div class="typo-brand">[BRAND_NAME]</div>
        <div class="typo-tagline" style="color: [MUTED];">[TAGLINE]</div>
        <div class="typo-body" style="color: [SECONDARY]; font-family: [FONT_BODY], system-ui;">
          Body text sample in [FONT_BODY]. Clean, readable, professional.
          Numbers look like this: 1,234.56 — ideal for data and metrics.
        </div>
        <div class="btn-row">
          <button class="btn-primary" style="background: [PRIMARY];">Primary</button>
          <button class="btn-secondary" style="color: [TEXT]; border-color: [BORDER];">Secondary</button>
        </div>
        <div class="font-stack">[FONT_DISPLAY] &middot; [FONT_BODY] &middot; [FONT_MONO]</div>
      </div>
    </div>
  </div>

  <a class="back-link" href="directions-overview.html">&larr; Back to overview</a>
</body>
</html>
```

## Variables Reference

All variables are populated from the direction exploration data generated in Phase 1.

| Variable | Source | Example |
|----------|--------|---------|
| `[BRAND_NAME]` | User input | "MyBrand" |
| `[DIRECTION_N_NAME]` | Generated direction name | "The Prism" |
| `[DIRECTION_N_DESCRIPTION]` | 1-2 sentence description | "Dark-first geometric aesthetic..." |
| `[DIRECTION_N_TAGLINE]` | Short tagline for direction | "Precision meets data" |
| `[PRIMARY_N]` | Direction primary color hex | "#7c3aed" |
| `[SECONDARY_N]` | Direction secondary color hex | "#6d28d9" |
| `[ACCENT_N]` | Direction accent color hex | "#10b981" |
| `[BG_N]` | Direction background color hex | "#09090b" |
| `[TEXT_N]` | Direction text color hex | "#fafafa" |
| `[MUTED_N]` | Direction muted text hex | "#52525b" |
| `[FONT_N]` | Display font family | "Sora" |
| `[FONT_BODY_N]` | Body font family | "Inter" |
| `[FONT_MONO]` | Mono font family | "DM Mono" |
| `[MOOD_N_KW*]` | Style keywords | "dark-first", "geometric", "premium" |
| `[BORDER]` | Border color | "rgba(255,255,255,0.06)" |

## Fallback — No Python 3

If Python 3 is not available (extremely rare), fall back to a terminal-based comparison:

```markdown
## Brand Directions

| | Direction 1 | Direction 2 | Direction 3 |
|---|------------|------------|------------|
| **Name** | [NAME_1] | [NAME_2] | [NAME_3] |
| **Mood** | [MOOD_1] | [MOOD_2] | [MOOD_3] |
| **Primary** | [HEX_1] | [HEX_2] | [HEX_3] |
| **Font** | [FONT_1] | [FONT_2] | [FONT_3] |
| **Why** | [ARGUMENT_1] | [ARGUMENT_2] | [ARGUMENT_3] |

Which direction resonates most? I can also mix elements from different directions.
```

## Integration with Brand Pipeline

Phase 1 of the brand pipeline should:

1. Generate the 3 directions (palettes, fonts, moods, concepts)
2. Write `directions-overview.html` as a complete HTML file into `brandbook-exploration/`
3. Start the embedded preview server: `preview-server.sh start brandbook-exploration/directions-overview.html`
4. Tell the user to open the URL and select a direction
5. Wait for the user's terminal response
6. If the user wants a deep dive: write `direction-N-detail.html` to the same folder, give them the URL
7. On confirmation: stop the server (`preview-server.sh stop`), continue to Phase 2
8. Fallback: if Python 3 is unavailable, use terminal markdown table
