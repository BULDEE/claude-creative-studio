# Architecture — Claude Creative Studio

## Vue d'ensemble

Claude Creative Studio est un **Claude Code Plugin** structuré selon les principes de Clean Architecture, DDD et SOLID, adaptés au contexte d'un système de skills piloté par un LLM.

## Couches architecturales

```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION                            │
│  commands/           Slash commands — point d'entrée user     │
│  skills/*/SKILL.md   Instructions LLM — contrat d'interface  │
├──────────────────────────────────────────────────────────────┤
│                      APPLICATION                             │
│  Workflows définis dans les SKILL.md                         │
│  Orchestration : brief → détection DA → génération → output  │
│  Validation : checklist qualité, confirmation utilisateur     │
├──────────────────────────────────────────────────────────────┤
│                        DOMAIN                                │
│  Bounded Contexts : Logo Design │ Brand Visuals │ User Docs  │
│  Aggregates : Brief, Asset, Guide                            │
│  Value Objects : Palette, Piste Créative, Screenshot          │
│  Domain Services : Cascade DA, Checklist Qualité              │
├──────────────────────────────────────────────────────────────┤
│                     INFRASTRUCTURE                           │
│  .mcp.json           MCP Filesystem (knowledge base)         │
│  Gemini API          Backend de génération (Nano Banana)      │
│  Playwright MCP      Navigation & screenshots (externe)       │
│  Filesystem          Output (logos/, visuals/, docs/guide/)   │
└──────────────────────────────────────────────────────────────┘
```

## Mapping DDD

### Bounded Contexts

Le plugin identifie **trois contextes bornés** avec des langages ubiquitaires distincts :

```
┌─────────────────┐    brand.json    ┌──────────────────┐
│  Logo Design    │ ───────────────► │  Brand Visuals   │
│                 │  (Domain Event)  │                  │
│  Brief          │                  │  Asset Brief     │
│  Piste Créative │                  │  Brand Tokens    │
│  Déclinaison    │                  │  Type d'Asset    │
└─────────────────┘                  └──────────────────┘
                                              │
                                    screenshots dans guide
                                              │
                                     ┌────────▼─────────┐
                                     │  User Docs       │
                                     │                  │
                                     │  Guide           │
                                     │  Screenshot      │
                                     │  Flow Interactif │
                                     └──────────────────┘
```

### Communication inter-contextes

Les contextes sont **loosely coupled** via des conventions partagées, pas via des appels directs :

| Source | Convention | Consommateur |
|--------|-----------|-------------|
| `design-logo` | Fichier `brand.json` produit | `brand-visuals` |
| `brand-visuals` | Fichiers dans `visuals/` | Templates Astro/React du projet |
| `app-guide-generator` | Screenshots dans `docs/guide/` | Documentation projet |

C'est l'équivalent de **Domain Events** dans un système distribué : chaque contexte produit un artefact que les autres consomment sans couplage direct.

### Aggregates

| Bounded Context | Aggregate Root | Invariants |
|----------------|---------------|------------|
| Logo Design | `Brief` (nom, secteur, valeurs) | 3 pistes minimum, checklist qualité validée |
| Brand Visuals | `AssetBrief` (type, sujet, ratio) | DA détectée et validée avant génération |
| User Docs | `Guide` (audience, périmètre, pages) | ToC validée, auth manuelle si nécessaire |

## Principes SOLID appliqués

### S — Single Responsibility

Chaque skill a **une seule raison de changer** :
- `design-logo` change si le processus de création de logos évolue
- `brand-visuals` change si le backend de génération ou la détection DA évolue
- `app-guide-generator` change si le workflow de documentation évolue

Le `.mcp.json` ne change que si l'infrastructure d'accès aux fichiers change.

### O — Open/Closed

Le plugin est **ouvert à l'extension, fermé à la modification** :
- Ajouter un nouveau Bounded Context = ajouter un dossier dans `skills/` (pas de modification des skills existants)
- Ajouter une source de DA dans la cascade = ajouter une étape dans le SKILL.md de `brand-visuals`
- Ajouter des références = déposer des fichiers dans `knowledge/`

