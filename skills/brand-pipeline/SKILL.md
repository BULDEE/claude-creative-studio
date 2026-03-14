---
name: brand-pipeline
description: Pipeline complet brand-to-code en 5 phases — exploration artistique, brandbook final, landing page React, design system, et carrousels social media pour l'acquisition. Orchestre les skills design-logo, brand-visuals et social-carousels. Déclenché par 'brandbook', 'brand pipeline', 'brand creation', 'brand to code', 'design system', 'full branding', 'brand identity workflow', 'create brand', 'brand exploration'.
argument-hint: [company-name]
---

# Brand-to-Code Pipeline

Orchestration end-to-end de l'exploration de marque jusqu'au design system et contenu d'acquisition. Ce skill agit comme un **Process Manager** qui coordonne les skills `design-logo`, `brand-visuals` et `social-carousels`.

## Prérequis

- `GEMINI_API_KEY` configurée (voir `/claude-creative-studio:setup-gemini`)
- Phase 3 : projet React 19 + TypeScript + Tailwind CSS
- Phase 3-4 : utiliser les skills cross-plugin `craftsman:component` et `frontend-design:frontend-design` si disponibles
- Phase 5 : `brand.json` validé (produit en Phase 2)

## Vue d'ensemble

```
Phase 1          Phase 2           Phase 3            Phase 4            Phase 5
EXPLORE    →     DEFINE      →     BUILD        →     DOCUMENT     →     ACQUIRE

3+ directions    Brandbook final   Landing page       Design system      Carrousels
artistiques      + brand.json      React brandée      tokens + docs      LinkedIn/IG

brandbook-       brandbook-        src/landing/       design-system/     carousels/
exploration/     final/            + components       tokens + comps     slides + .pptx
```

Chaque phase requiert la validation explicite de l'utilisateur avant de passer à la suivante.

---

## Phase 1 : Exploration Brandbook

### Objectif
Générer 3+ directions artistiques distinctes pour que le client choisisse un univers visuel.

### Input requis
Demander à l'utilisateur :
1. **Nom** de l'entreprise/produit
2. **Industrie et positionnement**
3. **Valeurs fondamentales** (3-5 mots-clés)
4. **Audience cible**
5. **Concurrents** à différencier (optionnel)
6. **Mood/feeling** souhaité (optionnel)
7. **Contraintes existantes** (couleurs imposées, logo à rafraîchir, etc.)

### Process

Pour chaque direction, générer :
1. **Mood Board** — 3-5 visuels de référence via Nano Banana
2. **Palette de couleurs** — primary, secondary, accent, neutrals avec hex
3. **Pairing typographique** — display + body font avec rationale
4. **Concept de logo** — utiliser la méthodologie du skill `design-logo`
5. **Style visuel** — illustration, photographie, iconographie
6. **Application d'exemple** — un mockup montrant la direction en contexte

#### Prompt template pour les visuels de direction

```
Mood board visual for brand direction "[NOM DIRECTION]".
Style: [STYLE KEYWORDS]. Color palette: [HEX CODES].
Mood: [MOOD KEYWORDS].
Subject: abstract composition representing [BRAND VALUES].
Premium quality, editorial feel. No text. Aspect ratio: 16:9.
```

### Output

Créer un dossier `brandbook-exploration/` — voir [phase-templates.md](phase-templates.md) pour les templates `direction.md` et le tableau comparatif.

<validation_checkpoint phase="1">
**Présenter à l'utilisateur** pour chaque direction :
| Direction | Mood | Palette | Argument principal |
|-----------|------|---------|-------------------|
| [Nom 1] | [3 mots-clés] | [3 hex codes preview] | [Pourquoi cette direction] |
| [Nom 2] | [3 mots-clés] | [3 hex codes preview] | [Pourquoi cette direction] |
| [Nom 3] | [3 mots-clés] | [3 hex codes preview] | [Pourquoi cette direction] |

