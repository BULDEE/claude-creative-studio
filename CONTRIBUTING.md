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
docs: add ADR-007 for Figma token support
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

1. **Frontmatter** : `name`, `description` (déclencheurs inclus)
2. **Structure** : Prérequis → Workflow (phases numérotées) → Livrable → Anti-patterns
3. **Langue** : français pour le contenu, anglais pour le code
4. **Impératif** : "Générer 3 variantes" pas "Il est possible de générer"
5. **Anti-patterns** : liste explicite de ce qu'il ne faut PAS faire

### ADR

Pour toute décision architecturale significative :

1. Créer `docs/adr/NNN-titre-kebab.md`
2. Suivre le template : Contexte → Décision → Justification → Conséquences
3. Mettre à jour `docs/adr/README.md`

## Ajouter un nouveau Skill

1. Créer `skills/mon-skill/SKILL.md`
2. Respecter la structure et conventions ci-dessus
3. Documenter l'intégration avec les skills existants
4. Mettre à jour le README.md principal
5. Créer un ADR si le skill introduit un nouveau Bounded Context

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
```
