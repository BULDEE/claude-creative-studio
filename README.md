# Claude Creative Studio

Claude Code plugin for generating professional Design Applications (DA): logos, 3D renders, interactive HTML brandbook, branded visuals, React design system, LinkedIn/Instagram carousels, and automated user guides.

## Installation

```
/plugin marketplace add BULDEE/claude-creative-studio
/plugin install claude-creative-studio@claude-creative-studio
```

Or locally for testing:

```bash
claude --plugin-dir /path/to/claude-creative-studio
```

## What You Can Do

### Create a logo + 3D proposals

```
Create a logo for "MyCompany" in the healthcare sector
```

Claude consults your DA references, proposes 3 creative directions, generates visuals, then **systematically proposes 3 cinematic 3D renders** (obsidian, concrete, frosted glass) with different materials.

### Generate an interactive DA

```
Generate the HTML DA for my project
```

Claude reads `brand.json` and generates a professional-quality single-file HTML with 16 sections: symbol, moodboard, palette, font exploration, typography, construction grid, clear zone, dark/light components, specifications, landing preview, data-viz, brand applications, states, design tokens. Vercel/Linear standard.

### Export the full branding

```
Export the full branding to a branding/ folder
```

Claude compiles all assets: 8 logo variants (flat, lockup, mono, app-icons), 3-5 3D renders, social assets, `brand-tokens.css`, `tailwind.preset.ts`, HTML DA, `favicon.ico`, README.

### Generate branded visuals

```
Generate a hero image for the landing page
```

Claude **automatically detects** your project's palette (Tailwind, CSS, `brand.json`) and generates consistent visuals via Gemini or OpenAI.

### Create LinkedIn/Instagram carousels

```
Create a LinkedIn carousel about copywriting
```

Claude generates a viral 10-slide carousel with psychological hooks, branded visuals per slide, and `.pptx` export for Canva (or Figma).

### Run the full pipeline

```
Run the brand pipeline for "MyProduct"
```

8-phase pipeline with user validation at each step:
1. **Exploration** — 3+ artistic directions
2. **Brandbook** — selected direction + `brand.json`
3. **HTML DA** — interactive Design Application (the-[name].html)
4. **3D Logos** — 3-5 cinematic renders with different materials
5. **Brand Export** — complete `branding/` folder with all assets
6. **Landing Page** — React + Tailwind + tokens
7. **Design System** — components + Tailwind preset
8. **Social Carousels** — acquisition carousels

### Create a user guide

```
Create a user guide for myapp.com with screenshots
```

Claude navigates the app via Playwright, captures screens, and assembles a complete Markdown guide.

### Configure the image provider

```
/claude-creative-studio:setup-provider
```

Guided configuration of the provider (free Gemini or paid OpenAI).

### Index brandbook references (RAG)

```
/claude-creative-studio:ingest-references
```

Index your professional brandbook PDFs and image folders into a searchable knowledge base. The plugin uses these references to calibrate prompts, construction grids, and 3D material specs. Gemini Vision analyzes each page — free within the 1,500/day limit.

## Components

| Component | Type | Description |
|-----------|------|-------------|
| `design-logo` | Skill | Logo creation + systematic 3D proposals |
| `brand-visuals` | Skill | Branded visuals with auto DA detection |
| `brand-da` | Skill | Interactive single-file HTML DA (16 sections) |
| `brand-export` | Skill | Full branding/ folder export (logos, 3D, tokens, DA) |
| `social-carousels` | Skill | Viral LinkedIn/Instagram carousels (10 slides + Canva export) |
| `brand-pipeline` | Skill | Brand-to-code pipeline in 8 phases with validation gates |
| `app-guide-generator` | Skill | Guides with Playwright screenshots |
| `setup-provider` | Command | Guided image provider configuration (Gemini/OpenAI) |
| `ingest-references` | Command | Index brandbook references into RAG database |
| `setup-gemini` | Command | Guided Gemini key configuration (legacy) |
| `art-director` | Agent | Creative lead, validates the DA (opus) |
| `visual-designer` | Agent | Generates visuals via configured provider (sonnet) |
| `carousel-copywriter` | Agent | Viral carousel copywriting (sonnet) |
| `design-system-engineer` | Agent | React tokens, components, Tailwind (sonnet) |
| `creative-knowledge` | MCP | Access to reference files |

