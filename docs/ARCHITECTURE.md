# Architecture — Claude Creative Studio v2.0.0

## Vue d'ensemble

Claude Creative Studio est un **Claude Code Plugin** structuré selon les principes de Clean Architecture, DDD et SOLID, adaptés au contexte d'un système de skills et agents piloté par un LLM.

## Couches architecturales

```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION                            │
│  commands/           Slash commands — point d'entrée user     │
│  skills/*/SKILL.md   Instructions LLM — contrat d'interface  │
│  agents/             Subagents spécialisés — delegation       │
├──────────────────────────────────────────────────────────────┤
│                      APPLICATION                             │
│  brand-pipeline      Process Manager — orchestration 5 phases │
│  Workflows skills    brief → détection DA → génération → out  │
│  Validation          checklist qualité, confirmation user      │
├──────────────────────────────────────────────────────────────┤
│                        DOMAIN                                │
│  Bounded Contexts :                                          │
│    Logo Design │ Brand Visuals │ User Docs │ Social Carousels│
│  Aggregates : Brief, Asset, Guide, Carousel                  │
│  Value Objects : Palette, Direction, Screenshot, Slide        │
│  Domain Services : Cascade DA, Checklist, Hook Strategy       │
├──────────────────────────────────────────────────────────────┤
│                     INFRASTRUCTURE                           │
│  .mcp.json           MCP Filesystem (knowledge base)         │
│  Gemini API          Backend de génération (Nano Banana)      │
│  Playwright MCP      Navigation & screenshots (externe)       │
│  PptxGenJS           Export carrousels .pptx (Canva)          │
│  Filesystem          Output (logos/, visuals/, carousels/)    │
└──────────────────────────────────────────────────────────────┘
```

## Mapping DDD

### Bounded Contexts

Le plugin identifie **quatre contextes bornés** avec des langages ubiquitaires distincts :

```
┌─────────────────┐    brand.json    ┌──────────────────┐
│  Logo Design    │ ───────────────► │  Brand Visuals   │
│                 │  (Domain Event)  │                  │
│  Brief          │                  │  Asset Brief     │
│  Piste Créative │                  │  Brand Tokens    │
│  Déclinaison    │                  │  Type d'Asset    │
└─────────────────┘                  └──────────────────┘
                                              │
                        ┌─────────────────────┼─────────────────────┐
                        │                     │                     │
               screenshots dans guide  brand.json palette   brand.json palette
                        │                     │                     │
               ┌────────▼─────────┐  ┌───────▼──────────┐  ┌──────▼───────────┐
               │  User Docs       │  │ Social Carousels │  │  Design System   │
               │                  │  │                  │  │  (Phase 3-4)     │
               │  Guide           │  │  Carousel        │  │                  │
               │  Screenshot      │  │  Slide           │  │  Tokens          │
               │  Flow Interactif │  │  Hook            │  │  Components      │
               └──────────────────┘  │  Copy            │  │  Tailwind Preset │
                                     └──────────────────┘  └──────────────────┘
```

### Communication inter-contextes

Les contextes sont **loosely coupled** via des conventions partagées :

| Source | Convention | Consommateur |
|--------|-----------|-------------|
| `design-logo` | `brand.json` produit | `brand-visuals`, `social-carousels`, `brand-pipeline` |
| `brand-visuals` | Fichiers dans `visuals/` | Templates React, slides carrousels |
| `app-guide-generator` | Screenshots dans `docs/guide/` | Documentation projet |
| `social-carousels` | Slides dans `carousels/` + `.pptx` | Canva / Figma (externe) |
| `brand-pipeline` | Orchestre les 5 phases | Tous les skills ci-dessus |

### Aggregates

| Bounded Context | Aggregate Root | Invariants |
|----------------|---------------|------------|
| Logo Design | `Brief` (nom, secteur, valeurs) | 3 pistes minimum, checklist qualité validée |
| Brand Visuals | `AssetBrief` (type, sujet, ratio) | DA détectée et validée avant génération |
| User Docs | `Guide` (audience, périmètre, pages) | ToC validée, auth manuelle si nécessaire |
| Social Carousels | `Carousel` (sujet, type, plateforme) | 10 slides, hook viral, cohérence visuelle |

## Agents spécialisés

Le plugin fournit 4 agents qui peuvent fonctionner comme subagents ou comme futurs teammates :

