# ADR-004: Playwright MCP exclu du bundle plugin

**Date** : 2026-03-14
**Statut** : accepted

## Contexte

Le skill `app-guide-generator` dépend du MCP Playwright pour naviguer dans les applications web et capturer des screenshots. La question est de savoir si ce MCP doit être inclus dans le `.mcp.json` du plugin ou installé séparément par l'utilisateur.

## Décision

Le MCP Playwright est **exclu** du bundle plugin. Il est installé séparément en scope user.

## Justification

**Pourquoi exclure :**

1. **Principe de responsabilité unique (SRP)** : le plugin est un toolkit créatif, pas un outil de browser automation. Playwright sert à bien d'autres usages (tests, QA, scraping, exploration).

2. **Éviter la duplication** : si l'utilisateur a déjà Playwright MCP installé (très courant chez les devs), l'inclure dans le plugin créerait un doublon qui consomme du context window inutilement.

3. **Scope différent** : le MCP `creative-knowledge` est spécifique au plugin (scope plugin). Playwright est un outil transversal (scope user). Mélanger les scopes viole la séparation des responsabilités.

4. **Optionnel** : seul 1 skill sur 3 utilise Playwright. Forcer son installation pour les 2/3 des utilisateurs qui ne feront pas de guides est du waste.

**Comment ça fonctionne :**
- Le skill `app-guide-generator` documente le prérequis dans son SKILL.md
- Si Playwright n'est pas installé et que l'utilisateur demande un guide, Claude Code l'informe et donne la commande d'installation
- Le README du plugin liste Playwright comme prérequis optionnel

## Conséquences

- L'installation du plugin ne suffit pas pour le skill `app-guide-generator` — une étape supplémentaire est nécessaire
- Trade-off accepté : simplicité du plugin > completeness du guide generator
- Si d'autres skills nécessitent Playwright à l'avenir, réévaluer cette décision
