# Phase Templates — Brand Pipeline

Templates de référence pour chaque phase du pipeline. Consulté par le skill `brand-pipeline`.

## direction.md Template (Phase 1)

```markdown
# Direction: [Name]

## Concept
[2-3 sentences describing the artistic universe]

## Why It Works
[3 arguments connecting the direction to the brand values]

## Color Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | [name] | #XXXXXX | CTAs, headings, key elements |
| Secondary | [name] | #XXXXXX | Supporting elements, accents |
| Accent | [name] | #XXXXXX | Highlights, notifications |
| Background | [name] | #XXXXXX | Page backgrounds |
| Surface | [name] | #XXXXXX | Cards, elevated elements |
| Text Primary | [name] | #XXXXXX | Body text |
| Text Secondary | [name] | #XXXXXX | Captions, labels |

## Typography

| Role | Font | Weight | Usage |
|------|------|--------|-------|
| Display | [Font Name] | Bold/Black | H1, hero text |
| Heading | [Font Name] | Semibold | H2-H4 |
| Body | [Font Name] | Regular | Paragraphs |
| Mono | [Font Name] | Regular | Code, data |

## Logo Concept
[Description + generated visuals]

## Visual Style
- **Illustration**: [flat/3D/geometric/organic/line art...]
- **Photography**: [studio/lifestyle/editorial/abstract...]
- **Iconography**: [outline/filled/duotone/custom...]
- **Patterns/Textures**: [gradients/grain/geometric/none...]

## Sample Application
[Generated mockup showing the direction in context]
```

### Exemple rempli — Direction "NovaSanté"

```markdown
# Direction: Lumière Bleue

## Concept
Un univers médical contemporain, épuré et lumineux. La direction s'appuie sur des formes géométriques douces et une palette bleu-vert qui évoque à la fois la technologie et le soin. L'espace blanc domine pour communiquer la clarté et la confiance.

## Why It Works
1. Le bleu est la couleur la plus associée à la confiance en santé (étude Pantone 2023)
2. La géométrie douce (arrondis, cercles) réduit la perception de froideur technologique
3. Le contraste bleu/vert crée un pont visuel entre "innovation" et "naturel"

## Color Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | Bleu Confiance | #2563EB | CTAs, headings, éléments-clés |
| Secondary | Vert Vitalité | #10B981 | Badges santé, accents positifs |
| Accent | Cyan Innovation | #06B6D4 | Notifications, highlights |
| Background | Blanc Pur | #FAFBFC | Fond de page |
| Surface | Gris Nuage | #F1F5F9 | Cards, sections élevées |
| Text Primary | Ardoise | #1E293B | Corps de texte |
| Text Secondary | Gris Moyen | #64748B | Labels, captions |

## Typography

| Role | Font | Weight | Usage |
|------|------|--------|-------|
| Display | Plus Jakarta Sans | Bold (700) | H1, hero text |
| Heading | Plus Jakarta Sans | Semibold (600) | H2-H4 |
| Body | Inter | Regular (400) | Paragraphes |
| Mono | JetBrains Mono | Regular (400) | Données médicales |

## Logo Concept
Logotype "NovaSanté" en Plus Jakarta Sans Bold, le "o" de Nova transformé en point lumineux bleu #2563EB. Le point lumineux symbolise l'étoile (Nova) et le diagnostic digital. Déclinaison icône : le "N" stylisé avec le point lumineux.

## Visual Style
- **Illustration** : flat avec dégradés subtils, formes organiques arrondies
- **Photography** : portraits patients/médecins lumineux, style éditorial, lumière naturelle
- **Iconography** : outline 1.5px stroke, coins arrondis, style Phosphor
- **Patterns/Textures** : dégradés bleu→cyan subtils, grain léger sur les hero

## Sample Application
[Hero image générée : fond blanc, formes géométriques bleu/vert en arrière-plan, espace texte 40% gauche]
```

## Comparison Table Template (Phase 1)

```markdown
| Aspect | Direction 1 | Direction 2 | Direction 3 |
|--------|------------|------------|------------|
| Mood | [keywords] | [keywords] | [keywords] |
| Primary Color | #XXX | #XXX | #XXX |
| Display Font | [font] | [font] | [font] |
| Logo Style | [type] | [type] | [type] |
| Best For | [audience] | [audience] | [audience] |
```

### Exemple rempli — NovaSanté

```markdown
| Aspect | Lumière Bleue | Terre Vivante | Néon Urbain |
|--------|--------------|---------------|-------------|
| Mood | confiance, clarté, sérénité | naturel, chaleur, proximité | audace, énergie, disruption |
| Primary Color | #2563EB | #059669 | #7C3AED |
| Display Font | Plus Jakarta Sans | DM Serif Display | Space Grotesk |
| Logo Style | logotype minimaliste | symbole organique + serif | typographique bold |
| Best For | B2B santé, hôpitaux, assurances | patients, bien-être, prévention | startups santé, GenZ |
```

## Brandbook README.md Sections (Phase 2)

1. **Brand Story** — mission, vision, values, personality
2. **Logo** — all versions, usage rules, safe zones, forbidden uses
3. **Color System** — full palette with usage guidelines, accessibility (WCAG AA/AAA)
4. **Typography** — type scale, pairings, usage per context
5. **Imagery & Illustration** — photography style, illustration approach, iconography
6. **Voice & Tone** — writing style guidelines (optional, if user wants)
7. **Application Examples** — generated mockups showing the brand in context

