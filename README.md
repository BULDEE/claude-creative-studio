# Claude Creative Studio

Plugin Claude Code pour le pipeline complet brand-to-code : logos, visuels brandés, design system React, carrousels LinkedIn/Instagram, et guides utilisateurs automatisés.

## Installation

```
/plugin marketplace add BULDEE/claude-creative-studio
/plugin install claude-creative-studio@claude-creative-studio
```

Ou en local pour tester :

```bash
claude --plugin-dir /path/to/claude-creative-studio
```

## Ce que vous pouvez faire

### Créer un logo

```
Crée un logo pour "MonEntreprise" dans le secteur santé
```

Claude consulte vos références DA, propose 3 pistes créatives, et génère des visuels via Nano Banana (Gemini).

### Générer des visuels brandés

```
Génère un hero image pour la landing page
```

Claude **détecte automatiquement** la palette de votre projet (Tailwind, CSS, `brand.json`) et génère des visuels cohérents.

### Créer des carrousels LinkedIn/Instagram

```
Crée un carrousel LinkedIn sur le copywriting
```

Claude génère un carrousel viral de 10 slides avec hooks psychologiques, visuels brandés par slide, et export `.pptx` pour Canva (ou Figma).

### Lancer le pipeline complet

```
Lance le brand pipeline pour "MonProduit"
```

Pipeline en 5 phases avec validation utilisateur à chaque étape :
1. **Exploration** — 3 directions artistiques
2. **Brandbook** — direction choisie complète
3. **Design Tokens** — CSS/JSON/SCSS
4. **Design System** — composants React + Tailwind preset
5. **Social Carousels** — carrousels d'acquisition

### Créer un guide utilisateur

```
Crée un guide utilisateur de monapp.com avec des screenshots
```

Claude navigue dans l'app via Playwright, capture les écrans, et assemble un guide Markdown complet.

### Configurer Gemini

```
/claude-creative-studio:setup-gemini
```

Configuration guidée de la clé API Gemini (gratuite, 500 images/jour).

## Composants

| Composant | Type | Description |
|-----------|------|-------------|
| `design-logo` | Skill | Création de logos avec références DA |
| `brand-visuals` | Skill | Visuels brandés avec détection auto de la DA |
| `social-carousels` | Skill | Carrousels LinkedIn/Instagram viraux (10 slides + export Canva) |
| `brand-pipeline` | Skill | Pipeline brand-to-code en 5 phases avec validation gates |
| `app-guide-generator` | Skill | Guides avec screenshots Playwright |
| `setup-gemini` | Command | Configuration guidée clé Gemini |
| `art-director` | Agent | Lead créatif, valide la DA (opus) |
| `visual-designer` | Agent | Génère visuels via Nano Banana (sonnet) |
| `carousel-copywriter` | Agent | Copywriting carrousels viraux (sonnet) |
| `design-system-engineer` | Agent | React tokens, composants, Tailwind (sonnet) |
| `creative-knowledge` | MCP | Accès aux fichiers de référence |

## Ajouter vos références

Déposez vos fichiers dans le dossier `knowledge/` du plugin :

```
knowledge/
├── logo-references/        ← PDFs de chartes graphiques, logos existants
├── brand-assets/           ← Logos finaux, palettes, guidelines
└── carousel-references/    ← Exemples carrousels, méthodologies copywriting
```

Claude les consultera automatiquement lors de la création.

## Prérequis

- **Claude Code** (dernière version)
- **Node.js 18+**
- **Playwright MCP** (pour les guides uniquement) :
  ```bash
  claude mcp add --scope user playwright npx @playwright/mcp@latest
  ```

## Génération d'images (optionnel)

Pour que Claude génère des images réelles (pas juste des descriptions) :

1. Allez sur **https://aistudio.google.com/apikey**
2. Créez une clé API gratuite (500 images/jour)
3. Lancez `/claude-creative-studio:setup-gemini` ou ajoutez manuellement :
   ```bash
   echo 'export GEMINI_API_KEY="votre-clé"' >> ~/.zshrc
   source ~/.zshrc
   ```

## Détection automatique de la DA

Le skill `brand-visuals` cherche la palette de couleurs dans cet ordre :

