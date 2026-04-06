---
description: Complete brand-to-code pipeline in 8 phases — artistic exploration, final brandbook, 3D proposals, interactive HTML design application, React landing page, design system, social media carousels, and full branding/ export. Orchestrates design-logo, brand-visuals, brand-da, brand-export, and social-carousels. Triggered by 'brandbook', 'brand pipeline', 'brand creation', 'brand to code', 'design system', 'full branding', 'brand identity workflow', 'create brand', 'brand exploration'.
argument-hint: [company-name]
---

# Brand-to-Code Pipeline

End-to-end orchestration from brand exploration through to exported brandbook and acquisition content. This skill acts as a **Process Manager** coordinating the `design-logo`, `brand-visuals`, `brand-da`, `brand-export`, and `social-carousels` skills.

## Prerequisites

- `GEMINI_API_KEY` or `OPENAI_IMAGE_KEY` configured (see `userConfig.image_provider`)
- Phase 1 competitor research: Playwright MCP (strongly recommended — `claude mcp add --scope user playwright npx @playwright/mcp@latest`)
- Phase 1 visual preview: embedded preview server (Python 3 — pre-installed on macOS/Linux). See [direction-preview.md](direction-preview.md)
- Phase 4: React 19 + TypeScript + Tailwind CSS project (optional)
- Phase 4-5: use cross-plugin skills `craftsman:component` and `frontend-design:frontend-design` if available
- Image API reference: see [image-provider-reference.md](../image-provider-reference.md)

## Overview

```
Phase 1         Phase 2          Phase 2.5       Phase 2.7        Phase 3
EXPLORE    →    DEFINE     →     DA HTML    →    3D LOGOS    →    DA EXPORT
3+ artistic     Final brandbook  Interactive DA   3 cinematic      Full branding/
directions      + brand.json     the-[name].html  3D renders       logos+3D+tokens+DA

Phase 4          Phase 5           Phase 6            Phase 7
BUILD      →     DOCUMENT    →     ACQUIRE      →     DELIVER
Branded React    Design system     LinkedIn/IG        Final branding/
landing page     tokens + docs     carousels          with everything
```

Each phase requires explicit user validation before proceeding to the next.

---

## Phase 1: Brandbook Exploration

### Objective
Generate 3+ distinct artistic directions so the client can choose a visual universe.

### Required Input
Ask the user for:
1. **Name** of the company/product
2. **Industry and positioning**
3. **Core values** (3-5 keywords)
4. **Target audience**
5. **Competitors** — URLs of 2-5 competitor websites (strongly recommended)
6. **Desired mood/feeling** (optional)
7. **Existing constraints** (mandated colors, logo to refresh, etc.)

### Competitor Research (Playwright MCP)

If the user provides competitor URLs AND Playwright MCP is available, scrape competitor visual identities before generating directions. This grounds the creative process in real market data instead of generating blindly.

#### Scraping Flow

1. **For each competitor URL**, use Playwright MCP:
   ```
   browser_navigate → [URL]
   browser_take_screenshot → brandbook-exploration/competitors/[name]-homepage.png
   browser_snapshot → extract visible text, colors, fonts
   ```

2. **Extract visual patterns** from each screenshot:
   - **Dominant colors**: identify the top 3-5 colors from the screenshot
   - **Typography**: identify font families from the DOM snapshot (font-family CSS)
   - **Layout pattern**: hero style (centered, split, full-bleed), navigation style, CTA placement
   - **Visual mood**: keywords describing the overall feeling (corporate, playful, minimal, etc.)

3. **Build a competitive landscape summary**:
   ```
   brandbook-exploration/competitors/
   ├── [competitor-1]-homepage.png
   ├── [competitor-2]-homepage.png
   ├── [competitor-3]-homepage.png
   └── competitive-analysis.md    ← Summary below
   ```

4. **competitive-analysis.md** content:
   ```markdown
   ## Competitive Visual Landscape

   | Competitor | Primary Color | Typography | Layout | Mood |
   |-----------|--------------|------------|--------|------|
   | [Name 1]  | [HEX]       | [Font]     | [Pattern] | [Keywords] |
   | [Name 2]  | [HEX]       | [Font]     | [Pattern] | [Keywords] |
   | [Name 3]  | [HEX]       | [Font]     | [Pattern] | [Keywords] |

   ## Differentiation Opportunities
   - Colors to AVOID (already claimed by competitors): [LIST]
   - Typography gaps (no competitor uses): [LIST]
   - Visual mood white space (unexplored in market): [LIST]

   ## Recommended Differentiation Axis
   [2-3 sentences on how to stand out visually]
   ```