## Token Files Format (Phase 4)

```typescript
// tokens/colors.ts
export const colors = {
  primary: {
    DEFAULT: '#XXXXXX',
    50: '#XXXXXX',
    100: '#XXXXXX',
    // ... full scale generated from primary
    900: '#XXXXXX',
  },
  secondary: { /* ... */ },
  accent: { /* ... */ },
  neutral: { /* ... */ },
  semantic: {
    success: '#XXXXXX',
    warning: '#XXXXXX',
    error: '#XXXXXX',
    info: '#XXXXXX',
  },
} as const;

export type ColorToken = keyof typeof colors;
```

### Exemple rempli — NovaSanté tokens

```typescript
// tokens/colors.ts
export const colors = {
  primary: {
    DEFAULT: '#2563EB',
    50: '#EFF6FF',
    100: '#DBEAFE',
    200: '#BFDBFE',
    300: '#93C5FD',
    400: '#60A5FA',
    500: '#3B82F6',
    600: '#2563EB',
    700: '#1D4ED8',
    800: '#1E40AF',
    900: '#1E3A8A',
  },
  secondary: {
    DEFAULT: '#10B981',
    50: '#ECFDF5',
    500: '#10B981',
    700: '#047857',
    900: '#064E3B',
  },
  accent: {
    DEFAULT: '#06B6D4',
    50: '#ECFEFF',
    500: '#06B6D4',
    700: '#0E7490',
  },
  neutral: {
    50: '#FAFBFC',
    100: '#F1F5F9',
    400: '#94A3B8',
    600: '#64748B',
    800: '#1E293B',
    900: '#0F172A',
  },
  semantic: {
    success: '#22C55E',
    warning: '#F59E0B',
    error: '#EF4444',
    info: '#3B82F6',
  },
} as const;

export type ColorToken = keyof typeof colors;
```

## Component Documentation Format (Phase 4)

Each `*.stories.md` follows:

```markdown
# [Component Name]

## Usage
[When and why to use this component]

## Variants
| Variant | Usage | Example |
|---------|-------|---------|

## Sizes
| Size | Height | Font Size | Padding | Usage |
|------|--------|-----------|---------|-------|

## Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|

## Accessibility
[WCAG requirements specific to this component]

## Code
[Usage example]

## Do / Don't
[Best practices]
```

### Exemple rempli — Button.stories.md

```markdown
# Button

## Usage
Action principale de l'interface. Utiliser pour les soumissions de formulaire, navigations importantes et CTAs.

## Variants
| Variant | Usage | Example |
|---------|-------|---------|
| `primary` | Action principale — 1 par section max | "Prendre rendez-vous" |
| `secondary` | Action secondaire complémentaire | "En savoir plus" |
| `ghost` | Action tertiaire, navigation inline | "Annuler" |
| `destructive` | Suppression, actions irréversibles | "Supprimer le compte" |

## Sizes
| Size | Height | Font Size | Padding | Usage |
|------|--------|-----------|---------|-------|
| `sm` | 32px | 14px | 12px 16px | Inline, tableaux |
| `md` | 40px | 16px | 12px 24px | Formulaires (défaut) |
| `lg` | 48px | 18px | 16px 32px | Hero CTA, landing |

## Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `'primary' \| 'secondary' \| 'ghost' \| 'destructive'` | `'primary'` | Style visuel |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | Taille du bouton |
| `disabled` | `boolean` | `false` | Désactive l'interaction |
| `loading` | `boolean` | `false` | Affiche un spinner |
| `asChild` | `boolean` | `false` | Compose avec un élément enfant (Radix pattern) |

## Accessibility
- Rôle `button` natif (pas de `<div onClick>`)
- `aria-disabled` si disabled (pas `pointer-events: none` seul)
- `aria-busy="true"` pendant loading
- Focus visible conforme WCAG 2.1 AA (outline 2px offset)
- Contraste texte/fond ≥ 4.5:1

## Code

\`\`\`tsx
import { Button } from '@/components/Button';

<Button variant="primary" size="lg">
  Prendre rendez-vous
</Button>

<Button variant="secondary" loading>
  Chargement...
</Button>
\`\`\`

## Do / Don't
- **Do** : un seul bouton `primary` par section visible
- **Do** : verbe d'action clair ("Enregistrer", pas "OK")
- **Don't** : 2 boutons `primary` côte à côte
- **Don't** : texte vague ("Cliquez ici", "Soumettre")
```

## Tailwind Preset Template (Phase 4)

```typescript
// tailwind.preset.ts
import type { Config } from 'tailwindcss';
import { colors } from './tokens/colors';
import { typography } from './tokens/typography';

export default {
  theme: {
    extend: {
      colors,
      fontFamily: {
        display: [typography.display.family, 'sans-serif'],
        heading: [typography.heading.family, 'sans-serif'],
        body: [typography.body.family, 'sans-serif'],
        mono: [typography.mono.family, 'monospace'],
      },
      fontSize: typography.scale,
    },
  },
} satisfies Partial<Config>;
```
