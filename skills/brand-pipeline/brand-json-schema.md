# brand.json Schema — Single Source of Truth

Le fichier `brand.json` est le contrat entre toutes les phases du pipeline. Produit en Phase 2, consommé par les Phases 3, 4 et 5.

## Schema complet

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

## Champs obligatoires

| Champ | Type | Description |
|-------|------|-------------|
| `name` | string | Nom de la marque |
| `colors.primary` | object | Couleur principale avec hex, rgb, hsl |
| `colors.secondary` | object | Couleur secondaire |
| `colors.background` | object | Fond de page |
| `colors.text.primary` | string | Couleur texte principal |
| `typography.display` | object | Police d'affichage |
| `typography.body` | object | Police de corps |
| `style.keywords` | array | Mots-clés du style visuel |

## Champs optionnels

| Champ | Type | Description |
|-------|------|-------------|
| `tagline` | string | Accroche |
| `direction` | string | Nom de la direction choisie |
| `colors.accent` | object | Couleur d'accent |
| `colors.semantic` | object | Couleurs sémantiques |
| `typography.mono` | object | Police monospace |
| `spacing` | object | Échelle d'espacement |
| `borderRadius` | object | Rayons de bordure |
| `shadows` | object | Ombres |
| `logo` | object | Règles d'utilisation du logo |

## Consommateurs

| Phase | Consomme | Produit |
|-------|----------|---------|
| Phase 2 | Direction choisie | `brand.json` |
| Phase 3 | `brand.json` | `brand-tokens.css`, `tailwind.config.ts`, composants React |
| Phase 4 | `brand.json` + Phase 3 | `tokens/*.ts`, `components/*.tsx`, `tailwind.preset.ts` |
| Phase 5 | `brand.json` | Visuels carrousels cohérents, palette slides |