## Image Provider

The plugin supports two professional image providers:

| Provider | Variable | Cost | Quality |
|----------|----------|------|---------|
| **Gemini** (default) | `GEMINI_API_KEY` | Free (~500/day Flash) | Excellent |
| **OpenAI** | `OPENAI_IMAGE_KEY` | ~$0.04-0.19/image | Excellent |

### Configuration

```
/claude-creative-studio:setup-provider
```

Or manually:

```bash
# Gemini (free)
echo 'export GEMINI_API_KEY="your-key"' >> ~/.zshrc

# OpenAI (paid)
echo 'export OPENAI_IMAGE_KEY="your-key"' >> ~/.zshrc

source ~/.zshrc
```

To switch providers:
```
/plugin config claude-creative-studio image_provider openai
```

## Creative Temperature

The `creative_temperature` parameter controls the diversity of 3D renders:

| Level | 3D Renders | Materials |
|-------|-----------|-----------|
| `conservative` | 3 | Same material, different lighting |
| `balanced` (default) | 3 | Premium + Architectural + Luminous |
| `adventurous` | 5 | All 3 + Liquid + Holographic |

## API Usage & Costs

This plugin generates images via external APIs. Each generation consumes credits/quota.

### Estimated cost per operation

| Operation | Images generated | Gemini cost (free) | OpenAI cost |
|-----------|----------------|-----------------------|-------------|
| Logo (3 directions) | 9-15 images | ~15 out of 500/day | ~$0.60-1.20 |
| 3D proposals (balanced) | 3 images | ~3 out of 500/day | ~$0.12-0.57 |
| 3D proposals (adventurous) | 5 images | ~5 out of 500/day | ~$0.20-0.95 |
| Full Brand Export | 12-16 images | ~16 out of 500/day | ~$0.48-3.04 |
| Carousel (10 slides) | 10 images | ~10 out of 500/day | ~$0.40-1.90 |
| **Full pipeline** | **~40-50 images** | **~50 out of 500/day** | **~$2-8** |

### Agents

The `art-director` agent uses the **opus** model (creative decisions). Other agents use **sonnet** (execution).

### Cost control

- **Gemini (default)**: free with ~500 images/day — sufficient for a full pipeline
- **OpenAI**: paid — monitor usage via the OpenAI dashboard
- **Conservative temperature**: reduces 3D renders from 5 to 3 images
- **Partial phases**: stop at any pipeline phase

## Adding Your References

Place your files in the plugin's `knowledge/` folder:

```
knowledge/
├── logo-references/        <- Brand guideline PDFs, existing logos
├── brand-assets/           <- Final logos, palettes, guidelines
└── carousel-references/    <- Carousel examples, copywriting methodologies
```

Claude will automatically consult them during creation.

## Automatic DA Detection

The `brand-visuals` skill looks for the color palette in this order:

1. `brand.json` / `brand.yaml` at the project root
2. `tailwind.config.*` -> `theme.extend.colors`
3. CSS custom properties (`--color-primary`, etc.)
4. `.claude/CLAUDE.md` in the project
5. Asks the user

### Example `brand.json`