5. **Feed into direction generation**: use `competitive-analysis.md` as input constraint.
   Each of the 3 directions MUST score >= 2/3 on the art-director Differentiation criterion (cannot be mistaken for a competitor).

#### Fallback (no Playwright MCP)

If Playwright is not available, ask the user to describe competitors verbally or provide screenshots manually. Place them in `brandbook-exploration/competitors/`.

### Process

For each direction (informed by competitive analysis), generate:
1. **Mood Board** — 3-5 reference visuals via Nano Banana
2. **Color Palette** — primary, secondary, accent, neutrals with hex codes
3. **Typographic Pairing** — display + body font with rationale
4. **Logo Concept** — use the `design-logo` skill methodology
5. **Visual Style** — illustration, photography, iconography
6. **Sample Application** — a mockup showing the direction in context

#### Prompt template for direction visuals

```
Mood board visual for brand direction "[DIRECTION NAME]".
Style: [STYLE KEYWORDS]. Color palette: [HEX CODES].
Mood: [MOOD KEYWORDS].
Subject: abstract composition representing [BRAND VALUES].
Premium quality, editorial feel. No text. Aspect ratio: 16:9.
```

### Output

Create a `brandbook-exploration/` folder — see [phase-templates.md](phase-templates.md) for `direction.md` templates and the comparison table.

### Direction Selection — Visual Preview

After generating the 3 directions, present them visually using the embedded preview server. See [direction-preview.md](direction-preview.md) for full HTML templates and variable reference.

#### Visual Preview Flow

1. **Write** `brandbook-exploration/directions-overview.html` as a complete, self-contained HTML file.
   Populate the template from `direction-preview.md` with the 3 generated directions (palettes, fonts, mood keywords, taglines, mini mockups).

2. **Start** the embedded preview server:
   ```bash
   skills/brand-pipeline/preview-server.sh start brandbook-exploration/directions-overview.html
   ```
   Returns JSON with the URL. Tell the user to open it in their browser.

3. **Wait** for the user's terminal response (which direction they prefer).

4. **If the user wants a deep dive** on a specific direction → write `direction-N-detail.html` to the same folder using the detail template. Give them the direct URL.

5. **On confirmation** → stop the server:
   ```bash
   skills/brand-pipeline/preview-server.sh stop
   ```
   Continue to Phase 2 with the selected direction.

#### Terminal Fallback

If Python 3 is unavailable (extremely rare), fall back to a terminal-based comparison:

| | Direction 1 | Direction 2 | Direction 3 |
|---|------------|------------|------------|
| **Name** | [NAME_1] | [NAME_2] | [NAME_3] |
| **Mood** | [MOOD_1] | [MOOD_2] | [MOOD_3] |
| **Primary** | [HEX_1] | [HEX_2] | [HEX_3] |
| **Font** | [FONT_1] | [FONT_2] | [FONT_3] |
| **Why** | [ARGUMENT_1] | [ARGUMENT_2] | [ARGUMENT_3] |

<validation_checkpoint phase="1">
**Present to the user**: visual preview in browser (or terminal table as fallback).
**Ask**: "Which direction resonates most with you? I can also mix elements from different directions."
**Wait**: for the user's explicit response before continuing.

**After selection — cleanup unselected directions:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cleanup-selection.sh" \
  --phase direction --selected [N] --project-dir "$(pwd)" --confirm
```
This removes unselected direction folders and preview HTML files. Only the chosen direction, competitive analysis, and competitor screenshots are kept.
</validation_checkpoint>

---

## Phase 2: Final Brandbook

### Trigger
The user has chosen a direction (or a mix) from Phase 1.

### Process (GST-enriched)

Deep dive into the selected direction following the GST Agency methodology:

1. **Symbol decomposition** — describe the logo geometry: shapes, proportions, metaphors, and how the symbol relates to brand values
2. **Construction grid** — generate a parametric SVG grid:
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/construction-grid.mjs" \
     --width [logo-width] --height [logo-height] \
     --ratios "1,1.4,1.5,2.36" \
     --primary-color "[brand.json.colors.primary.hex]" \
     --output brandbook-final/assets/logo/construction-grid.svg
   ```
   RAG enrichment (if available): `bash "${CLAUDE_PLUGIN_ROOT}/scripts/search.sh" "[brand-name]" --category grid --limit 3`
