---
name: brand-da
description: Generates an interactive Design Application (DA) as a single-file HTML brandbook with 10 sections (symbol, palette, typography, dark/light components, specifications, landing page, data-viz, states, design tokens). Vercel/Linear quality level. Triggered by 'DA', 'design application', 'brandbook HTML', 'interactive brandbook', 'the-prism', 'DA interactive', 'generate DA'.
argument-hint: [brand-name]
---

# Design Application — HTML Interactive Brandbook

You are a **Senior Brand Designer & Frontend Architect** specialized in creating professional Design Applications. Your quality standard = DAs from brands like Vercel, Linear, Stripe.

## Prerequisites

- `brand.json` in the working directory or `brandbook-final/`
- Generated logos (at minimum `icon-flat-dark.png` and `icon-flat-light.png`)
- If `brand.json` is missing → redirect to `/claude-creative-studio:brand-pipeline`
- If logos are missing → redirect to `/claude-creative-studio:design-logo`

## Image API Reference

See [image-provider-reference.md](../image-provider-reference.md) for generating complementary visual assets.

## Design Principles

### Non-negotiable visual quality

The DA is the **most impactful deliverable** in the pipeline. It must:
- Be a single, self-contained HTML file (inline CSS, preconnected fonts, inline SVGs)
- Work by simply opening the file in a browser
- Impress an art director within 3 seconds
- Serve as a technical reference for developers

### Required visual patterns

1. **CSS Custom Properties** — all colors derived from `brand.json`
2. **Clamp() responsive** — `clamp(24px, 3vw, 36px)` for section titles
3. **Fixed grid background** — subtle 64px grid at 2% opacity (premium feel)
4. **1px borders** — `rgba(255,255,255,0.06)` on dark, `rgba(0,0,0,0.06)` on light
5. **Mono font for metrics** — hex codes, sizes, technical labels
6. **Hover states** — 200ms transitions on borders and backgrounds
7. **Numbered sections** — format "01 — The Symbol", "02 — Palette", etc.
8. **Max-width 1120px** — centered content, 40px horizontal padding

## Section Configuration

Based on `userConfig.da_sections`:
- `"all"` → generate all 16 sections (default)
- `"classic"` → generate original 10 sections (00, 01, 03, 05, 08, 09, 10, 11, 12, 14, 15 in new numbering)
- `["01","03","06"]` → custom selection by section number

## Structure — 16 Sections

### Section 00: Hero

```html
<section class="hero">
  <div class="badge">[BRAND NAME] — Design Application</div>
  <div class="hero-logo"><!-- Inline SVG or img of main logo --></div>
  <h1>[BRAND NAME]</h1>
  <p class="hero-subtitle">[TAGLINE from brand.json]</p>
  <div class="scroll-indicator">Scroll to explore ↓</div>
</section>
```

- Centered logo 160x160px
- Subtle badge at the top
- Background = background color from brand.json
- Animated scroll indicator (CSS only)

### Section 01: The Symbol

Present the logo in **6+ different contexts**:

