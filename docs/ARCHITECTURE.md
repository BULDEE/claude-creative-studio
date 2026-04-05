# Architecture — Claude Creative Studio v2.0.0

## Overview

Claude Creative Studio is a **Claude Code Plugin** structured according to Clean Architecture, DDD, and SOLID principles, adapted to the context of a skills and agents system driven by an LLM.

## Architectural Layers

```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION                            │
│  commands/           Slash commands — user entry point        │
│  skills/*/SKILL.md   LLM instructions — interface contract   │
│  agents/             Specialized subagents — delegation       │
├──────────────────────────────────────────────────────────────┤
│                      APPLICATION                             │
│  brand-pipeline      Process Manager — 5-phase orchestration │
│  Skill workflows     brief → DA detection → generation → out │
│  Validation          quality checklist, user confirmation     │
├──────────────────────────────────────────────────────────────┤
│                        DOMAIN                                │
│  Bounded Contexts:                                           │
│    Logo Design │ Brand Visuals │ User Docs │ Social Carousels│
│  Aggregates: Brief, Asset, Guide, Carousel                   │
│  Value Objects: Palette, Direction, Screenshot, Slide         │
│  Domain Services: DA Cascade, Checklist, Hook Strategy        │
├──────────────────────────────────────────────────────────────┤
│                     INFRASTRUCTURE                           │
│  .mcp.json           MCP Filesystem (knowledge base)         │
│  Gemini API          Generation backend (Nano Banana)        │
│  Playwright MCP      Navigation & screenshots (external)     │
│  PptxGenJS           Carousel .pptx export (Canva)           │
│  Filesystem          Output (logos/, visuals/, carousels/)    │
└──────────────────────────────────────────────────────────────┘
```

## DDD Mapping

### Bounded Contexts

The plugin identifies **four bounded contexts** with distinct ubiquitous languages:

```
┌─────────────────┐    brand.json    ┌──────────────────┐
│  Logo Design    │ ───────────────► │  Brand Visuals   │
│                 │  (Domain Event)  │                  │
│  Brief          │                  │  Asset Brief     │
│  Creative Dir.  │                  │  Brand Tokens    │
│  Variation      │                  │  Asset Type      │
└─────────────────┘                  └──────────────────┘
                                              │
                        ┌─────────────────────┼─────────────────────┐
                        │                     │                     │
               screenshots in guide    brand.json palette   brand.json palette
                        │                     │                     │
               ┌────────▼─────────┐  ┌───────▼──────────┐
               │  User Docs       │  │ Social Carousels │
               │                  │  │                  │
               │  Guide           │  │  Carousel        │
               │  Screenshot      │  │  Slide           │
               │  Interactive Flow│  │  Hook            │
               └──────────────────┘  │  Copy            │
                                     └──────────────────┘
```

**Note**: The Design System (Pipeline Phases 3-4) is not a separate Bounded Context. It is a **subdomain of Brand Visuals** — it consumes `brand.json` and produces React/Tailwind artifacts. Its language (tokens, components, preset) is technical, not domain-driven.

### Inter-context Communication

Contexts are **loosely coupled** via shared conventions:

| Source | Convention | Consumer |
|--------|-----------|----------|
| `design-logo` | produces `brand.json` | `brand-visuals`, `social-carousels`, `brand-pipeline` |
| `brand-visuals` | files in `visuals/` | React templates, carousel slides |
| `app-guide-generator` | screenshots in `docs/guide/` | Project documentation |
| `social-carousels` | slides in `carousels/` + `.pptx` | Canva / Figma (external) |
| `brand-pipeline` | orchestrates 5 phases | All skills above |

### Aggregates

| Bounded Context | Aggregate Root | Invariants |
|----------------|---------------|------------|
| Logo Design | `Brief` (name, sector, values) | Minimum 3 directions, quality checklist validated |
| Brand Visuals | `AssetBrief` (type, subject, ratio) | DA detected and validated before generation |
| User Docs | `Guide` (audience, scope, pages) | ToC validated, manual auth if needed |
| Social Carousels | `Carousel` (topic, type, platform) | 10 slides, viral hook, visual consistency |

## Specialized Agents

The plugin provides 4 agents that can operate as subagents or as future teammates:

