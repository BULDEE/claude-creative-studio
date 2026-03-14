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
               ┌────────▼─────────┐  ┌───────▼──────────┐
               │  User Docs       │  │ Social Carousels │
               │                  │  │                  │
               │  Guide           │  │  Carousel        │
               │  Screenshot      │  │  Slide           │
               │  Flow Interactif │  │  Hook            │
               └──────────────────┘  │  Copy            │
                                     └──────────────────┘
```

**Note** : Le Design System (Phases 3-4 du pipeline) n'est pas un Bounded Context séparé. C'est un **sous-domaine de Brand Visuals** — il consomme `brand.json` et produit des artefacts React/Tailwind. Son langage (tokens, composants, preset) est technique, pas métier.

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

### Agent-to-Phase mapping

| Phase | Agent primaire | Agent secondaire |
|-------|---------------|-----------------|
| Phase 1 — Exploration | `art-director` | `visual-designer` |
| Phase 2 — Brandbook | `art-director` | `visual-designer` |
| Phase 3 — Landing React | `design-system-engineer` | — |
| Phase 4 — Design System | `design-system-engineer` | — |
| Phase 5 — Carrousels | `carousel-copywriter` | `visual-designer` |

### Stratégie mémoire des agents

Seuls `art-director` et `carousel-copywriter` ont `memory: user`. Ce choix est délibéré :

| Agent | Memory | Justification |
|-------|--------|---------------|
| `art-director` | `user` | Retient les préférences visuelles, directions validées/rejetées, palettes efficaces — critique pour la cohérence DA sur plusieurs sessions |
| `carousel-copywriter` | `user` | Retient le ton validé, les hooks qui fonctionnent, les sujets déjà traités — permet d'améliorer la pertinence au fil du temps |
| `visual-designer` | — | Exécutant pur : reçoit un brief et un style de référence, pas de décision créative à retenir |
| `design-system-engineer` | — | Travail technique déterministe : lit `brand.json`, produit des tokens/composants. Le contexte projet suffit, pas besoin de mémoire inter-sessions |

**Règle** : la mémoire est réservée aux agents qui prennent des **décisions subjectives** (DA, copywriting). Les agents qui **exécutent un contrat** (brand.json → code, brief → image) n'en ont pas besoin.

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
│   ├── gemini-api-reference.md      ← Shared: templates API Gemini (SRP: un seul point de changement)
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

## Data Flow — Exemple concret

Voici le flux de données complet pour une marque "NovaSanté", de l'exploration à l'acquisition.

### Phase 1 → Phase 2 : Direction → brand.json

```
art-director propose 3 directions (direction.md × 3)
  → utilisateur valide "Lumière Bleue"
    → art-director produit brand.json :

{
  "name": "NovaSanté",
  "colors": { "primary": { "hex": "#2563EB" }, "secondary": { "hex": "#10B981" } },
  "typography": { "display": { "family": "Plus Jakarta Sans" }, "body": { "family": "Inter" } },
  "style": { "keywords": ["modern", "clean", "medical"] }
}
```

### Phase 2 → Phase 3 : brand.json → React tokens

```
design-system-engineer lit brand.json
  → génère brand-tokens.css :
      --color-primary: #2563EB;
      --font-display: 'Plus Jakarta Sans', sans-serif;
  → étend tailwind.config.ts :
      colors: { primary: { DEFAULT: '#2563EB', 600: '#2563EB' } }
  → crée Hero.tsx :
      <section className="bg-primary-600 text-white">
        <h1 className="font-display text-5xl">NovaSanté</h1>
      </section>
```

### Phase 3 → Phase 4 : Composants → Design System

```
design-system-engineer extrait les tokens de tailwind.config.ts
  → produit tokens/colors.ts (avec branded types HexColor)
  → produit Button.tsx (variants primary=#2563EB, secondary=#10B981)
  → produit Button.stories.md (props, variants, accessibility)
  → produit tailwind.preset.ts (partageable entre projets)
```

### Phase 2 → Phase 5 : brand.json → Carrousels

```
carousel-copywriter rédige 10 slides (copy.md)
  → visual-designer lit brand.json → palette #2563EB, #10B981
    → génère slide-01.png avec prompt incluant les hex codes
    → utilise slide-01 comme référence de style pour slides 02-10
  → export .pptx avec fontFace dérivé de brand.json.typography.display
```

## Hooks — Garde-fous créatifs

Le plugin intègre un système de hooks inspiré de `ai-craftsman-superpowers`, adapté aux dérives spécifiques du branding et de la création.

### bias-detector.sh (UserPromptSubmit)

Détecte 6 biais cognitifs sur chaque message utilisateur :

| Biais | Déclencheur | Risque |
|-------|-------------|--------|
| **Brief Drift** | "change la palette", "repartir de zéro" | Perte de cohérence avec le brief validé |
| **Perfectionnisme DA** | "encore une variante", "affine" | Boucle infinie d'itération sans livrer |
| **Phase Skip** | "saute cette phase", "directement" | Assets sans fondation DA = incohérence |
| **Scope Creep Visuel** | "et aussi", "en plus", "rajoute" | Dilution de qualité |
| **Palette Anarchie** | "ajoute du rouge", "autre couleur" | Briser la charte brand.json |
| **Accélération** | "vite", "urgent", "rush" | Branding bâclé = refaire 3x |

### brand-consistency-check.sh (PostToolUse Write|Edit)

Vérifie la cohérence brand sur chaque fichier écrit/modifié :
- Couleurs hex hardcodées dans `.tsx`/`.ts` (devrait utiliser les tokens)
- Styles inline avec couleurs (devrait utiliser les classes Tailwind)
- CSS custom properties hors convention (`--color-*`, `--font-*`, `--radius-*`)

Les deux hooks sont **non-bloquants** (exit 0) — ils avertissent, ne bloquent jamais.

## Évolutions possibles

| Évolution | Impact | Principe |
|-----------|--------|----------|
| Agent Teams mode | Agents deviennent teammates, art-director = lead | OCP (ADR-009) |
| Nouveau backend image (Flux, DALL-E) | Modifier le template script dans les skills | LSP |
| Nouveau BC (Email Templates) | Ajouter `skills/email-templates/` | OCP |
| Volume de références > 50 fichiers | Ajouter un index ou RAG léger | ADR future |
| Marketplace officiel Anthropic | Soumettre via formulaire in-app | Distribution |
