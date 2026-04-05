# Image Generation API — Multi-Provider Reference

Single reference file for all skills using image generation.
Update this file if an API changes — the `design-logo`, `brand-visuals`, `brand-da`, `brand-export`, and `social-carousels` skills reference it.

## Provider Detection

The provider is configured via `userConfig.image_provider` in the plugin:
- `gemini` (default) → `GEMINI_API_KEY` variable
- `openai` → `OPENAI_IMAGE_KEY` variable

## Pre-flight Check

Before any generation:

```javascript
const provider = process.env.CREATIVE_STUDIO_IMAGE_PROVIDER || "gemini";

if (provider === "gemini" && !process.env.GEMINI_API_KEY) {
  console.error("GEMINI_API_KEY missing. Run /creative:setup-provider");
  process.exit(1);
}
if (provider === "openai" && !process.env.OPENAI_IMAGE_KEY) {
  console.error("OPENAI_IMAGE_KEY missing. Run /creative:setup-provider");
  process.exit(1);
}
```

---

## Gemini (Nano Banana)

### Models

| Model | API ID | Usage | Free tier |
|-------|--------|-------|-----------|
| Nano Banana 2 (Flash) | `gemini-3.1-flash-image-preview` | Rapid iteration, exploration | ~500/day |
| Nano Banana Pro | `gemini-3-pro-image-preview` | Final 4K assets, text in image | ~3/day |

**Rule**: Flash for iteration, Pro only for the final asset or when text is required in the image.

### Simple generation

```javascript
import { GoogleGenAI } from "@google/genai";
import fs from "fs";

const client = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const response = await client.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: [{ parts: [{ text: PROMPT }] }],
  config: { responseModalities: ["TEXT", "IMAGE"] }
});

const parts = response.candidates?.[0]?.content?.parts || [];
for (const part of parts) {
  if (part.inlineData) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    fs.writeFileSync(`${OUTPUT_DIR}/${FILENAME}.png`,
      Buffer.from(part.inlineData.data, "base64"));
  }
}
```

### Style Transfer (reference image)

```javascript
const ref = fs.readFileSync(REFERENCE_IMAGE_PATH);
const response = await client.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: [{
    parts: [
      { inlineData: { mimeType: "image/png", data: ref.toString("base64") } },
      { text: PROMPT }
    ]
  }],
  config: { responseModalities: ["TEXT", "IMAGE"] }
});
```

### Gemini Rate Limits
- Flash: ~500 images/day (free tier)
- Pro: ~3 images/day (free tier)
- Recommended delay between requests: 2-3 seconds

---

## OpenAI (gpt-image-1 / DALL-E 3)

### Models

| Model | Usage | Pricing |
|-------|-------|---------|
| `gpt-image-1` | High quality, realistic or artistic style, editing | Paid — ~$0.04-0.19/image depending on size |
| `dall-e-3` | High quality, natural prompt, varied styles | Paid — ~$0.04-0.12/image depending on size |

**Rule**: `gpt-image-1` by default (better control), `dall-e-3` for highly descriptive prompts.

### Simple generation

```javascript
import OpenAI from "openai";
import fs from "fs";

const client = new OpenAI({ apiKey: process.env.OPENAI_IMAGE_KEY });

const response = await client.images.generate({
  model: "gpt-image-1",
  prompt: PROMPT,
  n: 1,
  size: "1024x1024",
  quality: "high"
});

// Download from URL
const imageUrl = response.data[0].url;
const imageResponse = await fetch(imageUrl);
const buffer = Buffer.from(await imageResponse.arrayBuffer());
fs.mkdirSync(OUTPUT_DIR, { recursive: true });
fs.writeFileSync(`${OUTPUT_DIR}/${FILENAME}.png`, buffer);
```

### Base64 generation (no temporary URL)

```javascript
const response = await client.images.generate({
  model: "gpt-image-1",
  prompt: PROMPT,
  n: 1,
  size: "1024x1024",
  quality: "high",
  response_format: "b64_json"
});

fs.writeFileSync(`${OUTPUT_DIR}/${FILENAME}.png`,
  Buffer.from(response.data[0].b64_json, "base64"));
```

### Style Transfer (image editing)

```javascript
const response = await client.images.edit({
  model: "gpt-image-1",
  image: fs.createReadStream(REFERENCE_IMAGE_PATH),
  prompt: PROMPT,
  n: 1,
  size: "1024x1024"
});
```

### Available OpenAI sizes