| Agent | Role | Model | Preloaded Skills |
|-------|------|-------|------------------|
| `art-director` | Creative lead, validates the DA | opus | `design-logo`, `brand-visuals` |
| `visual-designer` | Generates visuals via Nano Banana | sonnet | `brand-visuals` |
| `carousel-copywriter` | Viral carousel copywriting | sonnet | `social-carousels` |
| `design-system-engineer` | React tokens, components, Tailwind | sonnet | `brand-visuals` + cross-plugin |

### Agent-to-Phase Mapping

| Phase | Primary Agent | Secondary Agent |
|-------|---------------|-----------------|
| Phase 1 — Exploration | `art-director` | `visual-designer` |
| Phase 2 — Brandbook | `art-director` | `visual-designer` |
| Phase 3 — React Landing | `design-system-engineer` | — |
| Phase 4 — Design System | `design-system-engineer` | — |
| Phase 5 — Carousels | `carousel-copywriter` | `visual-designer` |

### Agent Memory Strategy

Only `art-director` and `carousel-copywriter` have `memory: user`. This is deliberate:

| Agent | Memory | Rationale |
|-------|--------|-----------|
| `art-director` | `user` | Retains visual preferences, validated/rejected directions, effective palettes — critical for DA consistency across sessions |
| `carousel-copywriter` | `user` | Retains validated tone, hooks that perform well, previously covered topics — improves relevance over time |
| `visual-designer` | — | Pure executor: receives a brief and a reference style, no creative decisions to retain |
| `design-system-engineer` | — | Deterministic technical work: reads `brand.json`, produces tokens/components. Project context is sufficient, no need for inter-session memory |

**Rule**: memory is reserved for agents making **subjective decisions** (DA, copywriting). Agents that **execute a contract** (brand.json -> code, brief -> image) do not need it.

### Cross-plugin Dependencies

The `design-system-engineer` references skills from other plugins when available:
- `craftsman:component` — React component scaffolding (ai-craftsman-superpowers plugin)
- `frontend-design:frontend-design` — high-quality visual design (frontend-design plugin)

These dependencies are **optional** — agents apply the principles directly if the plugins are not installed.

## SOLID Principles Applied

### S — Single Responsibility
Each skill has **one reason to change**. Each agent has **a single role**.

### O — Open/Closed
- New BC = new folder in `skills/` (no modification needed)
- New agent = new file in `agents/`
- New references = drop into `knowledge/`

### L — Liskov Substitution
Generation backends are substitutable: Gemini -> DALL-E -> Flux without changing the workflow.

### I — Interface Segregation
Each skill/agent exposes exactly what is needed for its context.

### D — Dependency Inversion
All components depend on `brand.json` (abstraction), not on implementation details.

## File Structure

```
claude-creative-studio/
├── .claude-plugin/
│   └── plugin.json                 <- Plugin identity (SRP: metadata only)
├── .mcp.json                       <- Infrastructure: knowledge base access
├── .gitignore
│
├── skills/                         <- DOMAIN LAYER
│   ├── image-provider-reference.md   <- Shared: multi-provider API templates Gemini/OpenAI (SRP)
│   ├── design-logo/
│   │   └── SKILL.md                <- BC: Logo Design + 3D proposals
│   ├── brand-visuals/
│   │   └── SKILL.md                <- BC: Brand Visual Production
│   ├── brand-da/
│   │   └── SKILL.md                <- BC: Interactive HTML DA (10 sections)
│   ├── brand-export/
│   │   └── SKILL.md                <- BC: Branding Folder Export
│   ├── app-guide-generator/
│   │   └── SKILL.md                <- BC: User Documentation
│   ├── social-carousels/
│   │   ├── SKILL.md                <- BC: Social Media Acquisition
│   │   ├── copywriting-rules.md    <- Copywriting rules (supporting file)
│   │   └── hook-strategies.md      <- Viral hooks matrix (supporting file)
│   └── brand-pipeline/
│       ├── SKILL.md                <- Process Manager (8-phase orchestration)
│       ├── phase-templates.md      <- Extracted templates (supporting file)
│       └── brand-json-schema.md    <- brand.json schema (supporting file)
│
├── commands/                       <- APPLICATION LAYER
│   ├── setup-provider.md            <- Image provider configuration Gemini/OpenAI
│   └── setup-gemini.md             <- Gemini configuration (legacy)
│
├── agents/                         <- DELEGATION LAYER
│   ├── art-director.md             <- Creative lead (opus, memory)
│   ├── visual-designer.md          <- Nano Banana specialist (sonnet)
│   ├── carousel-copywriter.md      <- Carousel copywriter (sonnet)
│   └── design-system-engineer.md   <- React/Tailwind/DDD (sonnet)
│
├── knowledge/                      <- INFRASTRUCTURE LAYER (data)
│   ├── logo-references/            <- Logo DA references
│   ├── brand-assets/               <- Validated assets
│   ├── carousel-references/        <- Carousel examples + methodologies
│   └── README.md
│
├── docs/                           <- DOCUMENTATION
│   ├── ARCHITECTURE.md             <- This file
│   └── adr/                        <- Architecture Decision Records
│
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Data Flow — Concrete Example

Here is the complete data flow for a brand "NovaHealth", from exploration to acquisition.

### Phase 1 -> Phase 2: Direction -> brand.json

```
art-director proposes 3 directions (direction.md x 3)
  -> user validates "Blue Light"
    -> art-director produces brand.json:

{
  "name": "NovaHealth",
  "colors": { "primary": { "hex": "#2563EB" }, "secondary": { "hex": "#10B981" } },
  "typography": { "display": { "family": "Plus Jakarta Sans" }, "body": { "family": "Inter" } },
  "style": { "keywords": ["modern", "clean", "medical"] }
}
```

### Phase 2 -> Phase 3: brand.json -> React tokens

```
design-system-engineer reads brand.json
  -> generates brand-tokens.css:
      --color-primary: #2563EB;
      --font-display: 'Plus Jakarta Sans', sans-serif;
  -> extends tailwind.config.ts:
      colors: { primary: { DEFAULT: '#2563EB', 600: '#2563EB' } }
  -> creates Hero.tsx:
      <section className="bg-primary-600 text-white">
        <h1 className="font-display text-5xl">NovaHealth</h1>
      </section>
```

### Phase 3 -> Phase 4: Components -> Design System

```
design-system-engineer extracts tokens from tailwind.config.ts
  -> produces tokens/colors.ts (with branded types HexColor)
  -> produces Button.tsx (variants primary=#2563EB, secondary=#10B981)
  -> produces Button.stories.md (props, variants, accessibility)
  -> produces tailwind.preset.ts (shareable across projects)
```

### Phase 2 -> Phase 5: brand.json -> Carousels

```
carousel-copywriter writes 10 slides (copy.md)
  -> visual-designer reads brand.json -> palette #2563EB, #10B981
    -> generates slide-01.png with prompt including hex codes
    -> uses slide-01 as style reference for slides 02-10
  -> exports .pptx with fontFace derived from brand.json.typography.display
```

## Hooks — Creative Guardrails

The plugin integrates a hooks system inspired by `ai-craftsman-superpowers`, adapted to the specific pitfalls of branding and creative work.

### bias-detector.sh (UserPromptSubmit)

Detects 6 cognitive biases on each user message:

| Bias | Trigger | Risk |
|------|---------|------|
| **Brief Drift** | "change the palette", "start over" | Loss of consistency with the validated brief |
| **DA Perfectionism** | "one more variant", "refine" | Infinite iteration loop without delivering |
| **Phase Skip** | "skip this phase", "directly" | Assets without DA foundation = inconsistency |
| **Visual Scope Creep** | "and also", "plus", "add" | Quality dilution |
| **Palette Anarchy** | "add red", "another color" | Breaking the brand.json guidelines |
| **Rush Mode** | "fast", "urgent", "rush" | Sloppy branding = redo 3x |

### brand-consistency-check.sh (PostToolUse Write|Edit)

Checks brand consistency on every written/modified file:
- Hardcoded hex colors in `.tsx`/`.ts` (should use tokens)
- Inline styles with colors (should use Tailwind classes)
- CSS custom properties outside convention (`--color-*`, `--font-*`, `--radius-*`)

Both hooks are **non-blocking** (exit 0) — they warn, never block.

## Possible Evolutions

| Evolution | Impact | Principle |
|-----------|--------|----------|
| Agent Teams mode | Agents become teammates, art-director = lead | OCP (ADR-009) |
| New image backend (Flux, DALL-E) | Modify the script template in skills | LSP |
| New BC (Email Templates) | Add `skills/email-templates/` | OCP |
| Reference volume > 50 files | Add an index or lightweight RAG | Future ADR |
| Official Anthropic Marketplace | Submit via in-app form | Distribution |
