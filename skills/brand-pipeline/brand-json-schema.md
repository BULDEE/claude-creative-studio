# brand.json Schema — Single Source of Truth

The `brand.json` file is the contract between all pipeline phases. Produced in Phase 2, consumed by Phases 3, 4, and 5.

## Full Schema

```json
{
  "name": "[Brand Name]",
  "tagline": "[Tagline]",
  "direction": "[Chosen Direction Name]",
  "colors": {
    "primary": { "hex": "#XXXXXX", "rgb": "R, G, B", "hsl": "H, S%, L%" },
    "secondary": { "hex": "#XXXXXX", "rgb": "R, G, B", "hsl": "H, S%, L%" },
    "accent": { "hex": "#XXXXXX", "rgb": "R, G, B", "hsl": "H, S%, L%" },
    "background": { "hex": "#XXXXXX" },
    "surface": { "hex": "#XXXXXX" },
    "text": {
      "primary": "#XXXXXX",
      "secondary": "#XXXXXX",
      "inverted": "#XXXXXX"
    },
    "semantic": {
      "success": "#XXXXXX",
      "warning": "#XXXXXX",
      "error": "#XXXXXX",
      "info": "#XXXXXX"
    }
  },
  "typography": {
    "display": { "family": "[Font]", "weights": [700, 900], "source": "Google Fonts" },
    "heading": { "family": "[Font]", "weights": [600, 700], "source": "Google Fonts" },
    "body": { "family": "[Font]", "weights": [400, 500, 600], "source": "Google Fonts" },
    "mono": { "family": "[Font]", "weights": [400], "source": "Google Fonts" },
    "scale": {
      "xs": "0.75rem",
      "sm": "0.875rem",
      "base": "1rem",
      "lg": "1.125rem",
      "xl": "1.25rem",
      "2xl": "1.5rem",
      "3xl": "1.875rem",
      "4xl": "2.25rem",
      "5xl": "3rem",
      "6xl": "3.75rem"
    }
  },
  "spacing": {
    "unit": "0.25rem",
    "scale": [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64]
  },
  "borderRadius": {
    "none": "0",
    "sm": "0.25rem",
    "md": "0.5rem",
    "lg": "0.75rem",
    "xl": "1rem",
    "full": "9999px"
  },
  "shadows": {
    "sm": "0 1px 2px rgba(0,0,0,0.05)",
    "md": "0 4px 6px rgba(0,0,0,0.07)",
    "lg": "0 10px 15px rgba(0,0,0,0.1)",
    "xl": "0 20px 25px rgba(0,0,0,0.1)"
  },
  "style": {
    "keywords": ["[keyword1]", "[keyword2]", "[keyword3]"],
    "mood": ["[mood1]", "[mood2]"],
    "illustration": "[style]",
    "photography": "[style]",
    "iconography": "[style]",
    "avoid": ["[anti-pattern1]", "[anti-pattern2]"]
  },
  "logo": {
    "safeZone": "20% of logo height",
    "minSize": { "digital": "24px", "print": "10mm" },
    "clearBackground": true,
    "forbiddenBackgrounds": ["busy patterns", "low contrast colors"]
  }
}
```

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Brand name |
| `colors.primary` | object | Primary color with hex, rgb, hsl |
| `colors.secondary` | object | Secondary color |
| `colors.background` | object | Page background |
| `colors.text.primary` | string | Primary text color |
| `typography.display` | object | Display font |
| `typography.body` | object | Body font |
| `style.keywords` | array | Visual style keywords |

## Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `tagline` | string | Tagline |
| `direction` | string | Chosen direction name |
| `colors.accent` | object | Accent color |
| `colors.semantic` | object | Semantic colors |
| `typography.mono` | object | Monospace font |
| `spacing` | object | Spacing scale |
| `borderRadius` | object | Border radii |
| `shadows` | object | Shadows |
| `logo` | object | Logo usage rules |

## Consumers

| Phase | Consumes | Produces |
|-------|----------|----------|
| Phase 2 | Chosen direction | `brand.json` |
| Phase 3 | `brand.json` | `brand-tokens.css`, `tailwind.config.ts`, React components |
| Phase 4 | `brand.json` + Phase 3 | `tokens/*.ts`, `components/*.tsx`, `tailwind.preset.ts` |
| Phase 5 | `brand.json` | Visually consistent carousel visuals, slide palette |
