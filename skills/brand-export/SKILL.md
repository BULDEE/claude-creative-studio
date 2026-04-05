---
name: brand-export
description: Exports the complete brandbook into a branding/ folder — logos (flat, lockup, mono, app-icons), 3D renders, social assets, brand-tokens.css, tailwind.preset.ts, interactive DA HTML, favicon.ico, icon.svg, README. Triggered by 'brand export', 'export branding', 'generate assets', 'branding folder', 'export brand', 'compile brand', 'export DA'.
argument-hint: [brand-name]
---

# Brand Export — Complete Branding Folder

You are a **Brand Production Manager** who compiles all brand assets into a ready-to-use folder.

## Prerequisites

- Valid `brand.json` (Phase 2 of the pipeline completed)
- At least one 2D logo generated
- `GEMINI_API_KEY` or `OPENAI_IMAGE_KEY` configured (see `userConfig.image_provider`)
- API reference: see [image-provider-reference.md](../image-provider-reference.md)

## Output Structure

```
branding/
├── brand.json                      ← Source of truth (copied from brandbook-final/)
├── the-[name].html                 ← Interactive DA (generated via brand-da)
├── brand-tokens.css                ← CSS custom properties
├── tailwind.preset.ts              ← Shareable Tailwind preset
├── logos/
│   ├── icon-flat-dark.png          ← White logo on dark background
│   ├── icon-flat-light.png         ← Color logo on white background
│   ├── icon-mono-black.png         ← Black monochrome
│   ├── icon-mono-white.png         ← White monochrome
│   ├── lockup-dark.png             ← Logo + name, dark background
│   ├── lockup-light.png            ← Logo + name, light background
│   ├── app-icon-ios.png            ← iOS app icon (rounded square, gradient)
│   ├── app-icon-chrome.png         ← Chrome/PWA icon (rounded, small)
│   ├── favicon.ico                 ← Multi-resolution (16/32/48)
│   └── icon.svg                    ← Vector SVG logo
├── 3d/
│   ├── 3d-premium.png              ← Premium material render (obsidian/titanium)
│   ├── 3d-architectural.png        ← Raw material render (concrete/basalt)
│   └── 3d-luminous.png             ← Frosted glass / neon render
├── social/
│   ├── og-image-1200x630.png       ← Open Graph / Twitter Card
│   └── avatar-square-512.png       ← Social media avatar
└── README.md                       ← Quick usage guide
```

If `creative_temperature: adventurous` → add `3d/3d-liquid.png` and `3d/3d-holographic.png`.

## Export Workflow

### Phase 1: Input validation

```
1. Verify that brand.json exists and is complete
2. Verify that the image provider is configured
3. Create the branding/ folder and its subfolders
4. Copy brand.json into branding/
```

### Phase 2: Logo generation

Generate logo variants using the configured provider.

**Prompts for each variant** (adapt from brand.json):

#### icon-flat-dark
```
Minimalist flat vector logo mark: [LOGO_DESCRIPTION from brand.json.logo.concept].
Solid white logo on very dark background ([BG_COLOR]).
Clean flat design, no 3D, no gradients, no effects. Pure geometric vector.
Centered in frame. Icon only, no text. Premium SaaS quality.
```

#### icon-flat-light
```
Minimalist flat vector logo mark: [LOGO_DESCRIPTION].
Solid [PRIMARY_COLOR] logo on pure white background.
Clean flat design, no 3D, no gradients, no effects.
Centered. Icon only. Premium quality.
```

#### icon-mono-black
```
Minimalist monochrome logo mark: [LOGO_DESCRIPTION].
Solid black on white background. No gradients, no effects.
Pure geometric construction. Icon only. Works for print and watermarks.
```

#### icon-mono-white
```
Minimalist monochrome logo mark: [LOGO_DESCRIPTION].
Solid white on transparent/black background. No gradients, no effects.
Pure geometric construction. Icon only.
```

#### lockup-dark
```
Professional horizontal logo lockup: [LOGO_DESCRIPTION] icon + "[BRAND_NAME]" wordmark.
White icon, white "[BRAND_NAME]" text in [FONT_PRIMARY] font, [FONT_WEIGHT] weight.
On dark background ([BG_COLOR]). Horizontal layout. Premium SaaS brand.
```

#### lockup-light
```
Professional horizontal logo lockup: [LOGO_DESCRIPTION] icon + "[BRAND_NAME]" wordmark.
[PRIMARY_COLOR] icon, dark text ([TEXT_COLOR]) in [FONT_PRIMARY] font.
On pure white background. Horizontal layout. Premium quality.
```