| Context | Description |
|---------|-------------|
| Dark background (bg) | Light logo on dark background |
| Light background (#fafafa) | Dark logo on light background |
| Primary background | White/black logo on primary color |
| Surface background | Logo on elevated surface |
| Horizontal lockup dark | Logo + name, dark background |
| Horizontal lockup light | Logo + name, light background |

**Layout**: 3-column grid with 1px gaps (gaps become visual lines).

### Section 02: Moodboard

**Visual mood reference board** showing the creative universe that inspired the brand direction.

**RAG enrichment** (if `creative-rag.db` exists):
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/search.sh" "[brand-style-keywords]" --category moodboard --limit 3
```
Use returned descriptions as composition references for Gemini/OpenAI generation.

**Content**:
1. **Primary mood image** — large (16:9), abstract composition representing the brand universe
2. **Secondary images** — 2 stacked (1:1), texture/material details
3. **Swatch strip** — 3-4 small images showing colors/patterns in context
4. Each image has a mono caption: material, color reference, mood keyword

**Layout**: 2-column asymmetric grid (60/40 split).
- Left: large primary mood image
- Right: 2 stacked secondary images
- Bottom row: 3-4 swatch thumbnails at equal width

**CSS pattern**:
```css
.moodboard-grid {
  display: grid;
  grid-template-columns: 3fr 2fr;
  grid-template-rows: auto auto;
  gap: 1px;
}
.moodboard-primary { grid-row: 1 / 3; }
.moodboard-swatches {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 1px;
}
```

**Generation**: use `brand.json.style.keywords` and `style.mood` as prompt seeds. Generate via the configured image provider (see [image-provider-reference.md](../image-provider-reference.md)).

### Section 03: Palette

**Color chips** organized by category:
- **Primary** — all shades (50 → 900 if available)
- **Neutral** — background, surface, muted, secondary, foreground
- **Accent** — functional colors (success, warning, error, info)
- **Border** — values with opacity

Each chip:
```html
<div class="color-chip">
  <div class="color-swatch" style="background: [HEX]"></div>
  <span class="color-name mono">[NAME]</span>
  <span class="color-hex mono">[HEX]</span>
</div>
```

**Layout**: CSS Grid `auto-fill, minmax(160px, 1fr)`.

### Section 04: Font Exploration

**Typographic pairing exploration** showing why the chosen fonts work together.

**Content**:
1. **Pairing showcase** — display font + body font side by side in a realistic layout (heading + paragraph + caption)
2. **Character set** — a→z A→Z 0→9 + special characters for each font
3. **Weight ramp** — all available weights shown on one word (e.g., "Design" in 300, 400, 500, 600, 700, 800)
4. **Size comparison** — same text at all scale sizes (xs → 6xl from brand.json.typography.scale)
5. **Contrast test** — fonts on dark and light backgrounds side by side

**Layout**: full-width cards, one per font family. Each card has the font name in mono header, then specimens below.

```css
.font-exploration-card {
  border: 1px solid var(--border);
  border-radius: 12px;
  overflow: hidden;
}
.font-card-header {
  padding: 16px 24px;
  border-bottom: 1px solid var(--border);
  font-family: var(--font-mono);
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-muted);
}
.font-card-body { padding: 32px 24px; }
.weight-ramp { display: flex; gap: 24px; flex-wrap: wrap; }
.weight-ramp span { display: flex; flex-direction: column; align-items: center; gap: 4px; }
.weight-label { font-family: var(--font-mono); font-size: 10px; color: var(--text-muted); }
.charset { font-size: 18px; line-height: 1.8; letter-spacing: 0.02em; word-break: break-all; }
```

### Section 05: Typography Specimen

**Type showcase** — one row per size/weight with:
- Left: sample text in the font/weight/size
- Right: metadata in mono (font, weight, size, line-height)

```html
<div class="type-row">
  <span class="type-sample" style="font-family: [FONT]; font-weight: [WEIGHT]; font-size: [SIZE]">
    [SAMPLE TEXT]
  </span>
  <span class="type-meta mono">[FONT] · [WEIGHT] · [SIZE] / [LINE-HEIGHT]</span>
</div>
```

Show: Display (all sizes from brand.json.typography.scale), Body, Mono.

### Section 06: Construction Grid

**Parametric SVG construction grid** showing the geometric foundation of the logo.

**Implementation**:
1. If `branding/logos/construction-grid.svg` exists → embed it inline as `<svg>` in the HTML
2. If not → generate a default grid:
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/construction-grid.mjs" \
     --width 512 --height 512 \
     --ratios "1,1.4,1.5,2.36" \
     --primary-color "[brand.json.colors.primary.hex]" \
     --output branding/logos/construction-grid.svg
   ```