| Agent | Rôle | Model | Skills préchargés |
|-------|------|-------|-------------------|
| `art-director` | Lead créatif, valide la DA | opus | `design-logo`, `brand-visuals` |
| `visual-designer` | Génère visuels via Nano Banana | sonnet | `brand-visuals` |
| `carousel-copywriter` | Copywriting carrousels viraux | sonnet | `social-carousels` |
| `design-system-engineer` | React tokens, composants, Tailwind | sonnet | `brand-visuals` + cross-plugin |

### Cross-plugin dependencies

Le `design-system-engineer` référence des skills d'autres plugins quand ils sont disponibles :
- `craftsman:component` — scaffolding composants React (plugin ai-craftsman-superpowers)
- `frontend-design:frontend-design` — design visuel haute qualité (plugin frontend-design)

Ces dépendances sont **optionnelles** — les agents appliquent les principes directement si les plugins ne sont pas installés.

## Principes SOLID appliqués

### S — Single Responsibility
Chaque skill a **une seule raison de changer**. Chaque agent a **un rôle unique**.

### O — Open/Closed
- Nouveau BC = nouveau dossier dans `skills/` (pas de modification)
- Nouvel agent = nouveau fichier dans `agents/`
- Nouvelles références = déposer dans `knowledge/`

### L — Liskov Substitution
Les backends de génération sont substituables : Gemini → DALL-E → Flux sans changer le workflow.

### I — Interface Segregation
Chaque skill/agent expose exactement ce qui est nécessaire à son contexte.

### D — Dependency Inversion
Tous les composants dépendent de `brand.json` (abstraction), pas des détails d'implémentation.

## Structure des fichiers

```
claude-creative-studio/
├── .claude-plugin/
│   └── plugin.json                 ← Identité du plugin (SRP: metadata only)
├── .mcp.json                       ← Infrastructure: accès knowledge base
├── .gitignore
│
├── skills/                         ← DOMAIN LAYER
│   ├── design-logo/
│   │   └── SKILL.md                ← BC: Logo Design
│   ├── brand-visuals/
│   │   └── SKILL.md                ← BC: Brand Visual Production
│   ├── app-guide-generator/
│   │   └── SKILL.md                ← BC: User Documentation
│   ├── social-carousels/
│   │   ├── SKILL.md                ← BC: Social Media Acquisition
│   │   ├── copywriting-rules.md    ← Règles copywriting (supporting file)
│   │   └── hook-strategies.md      ← Matrice hooks viraux (supporting file)
│   └── brand-pipeline/
│       ├── SKILL.md                ← Process Manager (orchestration 5 phases)
│       ├── phase-templates.md      ← Templates extraits (supporting file)
│       └── brand-json-schema.md    ← Schema brand.json (supporting file)
│
├── commands/                       ← APPLICATION LAYER
│   └── setup-gemini.md             ← Configuration guidée (disable-model-invocation)
│
├── agents/                         ← DELEGATION LAYER
│   ├── art-director.md             ← Lead créatif (opus, memory)
│   ├── visual-designer.md          ← Spécialiste Nano Banana (sonnet)
│   ├── carousel-copywriter.md      ← Copywriter carrousels (sonnet)
│   └── design-system-engineer.md   ← React/Tailwind/DDD (sonnet)
│
├── knowledge/                      ← INFRASTRUCTURE LAYER (data)
│   ├── logo-references/            ← Références DA logos
│   ├── brand-assets/               ← Assets validés
│   ├── carousel-references/        ← Exemples carrousels + méthodologies
│   └── README.md
│
├── docs/                           ← DOCUMENTATION
│   ├── ARCHITECTURE.md             ← Ce fichier
│   └── adr/                        ← Architecture Decision Records
│
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Évolutions possibles

| Évolution | Impact | Principe |
|-----------|--------|----------|
| Agent Teams mode | Agents deviennent teammates, art-director = lead | OCP (ADR-009) |
| Nouveau backend image (Flux, DALL-E) | Modifier le template script dans les skills | LSP |
| Nouveau BC (Email Templates) | Ajouter `skills/email-templates/` | OCP |
| Volume de références > 50 fichiers | Ajouter un index ou RAG léger | ADR future |
| Marketplace officiel Anthropic | Soumettre via formulaire in-app | Distribution |