**Demander** : "Quelle direction te parle le plus ? Je peux aussi mixer des éléments de différentes directions."
**Attendre** : la réponse explicite de l'utilisateur avant de continuer.
</validation_checkpoint>

---

## Phase 2 : Brandbook Final

### Trigger
L'utilisateur a choisi une direction (ou un mix) de la Phase 1.

### Process
Deep dive dans la direction sélectionnée pour produire un brandbook complet, production-ready.

### Output

```
brandbook-final/
├── README.md          ← Document brandbook complet
├── brand.json         ← Tokens machine-readable (voir brand-json-schema.md)
├── assets/
│   ├── logo/          ← Toutes les versions du logo
│   ├── palette/       ← Visuels palette
│   ├── typography/    ← Spécimen typographique
│   └── visuals/       ← Exemples hero, feature, social
└── guidelines/        ← Règles d'usage logo, couleurs, typo, imagerie
```

Le `brand.json` est le **contrat** entre toutes les phases downstream. Voir [brand-json-schema.md](brand-json-schema.md) pour le schéma complet.

<validation_checkpoint phase="2">
**Présenter** : le README.md brandbook avec aperçu palette, logo versions, typo samples.
**Vérifier** : `brand.json` est complet (toutes les sections required du schema).
**Demander** : "Le brandbook est prêt. On crée la landing page React basée sur cette marque ?"
**Attendre** : la réponse explicite de l'utilisateur.
</validation_checkpoint>

---

## Phase 3 : Landing Page React

### Trigger
L'utilisateur a validé le brandbook final de la Phase 2.

### Pré-condition
Vérifier que `brand.json` existe dans `brandbook-final/`. Si absent, rediriger vers Phase 2 : "Il me faut le brandbook final avec `brand.json` avant de construire la landing page. On lance la Phase 2 ?"

### Process

Générer une landing page production-ready en utilisant :
- Le `brand.json` de Phase 2 comme source de vérité unique
- Le skill `brand-visuals` pour les images hero/feature
- Les skills cross-plugin `craftsman:component` et `frontend-design:frontend-design` si disponibles
- React 19 + TypeScript + Tailwind CSS

### Règles d'implémentation

1. **Lire `brand.json`** — extraire tous les tokens avant d'écrire du code
2. **Générer `brand-tokens.css`** — convertir brand.json en CSS custom properties
3. **Étendre `tailwind.config.ts`** — mapper les couleurs dans Tailwind
4. **Générer les visuels** via `brand-visuals`
5. **Construire les composants** — chaque section est un composant React autonome
6. **Responsive by default** — mobile-first, breakpoints sm/md/lg/xl
7. **Accessible** — HTML sémantique, ARIA labels, contrastes WCAG AA

### Sections

| Section | Contenu | Composant |
|---------|---------|-----------|
| Hero | Headline + tagline + CTA + hero image | `Hero.tsx` |
| Features | 3-4 features avec icons/illustrations | `Features.tsx` |
| Social Proof | Témoignages ou logos | `Testimonials.tsx` |
| Pricing | Comparaison plans (si applicable) | `Pricing.tsx` |
| CTA | Call-to-action final | `CTA.tsx` |
| Footer | Liens + légal + socials | `Footer.tsx` |

<validation_checkpoint phase="3">
**Présenter** : screenshot ou aperçu des composants créés, palette appliquée, responsive preview.
**Vérifier** : tous les tokens CSS sont dérivés de `brand.json`, pas de couleurs hardcodées.
**Demander** : "La landing page est prête. Tu veux le design system complet pour ton équipe dev ?"
**Attendre** : la réponse explicite de l'utilisateur.
</validation_checkpoint>

---

## Phase 4 : Design System Book

### Trigger
L'utilisateur a validé la landing page de la Phase 3.

### Process

Créer une documentation design system complète. Voir [phase-templates.md](phase-templates.md) pour les formats de token files, component docs et Tailwind preset.

Utiliser le skill cross-plugin `craftsman:component` si disponible pour scaffolder les composants.