#### app-icon-ios
```
iOS app icon design: rounded square (iOS style) containing [LOGO_DESCRIPTION].
Background gradient from [PRIMARY_DARK] to [PRIMARY_COLOR].
White symbol centered with proper iOS padding. Bold, recognizable at small sizes.
No text. Apple App Store quality.
```

#### app-icon-chrome
```
Chrome extension icon: small rounded square containing [LOGO_DESCRIPTION].
Background [BG_COLOR]. White mark with subtle [PRIMARY_COLOR] glow.
Clear at 48x48px. Bold, simple. No text. Chrome Web Store quality.
```

**Delay between each generation**: 2-3 seconds (respect rate limits).

### Phase 3: 3D generation

Use the `icon-flat-dark.png` logo as the **reference image** for style transfer.

Generate 3D renders based on `userConfig.creative_temperature`:
- `conservative`: 3 variants of the same material (nuances)
- `balanced` (default): 3 different materials (premium, architectural, luminous)
- `adventurous`: 5 materials (the 3 above + liquid + holographic)

**See 3D prompts in [image-provider-reference.md](../image-provider-reference.md)**.

For each render:
1. Load `branding/logos/icon-flat-dark.png` as reference
2. Apply the 3D prompt with style transfer
3. Save to `branding/3d/`

### Phase 4: Social assets

#### og-image-1200x630
```
Professional Open Graph image for [BRAND_NAME] — [TAGLINE].
[LOGO_DESCRIPTION] centered with brand name underneath.
Style: [STYLE_KEYWORDS]. Color palette: [PRIMARY] and [BG_COLOR].
Dimensions: 1200x630. Clean, minimal, high contrast. Professional quality.
```

**OpenAI size**: `1536x1024` (crop to 1200x630)
**Gemini size**: specify in the prompt "Aspect ratio 1200:630"

#### avatar-square-512
Reuse `app-icon-chrome.png` resized or generate:
```
Square avatar icon for social media profiles. [LOGO_DESCRIPTION].
[PRIMARY_COLOR] mark on [BG_COLOR] background. 512x512. Bold, recognizable.
```

### Phase 5: Technical tokens

#### brand-tokens.css

```css
/* Brand Tokens — Generated from brand.json */
/* Source: branding/brand.json */
/* Do not edit manually — regenerate via /creative:brand-export */

:root {
  /* Colors — Primary */
  --color-primary: [PRIMARY_HEX];
  --color-primary-dark: [PRIMARY_DARK_HEX];
  --color-primary-light: [PRIMARY_LIGHT_HEX];

  /* Colors — Neutral */
  --color-bg: [BG_HEX];
  --color-surface: [SURFACE_HEX];
  --color-surface-raised: [SURFACE_RAISED_HEX];
  --color-text: [FOREGROUND_HEX];
  --color-text-secondary: [SECONDARY_HEX];
  --color-text-muted: [MUTED_HEX];

  /* Colors — Accent */
  --color-success: [SUCCESS_HEX];
  --color-warning: [WARNING_HEX];
  --color-error: [ERROR_HEX];
  --color-info: [INFO_HEX];

  /* Colors — Border */
  --color-border: [BORDER_DEFAULT];
  --color-border-hover: [BORDER_HOVER];

  /* Typography */
  --font-primary: '[FONT_PRIMARY]', system-ui, sans-serif;
  --font-mono: '[FONT_MONO]', ui-monospace, monospace;

  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
  --space-12: 48px;
  --space-16: 64px;
  --space-24: 96px;
  --space-32: 128px;

  /* Border Radius */
  --radius-sm: [SM];
  --radius-md: [MD];
  --radius-lg: [LG];
  --radius-xl: [XL];
  --radius-2xl: [2XL];
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: [SM_SHADOW];
  --shadow-md: [MD_SHADOW];
  --shadow-lg: [LG_SHADOW];
  --shadow-xl: [XL_SHADOW];

  /* Motion */
  --duration-fast: [FAST]ms;
  --duration-normal: [NORMAL]ms;
  --duration-slow: [SLOW]ms;
  --ease-default: [EASE_DEFAULT];
  --ease-in: [EASE_IN];
  --ease-out: [EASE_OUT];
}
```

#### tailwind.preset.ts

