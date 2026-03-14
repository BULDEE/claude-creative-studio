# Knowledge Base

Dossier de fichiers de référence utilisés par les skills du plugin.

## Structure

```
knowledge/
├── logo-references/       ← DA logos validées (PDFs, images, SVGs)
├── brand-assets/          ← Logos finaux, palettes, guidelines
├── carousel-references/   ← Exemples carrousels viraux, méthodologies copywriting
└── README.md              ← Ce fichier
```

## Utilisation

Le MCP `creative-knowledge` (configuré automatiquement par le plugin) donne accès à ce dossier depuis Claude Code.

### Ajouter des références de logos

Déposez vos fichiers dans `logo-references/` :
- PDFs de chartes graphiques
- Images de logos existants (PNG, SVG)
- Moodboards ou planches d'inspiration

Claude les consultera automatiquement avant de créer un nouveau logo.

### Ajouter des assets de marque

Déposez vos fichiers dans `brand-assets/` :
- Logos finaux validés
- Fichiers `brand.json` de référence
- Palettes de couleurs

### Ajouter des références de carrousels

Déposez vos fichiers dans `carousel-references/` :
- PDFs de carrousels performants (exemples visuels)
- DOCX de méthodologies copywriting (hooks, structure, ton)
- Templates de scripts et frameworks de contenu

Claude les consultera automatiquement avant de créer un carrousel via le skill `social-carousels`.

## Formats supportés

PDF, PNG, JPG, SVG, JSON, YAML, MD, DOCX