### Output

```
design-system/
├── README.md              ← Overview + quick start
├── tokens/                ← Color, typography, spacing, shadows, radii tokens (.ts)
├── components/            ← Button, Card, Input, Badge, Typography avec stories.md
├── patterns/              ← Layout, forms, navigation, feedback patterns
├── guidelines/            ← Accessibility, responsive, animation, dark mode
└── tailwind.preset.ts     ← Preset Tailwind partageable
```

<validation_checkpoint phase="4">
**Présenter** : liste des tokens, composants documentés, Tailwind preset.
**Vérifier** : chaque composant a sa documentation de props et ses variantes.
**Demander** : "Le design system est prêt. On génère les carrousels social media pour l'acquisition ?"
**Attendre** : la réponse explicite de l'utilisateur.
</validation_checkpoint>

---

## Phase 5 : Carrousels Social Media

### Trigger
L'utilisateur a validé le design system de la Phase 4 (ou souhaite générer des carrousels directement après Phase 2).

### Process

Utiliser le skill `social-carousels` avec le `brand.json` comme source de vérité pour :
1. **Définir les sujets** — quels thèmes d'acquisition pour la marque ?
2. **Générer les carrousels** — copywriting + visuels Nano Banana cohérents avec la DA
3. **Exporter** — en frames éditables Canva (.pptx) ou Figma

### Sujets d'acquisition recommandés

Proposer à l'utilisateur 3-5 sujets de carrousels basés sur :
- Le positionnement de la marque (issues du brief Phase 1)
- Les pain points de l'audience cible
- Les valeurs et l'expertise de la marque

### Output

Chaque carrousel produit :
```
carousels/
├── carousel-[sujet]/
│   ├── slides/            ← 10 images par carrousel
│   ├── carousel-export.pptx
│   ├── copy.md
│   └── carousel.json
```

---

## Règles d'orchestration

### Transitions entre phases

```
[Phase 1] ──validation──► [Phase 2] ──validation──► [Phase 3] ──validation──► [Phase 4] ──validation──► [Phase 5]
    │                          │                          │                          │                          │
    ▼                          ▼                          ▼                          ▼                          ▼
brandbook-exploration/    brandbook-final/           src/landing/             design-system/            carousels/
                          + brand.json               + brand-tokens.css       + tokens/                 + slides/
                                                     + tailwind.config.ts     + components/             + .pptx
```

### Data flow

1. Phase 1 → `direction.md` avec palettes et concepts
2. Phase 2 → `brand.json` (source de vérité unique)
3. Phase 3 → CSS tokens + Tailwind config + composants React (depuis `brand.json`)
4. Phase 4 → Design system complet (depuis `brand.json` + Phase 3)
5. Phase 5 → Carrousels visuellement cohérents (depuis `brand.json`)

### Règles

- **Respecter l'ordre des phases** — chaque phase valide les hypothèses de la précédente
- **brand.json est le contrat** — toutes les phases downstream le lisent
- **Validation utilisateur obligatoire** — présenter et demander explicitement
- **Exécution partielle OK** — l'utilisateur peut s'arrêter à n'importe quelle phase
- **Intégration projet existant** — s'adapter à la structure React existante

<avoid>
- Avancer sans validation utilisateur
- Générer sans brandbook validé
- Hardcoder des couleurs au lieu d'utiliser les tokens
- Composants qui ne matchent pas brand.json
- Ignorer l'accessibilité dans le design system
- Design system sans documentation de props
- Valeurs arbitraires dans Tailwind au lieu de l'échelle design token
- Carrousels visuellement incohérents avec la DA
</avoid>

## Self-check avant chaque transition de phase

Avant de proposer la phase suivante, vérifier :
1. Tous les outputs de la phase courante sont générés et sauvegardés
2. `brand.json` est à jour avec les dernières décisions validées
3. L'utilisateur a explicitement validé (pas d'approbation implicite)
4. Les fichiers sont organisés selon la structure documentée