| Size | Usage |
|------|-------|
| `1024x1024` | Logo, social, icon (default) |
| `1536x1024` | Landscape, hero, banner |
| `1024x1536` | Portrait, story |
| `auto` | Let the model choose |

### OpenAI Rate Limits
- Tier-dependent (5-200 images/minute depending on plan)
- Paid only — no free tier for image generation

---

## Prompt Templates — By Asset Type

Each asset type has specific compositional requirements. **Never use a generic "Premium quality" prompt** — use the asset-specific template below.

### Hero Image

```
Hero illustration for [BRAND] landing page.
Subject: [DESCRIPTION — abstract 3D shapes, product mockup, or concept visualization].
Color palette: primary [HEX_PRIMARY], secondary [HEX_SECONDARY], accent [HEX_ACCENT].
Background: gradient from [HEX_BG_DARK] to [HEX_BG_MEDIUM].
Style: [KEYWORDS from brand.json.style.keywords]. Clean, editorial.
Composition: 40% left area empty for headline overlay. Key visual anchored right.
  Negative space: >= 35% of frame. No clutter.
Lighting: soft directional from top-left at 45°, subtle ambient fill.
Depth of field: shallow (f/2.8 equivalent), foreground sharp, background softly blurred.
Format: 16:9 (1536x1024). No text, no watermark, no border.
```

### Feature / Section Image

```
Feature illustration for [BRAND] — representing [FEATURE_CONCEPT].
Subject: [DESCRIPTION — icon-scale visual, single concept, not a scene].
Color palette: [HEX_PRIMARY] dominant, [HEX_ACCENT] for highlights.
Background: solid [HEX_BG] or transparent.
Style: [KEYWORDS]. Minimal, geometric, icon-like.
Composition: centered subject, square framing, 20% padding on all sides.
Lighting: flat, even, no dramatic shadows. Clean silhouette.
Scale: must read clearly at 64x64px and 512x512px.
Format: 1:1 (1024x1024). No text, no watermark.
```

### Social Media Asset (OG / Avatar)

```
Social media visual for [BRAND].
Subject: [DESCRIPTION — brand symbol or abstract representation].
Color palette: [HEX_PRIMARY] background, [HEX_ACCENT] for focal element.
Style: bold, high-contrast, recognizable at thumbnail size.
Composition: centered focal point, no edge-critical content (safe zone: inner 80%).
  Avatar variant: must work in circle crop (keep content within center 70%).
Lighting: high contrast, studio-style, clean edges.
Format: OG 1200x630 (landscape) or Avatar 512x512 (square). No text, no watermark.
```

### 3D Logo Render

```
Take this exact 2D logo and create a cinematic 3D render.
Keep the EXACT same geometry and proportions — do not redesign the shape.
Material: [MATERIAL_SPEC — see material table below].
Surface finish: [FINISH — satin, polished, matte, frosted].
Color accent: [HEX_PRIMARY] applied ONLY to edges, bevels, or inset details.
Lighting: 3-point studio setup — key light top-right at 60° (warm white),
  fill light left at 30° (cool, 40% intensity), rim light behind (accent color, 20%).
Background: [BG_SPEC — pure black void / dark gradient / studio backdrop].
Camera: centered, eye-level, slight 15° upward tilt for monumentality.
Depth of field: f/4 — logo sharp, background falls off smoothly.
Composition: logo fills 60% of frame, 20% breathing room on each side.
Render quality: photorealistic, 8K detail, no noise, no lens flare, no glow.
Format: 1:1 (1024x1024). No text.
```

### Mascot / Brand Character

```
Brand mascot for [BRAND] in the [INDUSTRY] sector.
Character concept: [DESCRIPTION — animal, abstract figure, anthropomorphic object].
Personality traits: [3-5 TRAITS matching brand values — e.g., friendly, precise, bold].
Color palette: primary [HEX_PRIMARY] as dominant body color,
  [HEX_ACCENT] for accessories or highlights, [HEX_SECONDARY] for details.
Style: [STYLE — flat vector / 3D rendered / hand-drawn / pixel art].
  Consistent line weight: [WEIGHT — 2px for flat, n/a for 3D].
Expression: [EXPRESSION — confident smile, curious tilt, focused determination].
Pose: [POSE — standing front 3/4 view, waving, pointing, working at desk].
Background: transparent or solid [HEX_BG].
Scalability: must read as silhouette at 32x32px (simple, recognizable shape).
Format: 1:1 (1024x1024). No text, no watermark.
```

