# Contributing

## Quick Start

1. Fork le repo
2. Clone : `git clone git@github.com:YOUR_USER/claude-creative-studio.git`
3. Testez en local : `claude --plugin-dir ./claude-creative-studio`
4. Créez une branche : `git checkout -b feat/mon-ajout`
5. Commitez : `git commit -m "feat: description"`
6. Push + PR

## Conventions

### Commits

Format **Conventional Commits** en anglais :

```
feat: add social media template skill
fix: correct brand detection for CSS modules
docs: add ADR for Figma token support
refactor: extract prompt template in design-logo
```

Types : `feat`, `fix`, `docs`, `refactor`, `chore`, `test`

### Branches

```
feat/nom-feature
fix/description-bug
docs/sujet
```

### SKILL.md

Chaque skill doit respecter :

1. **Frontmatter** : `name`, `description` (déclencheurs inclus), `argument-hint`
2. **Structure** : Prérequis → Workflow (phases numérotées) → Livrable → Anti-patterns → Self-check
3. **Langue** : français pour le contenu, anglais pour le code
4. **Ton** : instructions claires et directes (pas de langage agressif, Claude 4.6 n'en a pas besoin)
5. **XML tags** : utiliser `<constraints>`, `<avoid>`, `<example>`, `<validation_checkpoint>` pour structurer
6. **Anti-patterns** : liste explicite dans un bloc `<avoid>`
7. **Self-check** : section de validation avant livraison
8. **Limite** : max 500 lignes — extraire le détail dans des supporting files (ex: `copywriting-rules.md`)

### Supporting files

Pour les skills complexes, extraire le contenu de référence dans des fichiers séparés :

```
skills/mon-skill/
├── SKILL.md              ← Orchestrateur (< 500 lignes)
├── reference-rules.md    ← Règles détaillées (loaded on demand)
└── examples.md           ← Exemples complets (loaded on demand)
```

Référencer depuis SKILL.md : `[reference-rules.md](reference-rules.md)`

### Agents

Chaque agent dans `agents/` doit avoir :

1. **Frontmatter** : `name`, `description`, `model`, `skills`, `tools`
2. **Optionnel** : `memory: user` si l'agent doit retenir des préférences
3. **Rôle clair** : un agent = une responsabilité (SRP)
4. **Self-check** : section de validation avant livraison
5. **Format de sortie** : documenter comment l'agent présente ses résultats

### API Gemini

Les templates d'appel API Gemini sont centralisés dans `skills/gemini-api-reference.md`. Si l'API change, modifier ce fichier unique — les skills le référencent.

### ADR

Pour toute décision architecturale significative :

1. Créer `docs/adr/NNN-titre-kebab.md`
2. Suivre le template : Contexte → Décision → Justification → Conséquences
3. Mettre à jour `docs/adr/README.md`

## Ajouter un nouveau Skill

1. Créer `skills/mon-skill/SKILL.md` (suivre les conventions ci-dessus)
2. Ajouter des supporting files si le contenu dépasse 500 lignes
3. Documenter l'intégration avec les skills existants
4. Référencer `gemini-api-reference.md` si le skill génère des images
5. Mettre à jour le README.md principal (table des composants)
6. Créer un ADR si le skill introduit un nouveau Bounded Context

## Ajouter un nouvel Agent

1. Créer `agents/mon-agent.md` avec le frontmatter complet
2. Associer les skills nécessaires dans le champ `skills`
3. Déclarer les tools nécessaires dans le champ `tools`
4. Mettre à jour `docs/ARCHITECTURE.md` (table agents + agent-to-phase mapping)
5. Mettre à jour le README.md principal

## Ajouter à la Knowledge Base

1. Déposer les fichiers dans le bon sous-dossier de `knowledge/`
   - `logo-references/` : chartes graphiques, logos existants
   - `brand-assets/` : logos finaux, palettes, guidelines
   - `carousel-references/` : exemples carrousels, méthodologies copywriting
2. Mettre à jour `knowledge/README.md` si nécessaire
3. Formats supportés : PDF, PNG, JPG, SVG, JSON, YAML, MD, DOCX

## Ajouter une source de DA dans la cascade

1. Modifier `skills/brand-visuals/SKILL.md`
2. Insérer la nouvelle source à la bonne position dans l'ordre de priorité
3. Documenter dans l'ADR-005 (ou créer un ADR si changement de stratégie)

## Tests

Tester un skill :

```bash
# Lancer Claude Code avec le plugin en local
claude --plugin-dir /path/to/claude-creative-studio

# Vérifier que le plugin est chargé
/plugin list

# Vérifier les MCP
/mcp

# Tester un skill
"Crée un logo pour TestCorp dans le secteur tech"

# Tester un agent
"@art-director propose 3 directions pour TestCorp"
```
