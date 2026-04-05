# Phase Templates — Brand Pipeline

Reference templates for each pipeline phase. Consulted by the `brand-pipeline` skill.

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

### Filled Example — "NovaSante" Direction

```markdown
# Direction: Blue Light

## Concept
A contemporary, clean, and luminous medical universe. The direction relies on soft geometric shapes and a blue-green palette evoking both technology and care. White space dominates to communicate clarity and trust.

## Why It Works
1. Blue is the color most associated with trust in healthcare (Pantone 2023 study)
2. Soft geometry (rounded edges, circles) reduces the perception of technological coldness
3. The blue/green contrast creates a visual bridge between "innovation" and "natural"

## Color Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | Trust Blue | #2563EB | CTAs, headings, key elements |
| Secondary | Vitality Green | #10B981 | Health badges, positive accents |
| Accent | Innovation Cyan | #06B6D4 | Notifications, highlights |
| Background | Pure White | #FAFBFC | Page background |
| Surface | Cloud Gray | #F1F5F9 | Cards, elevated sections |
| Text Primary | Slate | #1E293B | Body text |
| Text Secondary | Medium Gray | #64748B | Labels, captions |

## Typography

| Role | Font | Weight | Usage |
|------|------|--------|-------|
| Display | Plus Jakarta Sans | Bold (700) | H1, hero text |
| Heading | Plus Jakarta Sans | Semibold (600) | H2-H4 |
| Body | Inter | Regular (400) | Paragraphs |
| Mono | JetBrains Mono | Regular (400) | Medical data |

## Logo Concept
"NovaSante" logotype in Plus Jakarta Sans Bold, the "o" in Nova transformed into a blue #2563EB light point. The light point symbolizes the star (Nova) and digital diagnosis. Icon variant: stylized "N" with the light point.

## Visual Style
- **Illustration**: flat with subtle gradients, rounded organic shapes
- **Photography**: bright patient/doctor portraits, editorial style, natural light
- **Iconography**: outline 1.5px stroke, rounded corners, Phosphor style
- **Patterns/Textures**: subtle blue→cyan gradients, light grain on hero sections

## Sample Application
[Generated hero image: white background, blue/green geometric shapes in background, 40% text space on left]
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

### Filled Example — NovaSante

```markdown
| Aspect | Blue Light | Living Earth | Urban Neon |
|--------|------------|--------------|------------|
| Mood | trust, clarity, serenity | natural, warmth, proximity | boldness, energy, disruption |
| Primary Color | #2563EB | #059669 | #7C3AED |
| Display Font | Plus Jakarta Sans | DM Serif Display | Space Grotesk |
| Logo Style | minimalist logotype | organic symbol + serif | bold typographic |
| Best For | B2B healthcare, hospitals, insurance | patients, wellness, prevention | health startups, GenZ |
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

### Filled Example — NovaSante Tokens

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

### Filled Example — Button.stories.md

```markdown
# Button

## Usage
Primary interface action. Use for form submissions, important navigations, and CTAs.

## Variants
| Variant | Usage | Example |
|---------|-------|---------|
| `primary` | Primary action — 1 per section max | "Book appointment" |
| `secondary` | Complementary secondary action | "Learn more" |
| `ghost` | Tertiary action, inline navigation | "Cancel" |
| `destructive` | Deletion, irreversible actions | "Delete account" |

## Sizes
| Size | Height | Font Size | Padding | Usage |
|------|--------|-----------|---------|-------|
| `sm` | 32px | 14px | 12px 16px | Inline, tables |
| `md` | 40px | 16px | 12px 24px | Forms (default) |
| `lg` | 48px | 18px | 16px 32px | Hero CTA, landing |

## Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `'primary' \| 'secondary' \| 'ghost' \| 'destructive'` | `'primary'` | Visual style |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | Button size |
| `disabled` | `boolean` | `false` | Disables interaction |
| `loading` | `boolean` | `false` | Displays a spinner |
| `asChild` | `boolean` | `false` | Composes with a child element (Radix pattern) |

## Accessibility
- Native `button` role (no `<div onClick>`)
- `aria-disabled` when disabled (not `pointer-events: none` alone)
- `aria-busy="true"` during loading
- WCAG 2.1 AA compliant visible focus (2px offset outline)
- Text/background contrast ratio >= 4.5:1

## Code

\`\`\`tsx
import { Button } from '@/components/Button';

<Button variant="primary" size="lg">
  Book appointment
</Button>

<Button variant="secondary" loading>
  Loading...
</Button>
\`\`\`

## Do / Don't
- **Do**: one `primary` button per visible section
- **Do**: clear action verb ("Save", not "OK")
- **Don't**: 2 `primary` buttons side by side
- **Don't**: vague text ("Click here", "Submit")
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