3. **Clear zone** — define protection zone (default: 20% of logo height), generate clear zone SVG
4. **Typography specimen** — explore font pairing: character sets, weight ramps, size comparisons
5. **brand.json generation** — complete machine-readable token file

### Output

```
brandbook-final/
├── README.md          ← Complete brandbook document
├── brand.json         ← Machine-readable tokens (see brand-json-schema.md)
├── assets/
│   ├── logo/          ← All logo versions
│   ├── palette/       ← Palette visuals
│   ├── typography/    ← Typographic specimens
│   └── visuals/       ← Hero, feature, social examples
└── guidelines/        ← Logo, color, typography, imagery usage rules
```

The `brand.json` is the **contract** between all downstream phases. See [brand-json-schema.md](brand-json-schema.md) for the full schema.

<validation_checkpoint phase="2">
**Present**: the brandbook README.md with palette preview, logo versions, typography samples.
**Verify**: `brand.json` is complete (all required schema sections).
**Ask**: "The brandbook is ready. Shall we generate the interactive HTML design application and the 3D proposals?"
**Wait**: for the user's explicit response.
</validation_checkpoint>

---

## Phase 2.5: Interactive HTML Design Application

### Trigger
The user has validated the final brandbook (Phase 2).

### Process
Invoke the `brand-da` skill to generate a professional-grade single-file HTML Design Application.

### Input
- `brand.json` from Phase 2
- Logos generated in `brandbook-final/assets/logo/`

### Output
- `the-[brand-name].html` — Interactive DA with 16 sections (symbol, palette, typography, dark/light components, specifications, landing preview, data-viz/imagery, states, tokens)

### Expected Quality
The file must be openable in a browser and impress an art director within 3 seconds. Standard = Vercel, Linear, Stripe design guidelines.

<validation_checkpoint phase="2.5">
**Present**: open `the-[name].html` in a browser, show a preview of the sections.
**Verify**: CSS variables derived from brand.json, correct fonts, all 16 sections present.
**Ask**: "The design application is generated. Shall we create the 3D logo proposals?"
**Wait**: for the user's explicit response.
</validation_checkpoint>

---

## Phase 2.7: 3D Logo Proposals

### Trigger
The user has validated the HTML DA (Phase 2.5) or wants 3D proposals directly after Phase 2.

### Process
Invoke Phase 4.5 of the `design-logo` skill to generate cinematic 3D renders of the validated logo.

### Input
- Approved 2D logo (reference image for style transfer)
- `brand.json` for accent colors
- `userConfig.creative_temperature` for number of variants

### Output
- 3 renders (balanced) or 5 (adventurous) in a temporary folder
- Comparative presentation with material, mood, recommended usage

<validation_checkpoint phase="2.7">
**Present**: comparative table of 3D renders (material, mood, usage recommendation).
**Ask**: "Which 3D render(s) do you want to keep? We can also refine a style."
**Wait**: for the user's explicit response.

**After selection — cleanup unselected 3D renders:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cleanup-selection.sh" \
  --phase 3d --selected "3d-premium,3d-luminous" --project-dir "$(pwd)" --confirm
```
Only the selected 3D renders are kept. This ensures the branding/ folder stays clean.
</validation_checkpoint>

---

## Phase 3: Brand Export

### Trigger
The user has validated the 3D renders (Phase 2.7) or wants to export directly after Phase 2.5.

### Process
Invoke the `brand-export` skill to compile all assets into a `branding/` folder at the project root.

### Input
- `brand.json`
- Approved 2D logo + selected 3D direction
- Generated HTML DA

### Output
The complete `branding/` folder as defined in the `brand-export` skill:
- logos/ (8 variants: flat dark/light, mono, lockup, app-icons, favicon, SVG)
- 3d/ (3-5 cinematic renders)
- social/ (OG image, avatar)
- brand-tokens.css + tailwind.preset.ts
- the-[name].html
- README.md

<validation_checkpoint phase="3">
**Present**: file tree of the `branding/` folder with the list of all generated files.
**Verify**: all assets are present, no placeholders, brand-tokens.css is complete.
**Run coherence check before presenting:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/brand-coherence-check.sh" \
  --brand branding/brand.json --branding-dir branding/
```
Fix any errors before presenting to the user. Warnings are acceptable.
**Ask**: "The branding is complete. Do you want the React landing page? Or the social media carousels?"
**Wait**: for the user's explicit response.
</validation_checkpoint>

