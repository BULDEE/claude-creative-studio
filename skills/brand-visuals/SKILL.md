---
name: brand-visuals
description: Generates branded visuals (hero images, illustrations, banners, OG images) via Gemini (Nano Banana) or OpenAI (gpt-image-1). Automatically detects the current project's DA via Tailwind config, CSS variables, brand.json, or CLAUDE.md. Triggered by 'visual', 'hero image', 'illustration', 'banner', 'OG image', 'brand asset', 'Nano Banana', 'branded visual', 'generate image'.
argument-hint: [asset-type] [subject]
---

# Branded Visuals — Multi-Provider Image Generation

Generates visuals consistent with the current project's visual identity.

## Prerequisites

- Provider configured via `userConfig.image_provider`:
  - `gemini` (default) → `GEMINI_API_KEY` required — free key: https://aistudio.google.com/apikey
  - `openai` → `OPENAI_IMAGE_KEY` required
- If key is missing → redirect to `/creative:setup-provider`
- Full API reference: see [image-provider-reference.md](../image-provider-reference.md)

## Available models

### Gemini (Nano Banana)
| Model | API ID | Usage | Free tier |
|-------|--------|-------|-----------|
| Flash | `gemini-3.1-flash-image-preview` | Rapid iteration | ~500/day |
| Pro | `gemini-3-pro-image-preview` | Final 4K assets | ~3/day |

### OpenAI
| Model | Usage | Pricing |
|-------|-------|---------|
| `gpt-image-1` | High quality, precise control | ~$0.04-0.19/image |
| `dall-e-3` | Natural prompt, varied styles | ~$0.04-0.12/image |

**Default**: Flash (Gemini) or gpt-image-1 (OpenAI) for iteration.

## Automatic DA detection

Detect the project context rather than using a hardcoded palette.

### Resolution order (most specific to most general)

1. **`brand.json`** or `brand.yaml` at the project root or `.claude/`
2. **`tailwind.config.*`** → extract `theme.extend.colors`
3. **CSS custom properties** → scan root CSS files for `--color-primary`, etc.
4. **`.claude/CLAUDE.md`** of the project → look for mentions of palette, colors, style
5. **`package.json`** → the `name` and `description` fields give product context
6. **Ask the user** → if no source is found

**Always display the detected palette and ask for validation before generating.**

### Recommended brand.json format

```json
{
  "name": "MyProduct",
  "tagline": "Short description",
  "colors": {
    "primary": "#6366F1",
    "secondary": "#8B5CF6",
    "accent": "#06B6D4",
    "background": "#0F172A",
    "surface": "#F8FAFC"
  },
  "style": {
    "keywords": ["modern", "clean", "premium"],
    "mood": ["professional", "innovative"],
    "avoid": ["clipart", "stock-photo", "cartoon"]
  }
}
```

## Workflow

### 1. Detect the DA
Follow the resolution order above. Display the detected palette.

### 2. Define the brief
- **Asset type**: hero, feature, OG image, social, banner
- **Subject**: what the image should represent
- **Dimensions**: 16:9 (hero), 1:1 (social), 1200x630 (OG)

### 3. Build the prompt

```
[TYPE] for [PRODUCT].
Subject: [DESCRIPTION].
Style: [BRAND KEYWORDS].
Palette: [HEX CODES].
Mood: [MOOD].
Composition: [LAYOUT].
Format: [RATIO].
No text unless explicitly requested. Premium quality.
```

### 4. Generate

Use the configured provider. See [image-provider-reference.md](../image-provider-reference.md) for complete code for each provider.

**Gemini**: `client.models.generateContent()` with `responseModalities: ["TEXT", "IMAGE"]`
**OpenAI**: `client.images.generate()` with `response_format: "b64_json"` or URL

### 5. Iterate with reference

For series consistency, send a validated image as reference:

**Gemini**: style transfer via `inlineData` in `contents.parts[]`
**OpenAI**: `client.images.edit()` with `image` stream

See detailed patterns in [image-provider-reference.md](../image-provider-reference.md#style-transfer-image-de-reference).

## Asset types

| Type | Ratio | Composition |
|------|-------|-------------|
| Hero | 16:9 / 21:9 | 40% space for text overlay, high-impact |
| Feature | 1:1 / 4:3 | Centered subject, clean background, one concept |
| OG Image | 1200x630 | Readable at small size, text via Pro |
| Social | 1:1 / 16:9 | Eye-catching, brand-consistent |
| Banner | variable | High contrast, minimal elements |

## Standards

- **Iterate**: 3-5 variants minimum, select, refine
- **Consistency**: once a style is validated, use it as reference for the rest
- **No text by default**: unless explicitly requested
- **Color fidelity**: always include hex codes in the prompt

## Fallback if generation fails

If generation fails (quota, API error, non-conforming image):
1. **Simplify the prompt** — remove hex codes, keep 3 style keywords max
2. **Reduce complexity** — request a simpler composition (solid background + centered subject)
3. **Switch model** — Flash → Pro (Gemini) or dall-e-3 → gpt-image-1 (OpenAI)
4. **If still failing** — document the detailed prompt in a `visual-brief.md` file for manual generation

<avoid>
- Hardcoded palette without checking project context
- Generic stock-photo visuals
- Inconsistent style across pages
- Text in images without Nano Banana Pro
- Generating without a brief
- Hardcoded API keys
</avoid>

<example>
**Brief**: Hero image for a fintech, brand.json palette detected (#6366F1, #8B5CF6, #06B6D4)

**Built prompt**:
```
Hero image for fintech landing page.
Style: modern, clean, premium. Abstract 3D shapes and gradients.
Color palette: #6366F1 primary, #8B5CF6 secondary, #06B6D4 accent.
Mood: professional, innovative, trustworthy.
Composition: 40% left for text overlay, key visual right.
Format: 16:9. No text. Premium quality.
```

**Self-check**: faithful palette, sufficient text space, no text in image, mood consistent with brand.json keywords.
</example>

## Self-check before delivery

Before presenting a visual, verify:
1. The palette used matches the hex codes from `brand.json` or the detected source
2. The style respects the defined keywords and mood
3. There is no text in the image (unless explicitly requested + Pro is used)
4. The text overlay space is sufficient (40% minimum for hero/social)
5. The visual works at the requested ratio