### L — Liskov Substitution

Dans le contexte d'un plugin Claude Code, LSP s'applique aux **backends de génération** :
- Le template de script Gemini dans les skills peut être remplacé par un template DALL-E ou Flux sans changer le workflow du skill
- Le skill définit un **contrat** (input: prompt + palette, output: fichier image), pas une implémentation

### I — Interface Segregation

Chaque skill expose **exactement ce qui est nécessaire** à son contexte :
- Un utilisateur qui fait des logos ne voit pas la logique Playwright
- Un utilisateur qui fait des guides ne voit pas la détection DA
- La command `setup-gemini` est séparée des skills (pas de mélange config/métier)

### D — Dependency Inversion

Les skills dépendent d'**abstractions** (conventions), pas de détails :
- Abstraction : "un fichier `brand.json` avec des couleurs" — pas "la réponse de `tailwind.config.ts`"
- Abstraction : "un script qui génère une image depuis un prompt" — pas "l'API Gemini v3.1"
- Abstraction : "un MCP qui lit des fichiers" — pas "`@modelcontextprotocol/server-filesystem` v1.2.3"

## Clean Code

### Conventions de nommage

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Skill | `kebab-case`, verbe ou domaine | `design-logo`, `brand-visuals` |
| Command | `kebab-case`, action | `setup-gemini` |
| Knowledge dir | `kebab-case` + `-references` ou `-assets` | `logo-references` |
| Output dir | Singulier, lowercase | `logos/`, `visuals/` |
| Screenshot | `NN-description-kebab.png` | `01-dashboard-overview.png` |

### Règles de contenu des SKILL.md

1. **Structure claire** : Prérequis → Workflow (phases numérotées) → Format livrable → Anti-patterns
2. **Impératif** : les instructions utilisent l'impératif ("Générer", "Vérifier"), pas le conditionnel
3. **Exemples concrets** : chaque concept abstrait a un exemple de code ou de prompt
4. **Anti-patterns documentés** : chaque skill liste explicitement ce qu'il ne faut PAS faire
5. **Intégration documentée** : chaque skill documente comment il interagit avec les autres

### Règles de qualité

- **DRY** : les templates de script Gemini sont dans chaque skill (pas de partage) car chaque contexte a des paramètres différents. La duplication est ici intentionnelle (contextes indépendants).
- **KISS** : pas d'abstraction sur l'API Gemini — un script inline lisible > une lib custom opaque
- **YAGNI** : pas de hook, pas d'agent, pas de LSP — ajoutés uniquement si un besoin réel émerge

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
│   └── app-guide-generator/
│       └── SKILL.md                ← BC: User Documentation
│
├── commands/                       ← APPLICATION LAYER
│   └── setup-gemini.md             ← Configuration guidée
│
├── knowledge/                      ← INFRASTRUCTURE LAYER (data)
│   ├── logo-references/            ← Input: références DA
│   ├── brand-assets/               ← Input/Output: assets validés
│   └── README.md
│
├── docs/                           ← DOCUMENTATION
│   ├── ARCHITECTURE.md             ← Ce fichier
│   └── adr/                        ← Architecture Decision Records
│       ├── README.md
│       ├── 001-plugin-over-script.md
│       ├── 002-knowledge-base-as-mcp-filesystem.md
│       ├── 003-gemini-nano-banana-image-backend.md
│       ├── 004-playwright-excluded-from-bundle.md
│       ├── 005-brand-detection-cascade.md
│       └── 006-skill-per-bounded-context.md
│
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Évolutions possibles

| Évolution | Impact | Principe |
|-----------|--------|----------|
| Nouveau backend image (Flux, DALL-E) | Modifier le template script dans 2 skills | LSP |
| Nouveau BC (Social Media Templates) | Ajouter `skills/social-templates/` | OCP |
| Volume de références > 50 fichiers | Ajouter un index ou RAG léger | ADR future |
| Plugin Cowork compatible | Adapter les SKILL.md en plugin Cowork | Même domain, nouvelle presentation |
| Marketplace officiel Anthropic | Soumettre via formulaire in-app | Distribution |
