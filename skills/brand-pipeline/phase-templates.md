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