### Carousel Slide Visual

```
Carousel slide visual for [BRAND] — slide [N]/10: [SLIDE_TOPIC].
Subject: [DESCRIPTION — concept illustration matching the slide's message].
Color palette: [HEX_PRIMARY] dominant, [HEX_BG] background.
Style: [KEYWORDS]. Consistent with slide 1 reference style.
Composition: vertical (9:16 or 4:5). Content in center 70% (safe zone for text overlay).
  Top 25%: reserved for headline text (keep empty or very subtle).
  Bottom 15%: reserved for CTA or page number.
Lighting: consistent with slide 1 — [LIGHTING_FROM_SLIDE_1].
Visual continuity: maintain same color temperature, object scale, and style as previous slides.
Format: [RATIO — 1080x1350 for Instagram, 1080x1080 for LinkedIn]. No text, no watermark.
```

## Provider-specific adaptations

### Gemini — prompt specifics
- Include hex codes directly (good color matching)
- Style transfer = best tool for series consistency
- Concise, structured prompts
- Specify "No text in image" explicitly
- Add "No watermark. No border." to avoid artifacts

### OpenAI — prompt specifics
- More natural, detailed descriptions
- Specify dimensions via the API (not in the prompt)
- Responds well to detailed art direction
- gpt-image-1: prefers precise instructions
- DALL-E 3: prefers natural descriptive language
- Add "Professional quality, photorealistic" for premium rendering

---

## 3D Logo Rendering — Material Specifications

Use the **3D Logo Render** template from the asset-type prompts above. Replace `[MATERIAL_SPEC]` and `[FINISH]` with the values from these tables.

### 3 Standard materials (creative_temperature: balanced)

| Style | Material | Finish | Reflectivity | Lighting Override | Background |
|-------|----------|--------|-------------|-------------------|------------|
| Premium | Polished titanium alloy (Ti-6Al-4V appearance) | Satin to mirror — 85% specular | High: sharp edge reflections, soft body | Key light: warm white 5600K, fill: cool blue 7500K at 30% | Pure black (#000) void, no floor reflection |
| Architectural | Micro-textured dark concrete (exposed aggregate, 0.5mm grain) | Matte — 15% specular, high diffuse | Low: absorbs light, subtle edge catch | Single directional from top-left, hard shadows, no fill | Dark charcoal (#111) seamless backdrop |
| Luminous | Frosted borosilicate glass (2mm thickness, 60% transmission) | Frosted — internal subsurface scattering | Medium: glass catches environment, interior glows | Rim light only (accent color at 40%), interior emission [HEX_PRIMARY] at 60% | Dark studio, no visible floor, floating |

### 5 Experimental materials (creative_temperature: adventurous)

The 3 above PLUS:

| Style | Material | Finish | Reflectivity | Lighting Override | Background |
|-------|----------|--------|-------------|-------------------|------------|
| Liquid | Chrome liquid metal (mercury viscosity, high surface tension) | Mirror — 95% specular, warped reflections | Very high: environment map distorted by surface curvature | High-contrast 2-point: key hard white, rim hard accent color | Deep black (#000) gradient to #0a0a0a at edges |
| Holographic | Dichroic glass film (thin-film interference, 380-780nm range) | Semi-gloss — angle-dependent color shift | Variable: rainbow spectrum shifts with viewing angle | Soft diffused dome light (white 5000K), no hard shadows | Dark (#0a0a0f) with subtle prismatic caustics on ground plane |

---

## Fallback Strategy

1. **Simplify the prompt** — remove hex codes, keep 3 style keywords max
2. **Reduce complexity** — solid background + centered subject
3. **Switch model** — Flash → Pro (Gemini) or dall-e-3 → gpt-image-1 (OpenAI)
4. **Document** — save the detailed prompt in `visual-brief.md` for manual generation

## Reference Variables

| Variable | Source | Example |
|----------|--------|---------|
| `PROMPT` | Built by the skill | See template above |
| `OUTPUT_DIR` | Defined by the skill | `branding/logos/`, `branding/3d/`, `visuals/` |
| `REFERENCE_IMAGE_PATH` | Previously validated image | `branding/logos/icon-flat-dark.png` |
| `HEX CODES` | `brand.json.colors` | `#7c3aed primary, #6d28d9 dark` |
| `FILENAME` | Skill pattern | `icon-flat-dark`, `3d-premium`, etc. |