```typescript
import type { Config } from "tailwindcss";

const brandPreset = {
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "[PRIMARY_HEX]",
          dark: "[PRIMARY_DARK]",
          light: "[PRIMARY_LIGHT]",
          // ... all shades from brand.json
        },
        surface: {
          DEFAULT: "[SURFACE]",
          raised: "[SURFACE_RAISED]",
        },
        border: {
          DEFAULT: "[BORDER_DEFAULT]",
          hover: "[BORDER_HOVER]",
        },
      },
      fontFamily: {
        sans: ["[FONT_PRIMARY]", "system-ui", "sans-serif"],
        mono: ["[FONT_MONO]", "ui-monospace", "monospace"],
      },
      borderRadius: {
        sm: "[SM]",
        md: "[MD]",
        lg: "[LG]",
        xl: "[XL]",
        "2xl": "[2XL]",
      },
      // spacing, shadows, motion from brand.json
    },
  },
} satisfies Partial<Config>;

export { brandPreset };
```

### Phase 6: DA HTML

Invoke the `brand-da` skill to generate `the-[name].html` in `branding/`.

### Phase 7: README

Generate `branding/README.md`:

```markdown
# [BRAND NAME] — Brand Assets

Generated by claude-creative-studio v0.10.0.

## Quick Start

### CSS Tokens
\`\`\`html
<link rel="stylesheet" href="brand-tokens.css">
\`\`\`

### Tailwind
\`\`\`typescript
// tailwind.config.ts
import { brandPreset } from "./branding/tailwind.preset";
export default { presets: [brandPreset], /* ... */ };
\`\`\`

### DA Interactive
Open `the-[name].html` in any browser.

## Assets

| Asset | Path | Usage |
|-------|------|-------|
| Logo (dark bg) | logos/icon-flat-dark.png | Dark backgrounds |
| Logo (light bg) | logos/icon-flat-light.png | Light backgrounds |
| Lockup (dark) | logos/lockup-dark.png | Headers, navbars |
| Lockup (light) | logos/lockup-light.png | Light layouts |
| Mono black | logos/icon-mono-black.png | Print, watermarks |
| Mono white | logos/icon-mono-white.png | Overlays, dark bg |
| iOS icon | logos/app-icon-ios.png | App Store |
| Chrome icon | logos/app-icon-chrome.png | Extensions, PWA |
| Favicon | logos/favicon.ico | Browser tab |
| SVG | logos/icon.svg | Scalable vector |
| 3D Premium | 3d/3d-premium.png | Hero, presentations |
| 3D Architectural | 3d/3d-architectural.png | Hero alt |
| 3D Luminous | 3d/3d-luminous.png | Creative, social |
| OG Image | social/og-image-1200x630.png | Social sharing |
| Avatar | social/avatar-square-512.png | Social profiles |

## Design Tokens

See `brand-tokens.css` for CSS custom properties.
See `tailwind.preset.ts` for Tailwind integration.
See `brand.json` for the canonical source.
```

---

## Orchestration

### Execution order

```
1. Input validation ──► 2. Logos (8 variants)
                                    │
                            ┌───────┴───────┐
                            ▼               ▼
                     3. 3D renders     4. Social assets
                     (3-5 variants)    (OG + avatar)
                            │               │
                            └───────┬───────┘
                                    ▼
                          5. Technical tokens
                          (CSS + Tailwind)
                                    │
                                    ▼
                            6. DA HTML
                            (via brand-da)
                                    │
                                    ▼
                            7. README
```

### Parallelization

Phases 3 and 4 are independent of Phase 2 — launch them in parallel when possible.

### Recovery

If the export fails midway:
- Check which files already exist in `branding/`
- Only regenerate the missing files
- Report to the user which assets were generated and which are missing

---

## Self-check before delivery

1. `branding/brand.json` is present and complete
2. All logos in `branding/logos/` are generated (8 minimum)
3. 3D renders in `branding/3d/` match the `creative_temperature`
4. `brand-tokens.css` has all variables from `brand.json`
5. `tailwind.preset.ts` compiles without TypeScript errors
6. `the-[name].html` opens in a browser
7. `branding/README.md` is generated with the asset table
8. No API keys are hardcoded in the files
9. Relative paths in the DA HTML correctly point to `logos/`
10. The `branding/` folder is self-contained (copy-paste ready)

<avoid>
- API keys in generated files
- Hardcoded colors in brand-tokens.css (everything comes from brand.json)
- Missing files in the output structure
- DA HTML referencing nonexistent external files
- Tailwind preset with values that don't match brand.json
- Incomplete README or README with unfilled placeholders
</avoid>
</output>