---

## Phase 4: React Landing Page

### Trigger
The user has validated the branding export (Phase 3) and wants a landing page.

### Pre-condition
Verify that `branding/brand.json` and `branding/brand-tokens.css` exist. If missing, redirect to Phase 3.

### Process

Generate a production-ready landing page using:
- `branding/brand.json` and `branding/brand-tokens.css` from Phase 3 as sources
- The `brand-visuals` skill for hero/feature images
- Cross-plugin skills `craftsman:component` and `frontend-design:frontend-design` if available
- React 19 + TypeScript + Tailwind CSS + `branding/tailwind.preset.ts`

### Implementation Rules

1. **Import `branding/tailwind.preset.ts`** into `tailwind.config.ts`
2. **Import `branding/brand-tokens.css`** into global CSS
3. **Generate visuals** via `brand-visuals`
4. **Build components** — each section is a standalone React component
5. **Responsive by default** — mobile-first, sm/md/lg/xl breakpoints
6. **Accessible** — semantic HTML, ARIA labels, WCAG AA contrast ratios
7. **No hardcoded colors** — everything via CSS tokens or Tailwind classes

### Sections

| Section | Content | Component |
|---------|---------|-----------|
| Hero | Headline + tagline + CTA + hero image | `Hero.tsx` |
| Features | 3-4 features with icons/illustrations | `Features.tsx` |
| Social Proof | Testimonials or logos | `Testimonials.tsx` |
| Pricing | Plan comparison (if applicable) | `Pricing.tsx` |
| CTA | Final call-to-action | `CTA.tsx` |
| Footer | Links + legal + socials | `Footer.tsx` |

<validation_checkpoint phase="4">
**Present**: screenshot or preview of created components, applied palette, responsive preview.
**Verify**: all CSS tokens are derived from `branding/brand-tokens.css`, no hardcoded colors.
**Ask**: "The landing page is ready. Do you want the complete design system for your dev team?"
**Wait**: for the user's explicit response.
</validation_checkpoint>

---

## Phase 5: Design System Book

### Trigger
The user has validated the landing page from Phase 4.

### Process

Create comprehensive design system documentation. See [phase-templates.md](phase-templates.md) for token file formats, component docs, and Tailwind preset.

Use the cross-plugin skill `craftsman:component` if available for component scaffolding.

### Output

```
design-system/
├── README.md              ← Overview + quick start
├── tokens/                ← Color, typography, spacing, shadows, radii tokens (.ts)
├── components/            ← Button, Card, Input, Badge, Typography with stories.md
├── patterns/              ← Layout, forms, navigation, feedback patterns
├── guidelines/            ← Accessibility, responsive, animation, dark mode
└── tailwind.preset.ts     ← Shareable Tailwind preset
```

<validation_checkpoint phase="5">
**Present**: list of tokens, documented components, Tailwind preset.
**Verify**: each component has props documentation and variants.
**Ask**: "The design system is ready. Shall we generate the social media carousels for acquisition?"
**Wait**: for the user's explicit response.
</validation_checkpoint>

---

## Phase 6: Social Media Carousels

### Trigger
The user has validated the design system from Phase 5 (or wants to generate carousels directly after Phase 3).

### Process

Use the `social-carousels` skill with `brand.json` as the source of truth to:
1. **Define topics** — what acquisition themes for the brand?
2. **Generate carousels** — copywriting + Nano Banana visuals consistent with the DA
3. **Export** — as editable Canva frames (.pptx) or Figma

### Recommended Acquisition Topics

Suggest 3-5 carousel topics to the user based on:
- Brand positioning (from the Phase 1 brief)
- Target audience pain points
- Brand values and expertise

### Carousel Generation Scripts

After copywriting is complete (copy.md + carousel.json), generate branded HTML and editable PPTX using the built-in scripts — **do NOT create generation scripts in the client's project**:

