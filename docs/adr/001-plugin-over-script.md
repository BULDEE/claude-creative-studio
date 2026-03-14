# ADR-001: Plugin Claude Code plutôt que script bash

**Date** : 2026-03-14
**Statut** : accepted

## Contexte

Le projet a initialement été distribué via un script bash (`setup-creative-studio.sh`) qui créait manuellement les dossiers, copiait les skills, et configurait les MCP servers via `claude mcp add`. Cette approche fonctionnait mais posait des problèmes de maintenabilité, de reproductibilité et d'accessibilité pour des utilisateurs non techniques.

## Décision

Migrer vers le format officiel **Claude Code Plugin** (spec Anthropic octobre 2025) avec un manifest `plugin.json`, un `.mcp.json` pour la configuration MCP automatique, et la structure standard `skills/`, `commands/`, `knowledge/`.

## Justification

**Pour le plugin :**
- Installation en une commande : `/plugin install BULDEE/claude-creative-studio`
- MCP auto-configuré via `.mcp.json` (zéro `claude mcp add` manuel)
- Skills auto-découverts et namespaced (`claude-creative-studio:design-logo`)
- Distribution via marketplace officiel Anthropic ou GitHub
- Mises à jour centralisées — l'utilisateur pull une version, pas re-exécute un script
- Convention partagée avec l'écosystème Claude Code

**Contre le script bash :**
- Fragile : dépend du shell, des chemins, de la présence de commandes
- Pas de versioning intégré
- Pas de namespace — risque de collision avec d'autres skills
- Maintenance manuelle des mises à jour
- Hors écosystème — invisible dans `/plugin list`

## Conséquences

- Le script `setup-creative-studio.sh` est déprécié
- Les skills existants dans `~/.claude/skills/` doivent être migrés vers le plugin
- Les MCP configurés manuellement (`knowledge-base`) sont remplacés par le `.mcp.json` du plugin
- Les utilisateurs installent via le système de plugins natif