1. `brand.json` / `brand.yaml` à la racine du projet
2. `tailwind.config.*` → `theme.extend.colors`
3. CSS custom properties (`--color-primary`, etc.)
4. `.claude/CLAUDE.md` du projet
5. Demande à l'utilisateur

### Exemple `brand.json`

```json
{
  "name": "MonProduit",
  "colors": {
    "primary": "#6366F1",
    "secondary": "#8B5CF6",
    "accent": "#06B6D4"
  },
  "style": {
    "keywords": ["modern", "clean", "premium"],
    "avoid": ["clipart", "stock-photo"]
  }
}
```

## Structure du plugin

```
claude-creative-studio/
├── .claude-plugin/
│   └── plugin.json              # Manifest du plugin
├── .mcp.json                    # MCP auto-configuré (knowledge base)
├── skills/
│   ├── design-logo/             # BC: Logo Design
│   │   └── SKILL.md
│   ├── brand-visuals/           # BC: Brand Visual Production
│   │   └── SKILL.md
│   ├── social-carousels/        # BC: Social Media Acquisition
│   │   ├── SKILL.md
│   │   ├── copywriting-rules.md
│   │   └── hook-strategies.md
│   ├── brand-pipeline/          # Process Manager (5 phases)
│   │   ├── SKILL.md
│   │   ├── phase-templates.md
│   │   └── brand-json-schema.md
│   └── app-guide-generator/     # BC: User Documentation
│       └── SKILL.md
├── commands/
│   └── setup-gemini.md          # Config guidée Gemini
├── agents/
│   ├── art-director.md          # Lead créatif (opus)
│   ├── visual-designer.md       # Spécialiste Nano Banana (sonnet)
│   ├── carousel-copywriter.md   # Copywriter carrousels (sonnet)
│   └── design-system-engineer.md # React/Tailwind/DDD (sonnet)
├── knowledge/
│   ├── logo-references/         # Références DA
│   ├── brand-assets/            # Assets finaux
│   ├── carousel-references/     # Exemples carrousels + méthodologies
│   └── README.md
├── hooks/
│   ├── hooks.json                 # Registration des hooks plugin
│   ├── bias-detector.sh           # 6 biais cognitifs créatifs (UserPromptSubmit)
│   └── brand-consistency-check.sh # Cohérence brand sur Write|Edit (PostToolUse)
├── docs/
│   ├── ARCHITECTURE.md          # Architecture DDD/Clean
│   └── adr/                     # Architecture Decision Records
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Migration v1 → v2

### Changements breaking

| v1.0.0 | v2.0.0 | Action |
|--------|--------|--------|
| 3 skills (logo, visuals, guide) | 5 skills + pipeline | Aucune — rétrocompatible |
| Pas d'agents | 4 agents spécialisés | Aucune — les agents sont additifs |
| `brand-visuals` génère sans fallback | Fallback 3 niveaux si Nano Banana échoue | Aucune — amélioration |
| Pas de supporting files | `copywriting-rules.md`, `hook-strategies.md`, etc. | Aucune — transparents |
| Templates Gemini dans chaque skill | `gemini-api-reference.md` centralisé | Si custom : migrer vers le fichier partagé |

### Nouveautés v2.0.0

- **`social-carousels`** : carrousels LinkedIn/Instagram 10 slides avec hooks viraux
- **`brand-pipeline`** : orchestration 5 phases (exploration → acquisition)
- **4 agents** : `art-director` (opus), `visual-designer`, `carousel-copywriter`, `design-system-engineer`
- **Knowledge base** : dossier `carousel-references/` pour exemples et méthodologies
- **Self-check** : chaque skill valide sa sortie avant livraison
- **XML tags** : `<constraints>`, `<avoid>`, `<example>`, `<validation_checkpoint>` dans les prompts

### Pour les contributeurs

- Les skills utilisent désormais `gemini-api-reference.md` — ne plus dupliquer les templates API
- Les agents doivent déclarer `tools:` dans leur frontmatter
- Les supporting files sont obligatoires si un SKILL.md dépasse 500 lignes
- Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour les guidelines complètes v2.0.0

## Licence

MIT — voir [LICENSE](LICENSE)

## Auteur

**BULDEE** — AI Agency & SaaS Studio