```bash
# Generate branded HTML slides (self-contained, previewable in browser)
node "${CLAUDE_PLUGIN_ROOT}/scripts/generate-carousel-html.mjs" \
  --brand branding/brand.json \
  --carousel carousels/carousel-[topic]/carousel.json \
  --copy carousels/carousel-[topic]/copy.md \
  --output carousels/carousel-[topic]/slides.html

# Generate editable PPTX (for Canva import or Gamma template creation)
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/generate-carousel-pptx.py" \
  --brand branding/brand.json \
  --carousel carousels/carousel-[topic]/carousel.json \
  --copy carousels/carousel-[topic]/copy.md \
  --output carousels/carousel-[topic]/carousel-export.pptx
```

**Gamma template workflow (recommended for scale):**
1. Generate PPTX with the script above
2. User imports PPTX into Gamma and customizes if needed
3. User saves as Gamma template
4. Future carousels generated via Gamma API `POST /generations/from-template`

### Output

Each carousel produces:
```
carousels/
├── carousel-[topic]/
│   ├── slides/            ← 10 PNG screenshots (via Playwright)
│   ├── slides.html        ← Branded HTML (generated by plugin script)
│   ├── carousel-export.pptx  ← Editable PPTX (generated by plugin script)
│   ├── copy.md            ← Text for each slide
│   └── carousel.json      ← Structured payload
```

---

## Orchestration Rules

### Phase Transitions

```
[Phase 1] ─► [Phase 2] ─► [Phase 2.5] ─► [Phase 2.7] ─► [Phase 3] ─► [Phase 4] ─► [Phase 5] ─► [Phase 6]
EXPLORE      DEFINE       DA HTML        3D LOGOS       EXPORT       BUILD        DOCUMENT      ACQUIRE
    │            │            │              │              │            │             │             │
    ▼            ▼            ▼              ▼              ▼            ▼             ▼             ▼
brandbook-   brandbook-   the-[name]    logos/3d/       branding/    src/landing/  design-       carousels/
exploration/ final/       .html         3-5 renders     complete     + components  system/       slides+.pptx
             +brand.json                                +tokens+DA
```

### Data Flow

1. Phase 1 → `direction.md` with palettes and concepts
2. Phase 2 → `brand.json` (single source of truth)
3. Phase 2.5 → `the-[name].html` (interactive DA from brand.json)
4. Phase 2.7 → 3D renders (style transfer from 2D logo + brand.json.colors)
5. Phase 3 → Complete `branding/` (logos, 3D, CSS tokens, Tailwind preset, DA, README)
6. Phase 4 → React landing page (from branding/brand-tokens.css + tailwind.preset.ts)
7. Phase 5 → Complete design system (from brand.json + Phase 4)
8. Phase 6 → Visually consistent carousels (from brand.json)

### Allowed Shortcuts

| Shortcut | Condition |
|----------|-----------|
| Phase 1 → Phase 3 | If brand.json already exists in the project |
| Phase 2 → Phase 3 | Skip HTML DA + 3D (minimal generation) |
| Phase 3 → Phase 6 | Skip landing + design system, go directly to carousels |
| Phase 2.5 alone | Generate only the HTML DA from an existing brand.json |

### Rules

- **Follow phase order** — each phase validates the assumptions of the previous one
- **brand.json is the contract** — all downstream phases read it
- **User validation is mandatory** — present and explicitly ask
- **Partial execution is OK** — the user can stop at any phase
- **Explicit shortcuts** — if the user wants to skip phases, suggest the shortcuts
- **Existing project integration** — adapt to the existing React structure

<avoid>
- Proceeding without user validation
- Generating without a valid brandbook
- Hardcoding colors instead of using tokens
- Components that don't match brand.json
- Ignoring accessibility in the design system
- Design system without props documentation
- Arbitrary Tailwind values instead of the design token scale
- Visually inconsistent carousels with the DA
- Generating the HTML DA without logos (minimum icon-flat-dark + icon-flat-light)
- Proposing 3D renders without a valid 2D logo as reference
- Exporting branding/ without brand-tokens.css
</avoid>

## Self-check before each phase transition

Before proposing the next phase, verify:
1. All outputs of the current phase are generated and saved
2. `brand.json` is up to date with the latest validated decisions
3. The user has explicitly validated (no implicit approval)
4. Files are organized according to the documented structure
5. If Phase 3 (export): run `brand-coherence-check.sh` and fix errors
6. Unselected assets have been cleaned up (run `cleanup-selection.sh` after each selection)
7. No generation scripts (`.py`, `.mjs`) were left in the client's project — all generation uses plugin scripts