```json
{
  "name": "MyProduct",
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

## Prerequisites

- **Claude Code** (latest version)
- **Node.js 18+**
- **Image provider**: Gemini (free) or OpenAI (paid) — see setup above
- **Playwright MCP** (for guides only):
  ```bash
  claude mcp add --scope user playwright npx @playwright/mcp@latest
  ```

## Plugin Structure

```
claude-creative-studio/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   ├── marketplace.json         # Marketplace registry
│   └── ignore                   # Distribution exclusions
├── .mcp.json                    # Auto-configured MCP (knowledge base)
├── skills/
│   ├── design-logo/             # BC: Logo Design + 3D proposals
│   │   └── SKILL.md
│   ├── brand-visuals/           # BC: Brand Visual Production
│   │   └── SKILL.md
│   ├── brand-da/                # BC: Interactive HTML DA
│   │   └── SKILL.md
│   ├── brand-export/            # BC: Branding Folder Export
│   │   └── SKILL.md
│   ├── social-carousels/        # BC: Social Media Acquisition
│   │   ├── SKILL.md
│   │   ├── copywriting-rules.md
│   │   └── hook-strategies.md
│   ├── brand-pipeline/          # Process Manager (8 phases)
│   │   ├── SKILL.md
│   │   ├── phase-templates.md
│   │   ├── brand-json-schema.md
│   │   ├── direction-preview.md  # Visual direction comparison templates
│   │   └── preview-server.sh     # Embedded HTTP server for direction preview
│   ├── app-guide-generator/     # BC: User Documentation
│   │   └── SKILL.md
│   └── image-provider-reference.md  # Unified API reference (Gemini + OpenAI)
├── scripts/                       # Maintainer tooling (not in plugin bundle)
│   ├── ingest.sh                # RAG ingestion orchestrator
│   ├── search.sh                # RAG search (bash + sqlite3)
│   ├── construction-grid.mjs    # Parametric SVG grid generator
│   └── lib/
│       ├── extract-pages.sh     # PDF → PNG page extraction
│       ├── describe-page.mjs    # Gemini Vision page analysis
│       └── embed-store.mjs      # SQLite FTS5 storage
├── commands/
│   ├── setup-provider.md        # Guided image provider config
│   ├── ingest-references.md     # Guided RAG ingestion
│   └── setup-gemini.md          # Guided Gemini config (legacy)
├── agents/
│   ├── art-director.md          # Creative lead (opus)
│   ├── visual-designer.md       # Image specialist (sonnet)
│   ├── carousel-copywriter.md   # Carousel copywriter (sonnet)
│   └── design-system-engineer.md # React/Tailwind/DDD (sonnet)
├── knowledge/
│   ├── logo-references/         # DA references
│   ├── brand-assets/            # Final assets
│   ├── carousel-references/     # Carousel examples + methodologies
│   └── README.md
├── hooks/
│   ├── hooks.json               # Plugin hooks registration
│   ├── session-start.sh         # Brand context detection (SessionStart)
│   ├── bias-detector.sh         # 6 creative cognitive biases (UserPromptSubmit)
│   └── brand-consistency-check.sh # Brand consistency on Write|Edit (PostToolUse)
├── docs/
│   ├── ARCHITECTURE.md          # DDD/Clean Architecture
│   └── adr/                     # Architecture Decision Records
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Output — branding/ Folder

After a full pipeline or `brand-export`, the generated folder contains:

```
branding/
├── brand.json                    # Source of truth
├── the-[name].html              # Interactive DA (open in browser)
├── brand-tokens.css             # CSS custom properties
├── tailwind.preset.ts           # Shareable Tailwind preset
├── logos/
│   ├── icon-flat-dark.png       # White logo on dark background
│   ├── icon-flat-light.png      # Color logo on white background
│   ├── icon-mono-black.png      # Black monochrome
│   ├── icon-mono-white.png      # White monochrome
│   ├── lockup-dark.png          # Logo + name, dark background
│   ├── lockup-light.png         # Logo + name, light background
│   ├── app-icon-ios.png         # iOS app icon
│   ├── app-icon-chrome.png      # Chrome/PWA icon
│   ├── favicon.ico              # Multi-resolution (16/32/48)
│   └── icon.svg                 # Vector SVG
├── 3d/
│   ├── 3d-premium.png           # Titanium/obsidian render
│   ├── 3d-architectural.png     # Concrete/basalt render
│   └── 3d-luminous.png          # Frosted glass render
├── social/
│   ├── og-image-1200x630.png    # Open Graph / Twitter Card
│   └── avatar-square-512.png    # Social media avatar
└── README.md                    # Quick usage guide
```

## License

MIT — see [LICENSE](LICENSE)

## Author

**BULDEE** — AI Agency & SaaS Studio
