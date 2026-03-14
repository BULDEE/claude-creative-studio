# 🎨 Claude Creative Studio

Plugin Claude Code pour la création visuelle : logos, visuels brandés, et guides utilisateurs avec screenshots automatiques.

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

### 🎯 Créer un logo

```
Crée un logo pour "MonEntreprise" dans le secteur santé
```

Claude consulte vos références DA, propose 3 pistes créatives, et peut générer des visuels via Nano Banana (Gemini).

### 🖼️ Générer des visuels brandés

```
Génère un hero image pour la landing page
```

Claude **détecte automatiquement** la palette de votre projet (Tailwind, CSS, `brand.json`) et génère des visuels cohérents.

### 📖 Créer un guide utilisateur

```
Crée un guide utilisateur de monapp.com avec des screenshots
```

Claude navigue dans l'app via Playwright, capture les écrans, et assemble un guide Markdown complet.

### ⚙️ Configurer Gemini

```
/claude-creative-studio:setup-gemini
```

Configuration guidée de la clé API Gemini (gratuite, 500 images/jour).

## Composants

| Composant | Type | Description |
|-----------|------|-------------|
| `design-logo` | Skill | Création de logos avec références DA |
| `brand-visuals` | Skill | Visuels brandés avec détection auto de la DA |
| `app-guide-generator` | Skill | Guides avec screenshots Playwright |
| `setup-gemini` | Command | Configuration guidée clé Gemini |
| `creative-knowledge` | MCP | Accès aux fichiers de référence |

## Ajouter vos références

Déposez vos fichiers dans le dossier `knowledge/` du plugin :

```
knowledge/
├── logo-references/    ← PDFs de chartes graphiques, logos existants
└── brand-assets/       ← Logos finaux, palettes, guidelines
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
│   └── plugin.json           # Manifest du plugin
├── .mcp.json                 # MCP auto-configuré (knowledge base)
├── skills/
│   ├── design-logo/          # Création de logos
│   │   └── SKILL.md
│   ├── brand-visuals/        # Visuels brandés
│   │   └── SKILL.md
│   └── app-guide-generator/  # Guides avec screenshots
│       └── SKILL.md
├── commands/
│   └── setup-gemini.md       # Config guidée Gemini
├── knowledge/
│   ├── logo-references/      # Vos références DA
│   ├── brand-assets/         # Vos assets finaux
│   └── README.md
├── README.md
└── LICENSE
```

## Licence

MIT — voir [LICENSE](LICENSE)

## Auteur

**BULDEE** — AI Agency & SaaS Studio