3. **RAG enrichment** (if `creative-rag.db` exists):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/search.sh" "[brand-name]" --category grid --limit 3
   ```
   Use returned descriptions for ratio calibration and layout reference.
4. Default GST ratios: X, X/1.4, X/1.5, X/2.36 (from GST Agency methodology)

**SVG embedding**: the full SVG is **inlined** in the HTML (not as `<img src>`). This ensures the grid scales with the page and layers are inspectable.

**Layout**: full-width card with dark background (#09090b), SVG centered at max 600px width, mono annotation showing grid dimensions and ratios used.

```css
.construction-grid-card {
  background: #09090b;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 48px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}
.construction-grid-card svg { max-width: 600px; width: 100%; height: auto; }
.grid-annotation {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-muted);
  display: flex;
  gap: 24px;
}
```

### Section 07: Clear Zone System

**Logo protection zone visualization** as inline SVG.

**Content**:
1. Logo centered with dashed-line protection zone rectangle
2. Protection zone = `brand.json.logo.safeZone` (default: 20% of logo height)
3. Show the logo at minimum size with zone annotations
4. Show forbidden placements: too close to edge, overlapping text, busy background

**Layout**: 2-column grid.
- Left: protection zone diagram (inline SVG: logo rect + dashed outer rect + dimension arrows)
- Right: "Do" and "Don't" examples with green checkmark / red cross indicators

```css
.clear-zone-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
.clear-zone-diagram {
  background: #09090b;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 48px;
  display: flex;
  justify-content: center;
}
.clear-zone-rules { display: flex; flex-direction: column; gap: 16px; }
.rule-do { border-left: 3px solid var(--emerald, #10b981); padding-left: 16px; }
.rule-dont { border-left: 3px solid var(--rose, #f43f5e); padding-left: 16px; }
```

**SVG structure** (simpler than construction grid):
```xml
<svg viewBox="0 0 300 300">
  <!-- Protection zone (dashed) -->
  <rect x="30" y="30" width="240" height="240" fill="none" stroke="[PRIMARY]" stroke-dasharray="6,3" opacity="0.4" />
  <!-- Logo area -->
  <rect x="60" y="60" width="180" height="180" fill="none" stroke="[PRIMARY]" stroke-width="1.5" />
  <!-- Dimension arrows -->
  <text x="150" y="22" text-anchor="middle" font-size="10" fill="[MUTED]" font-family="monospace">[SAFE_ZONE]%</text>
</svg>
```

### Section 08: Components — Dark Mode

**Real UI mockups** (not abstract boxes):

1. **Sidebar** — navigation with logo, menu items, active indicator (left accent border)
2. **Dashboard** — KPI grid (4 columns) with sparklines, topbar header
3. **Login form** — logo + email/password fields + primary button
4. **Cards** — header label (mono) + body content + hover state

Each mockup = a `.card` with border, padding, pure CSS code (no images).

### Section 09: Components — Light Mode

**The same components as Section 08** but in light mode.
- Background: `#fafafa` or brand.json.colors.surface if light
- Text: inverted from dark mode
- Borders: `rgba(0,0,0,0.06)`
- Proof of cross-theme design consistency

### Section 10: Specifications

**Logo usage rules**:
- Minimum size: `[brand.json.spacing.min_logo_size]` (e.g., 16px digital, 10mm print)
- Protection zone: `[brand.json.spacing.protection_zone]` (e.g., 25% of height)
- Allowed / prohibited backgrounds
- Aspect ratios to maintain

**Layout**: 4-column grid with specification cards.

### Section 11: Landing Page Preview

**Embedded mockup** of a complete landing page using the DA:
- Hero with logo + headline + CTA
- Features section with icons
- Pricing or social proof
- Footer

A single HTML/CSS block showing the DA applied to a real page.

### Section 12: Data Visualization (conditional)

**Include only if `brand.json.style.keywords` contains "data-driven", "analytics", "dashboard" or similar.**

Otherwise, replace with an **Imagery & Photography** section showing the recommended visual style.

If data-viz:
- Bar charts using palette colors
- Heatmap or grid with accent gradients
- Sparklines in KPI cards
- Legend with associated colors

### Section 13: Brand Applications

**Contextual mockups** showing the brand identity applied to real-world contexts.

**RAG enrichment** (if `creative-rag.db` exists):
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/search.sh" "[brand-name]" --category mockup --limit 5
```
Use returned descriptions for layout inspiration and mockup variety.

**Mockup types** (generate 4-6 as pure CSS/HTML):

| Mockup | Implementation |
|--------|---------------|
| Business card (front + back) | CSS card with logo, name, contact details, brand colors |
| Social media avatar | Circle-cropped logo preview at 64px, 128px, 256px |
| Email signature | HTML table layout with logo + name + title + brand colors |
| App icon on device | Rounded square icon on a dark phone-like frame |
| Browser tab favicon | 16x16 / 32x32 previews in a tab-bar mockup |
| Billboard / signage | Large-scale mockup with logo on dark gradient |

**Layout**: 3-column masonry-style grid. Each mockup in a `.card` with dark background.

```css
.applications-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1px;
}
.application-card {
  border: 1px solid var(--border);
  border-radius: 12px;
  overflow: hidden;
  padding: 32px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}
.application-label {
  font-family: var(--font-mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-muted);
}
```

### Section 14: States & Interactions

**Buttons**: default, hover, active, disabled, loading
**Inputs**: default, focus (primary border), error, disabled
**Badges**: all semantic variants (success, warning, error, info, neutral)
**Navigation items**: default, hover, active (with accent indicator)

Each state must be visible side by side for comparison.

### Section 15: Design Tokens

**Technical reference** for developers:

| Category | Tokens |
|----------|--------|
| Spacing | Full scale (4, 8, 12, 16, 24, 32, 48, 64, 96, 128) |
| Border Radius | sm, md, lg, xl, 2xl, full |
| Shadows | sm, md, lg, xl |
| Motion | fast (150ms), normal (200ms), slow (300ms) + easing curves |

Each token displayed in a card with visual example + value in mono.

---

## Generation — Workflow

### Step 1: Read brand.json

```
1. Read brand.json from the working directory
2. Extract: name, tagline, colors, typography, spacing, borderRadius, shadows, motion, style
3. If fields are missing → use defaults (documented in brand-json-schema.md)
```

### Step 2: Generate CSS Variables

Convert `brand.json.colors` to CSS custom properties:

```css
:root {
  /* Primary */
  --primary-900: [brand.json.colors.primary.violet_900 || brand.json.colors.primary.hex];
  --primary-700: [brand.json.colors.primary.violet_700 || adjust(primary, -20%)];
  /* ... all shades */

  /* Neutral */
  --bg: [brand.json.colors.neutral.bg];
  --surface: [brand.json.colors.neutral.surface];
  --surface-raised: [brand.json.colors.neutral.surface_raised];
  --text: [brand.json.colors.neutral.foreground];
  --text-secondary: [brand.json.colors.neutral.secondary];
  --text-muted: [brand.json.colors.neutral.muted];

  /* Accent */
  --emerald: [brand.json.colors.accent.emerald || #10b981];
  --rose: [brand.json.colors.accent.rose || #f43f5e];
  --amber: [brand.json.colors.accent.amber || #f59e0b];
  --blue: [brand.json.colors.accent.blue || #3b82f6];

  /* Border */
  --border: [brand.json.colors.border.default || rgba(255,255,255,0.06)];
  --border-hover: [brand.json.colors.border.hover || rgba(255,255,255,0.12)];
}
```

### Step 3: Preconnect Fonts

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=[PRIMARY_FONT]:wght@[WEIGHTS]&family=[MONO_FONT]:wght@[WEIGHTS]&display=swap" rel="stylesheet">
```

### Step 4: Generate the HTML

Write a `the-[brand-name-slug].html` file at the project root or in `branding/`.

**Generation rules**:
- All CSS in a `<style>` tag inside `<head>`
- No JavaScript (CSS-only for animations)
- Inline SVGs for logos
- Logo images as `<img>` with relative path to `branding/logos/` or base64
- No external dependencies (except Google Fonts CDN)
- UTF-8 encoding

### Step 5: Adapt sections

Based on `userConfig.da_sections`:
- `"all"` → generate all 16 sections + hero (default)
- `"classic"` → generate original 10 sections (00, 01, 03, 05, 08, 09, 10, 11, 12, 14, 15)
- Specific list (e.g., `"01,03,06"`) → generate only the requested sections

Based on brand context:
- SaaS/analytics → Section 12 = Data Visualization
- E-commerce → Section 12 = Product Photography Style
- Service → Section 12 = Imagery & Photography Guidelines
- Other → Section 12 = Visual Identity Examples

---

## CSS Architecture Reference

### Base layout

```css
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  font-family: var(--font-primary), system-ui, sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
}

.grid-bg {
  position: fixed; inset: 0; z-index: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.02) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.02) 1px, transparent 1px);
  background-size: 64px 64px;
  pointer-events: none;
}

.container { max-width: 1120px; margin: 0 auto; padding: 0 40px; }

section { position: relative; z-index: 1; padding: 120px 0; }
```

### Section headers

```css
.section-number {
  font-family: var(--font-mono), monospace;
  font-size: 13px;
  color: var(--text-muted);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 8px;
}

.section-title {
  font-size: clamp(24px, 3vw, 36px);
  font-weight: 700;
  margin-bottom: 12px;
}

.section-desc {
  color: var(--text-secondary);
  font-size: 15px;
  max-width: 560px;
}
```

### Cards

```css
.card {
  border: 1px solid var(--border);
  border-radius: 12px;
  overflow: hidden;
  transition: border-color 0.2s;
}
.card:hover { border-color: var(--border-hover); }
.card-header {
  padding: 16px 24px;
  border-bottom: 1px solid var(--border);
  font-family: var(--font-mono), monospace;
  font-size: 12px;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.card-body { padding: 24px; }
```

### Color chips

```css
.palette-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 16px;
}
.color-chip { border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }
.color-swatch { height: 80px; }
.color-info { padding: 12px; }
.color-name { font-size: 13px; display: block; }
.color-hex { font-family: var(--font-mono); font-size: 12px; color: var(--text-muted); }
```

### Utility classes

```css
.mono { font-family: var(--font-mono), monospace; }
.grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; }
.grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1px; }
.grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
```

---

## Self-check before delivery

Before presenting the DA, verify:

1. **All colors** come from CSS variables (no hardcoded hex in inline styles)
2. **Fonts** are preconnected and match `brand.json.typography`
3. **The file opens** in a browser without errors (mentally test the HTML)
4. **All 16 sections** are present (or the configured sections — 10 if "classic")
5. **The grid background** is visible and subtle
6. **Hover states** work (CSS transitions present)
7. **Typography is responsive** (clamp on headings)
8. **The hero** displays the logo and brand name
9. **UI mockups** are recognizable (sidebar, dashboard, login, not empty boxes)
10. **Dark/light modes** are consistent (same components, inverted colors)

<example>
**Input**: brand.json for a SaaS analytics platform (primary: violet #7c3aed, bg: #09090b, font: Sora + DM Mono)

**Output**: `the-[brand-name].html` with:
- Hero: logo centered, badge "[BRAND] — Design Application", background #09090b
- Section 01: 3x2 grid of the logo on 6 backgrounds (dark, light, primary, surface, lockup-dark, lockup-light)
- Section 02: moodboard — 3 mood images (abstract data flows, precision instruments, dark UI textures)
- Section 03: 18 color chips (9 primary shades + 6 neutral + 3 accent)
- Section 04: font exploration — display font character set + weight ramp, mono font specimens
- Section 05: typography specimen — display font 300→800 + mono 400/500 at all scale sizes
- Section 06: construction grid — inline SVG with X/1.4, X/2.36 ratio guides, 8x20 grid
- Section 07: clear zone — 20% safe zone diagram + do/don't examples
- Section 08: sidebar mock, dashboard mock with KPI cards, login form — dark mode
- Section 09: same components in light mode (#fafafa background)
- Section 10: min size 16px, protection zone 25%, allowed backgrounds
- Section 11: landing page preview Hero+Features+CTA
- Section 12: data visualization (SaaS analytics context) — bar charts, heatmap, sparklines
- Section 13: brand applications — business card, social avatar, email signature, app icon, favicon
- Section 14: button states, input states, badge variants
- Section 15: spacing scale, border-radius, shadows, motion timings
</example>

## Pipeline integration

This DA is generated in **Phase 2.5** of the brand-pipeline, after `brand.json` validation (Phase 2) and before the React landing page (Phase 3).

The file is saved to `branding/the-[name].html`.
</output>
