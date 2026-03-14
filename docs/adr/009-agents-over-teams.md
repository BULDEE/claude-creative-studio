# ADR-009: Agents spécialisés plutôt que Agent Teams

**Date**: 2026-03-14
**Status**: accepted

## Context

Le pipeline brand-to-code implique plusieurs rôles créatifs distincts (directeur artistique, designer visuel, copywriter, ingénieur design system). Deux approches sont possibles :

1. **Agents** dans `agents/` — subagents classiques, stables, production-ready
2. **Agent Teams** — feature expérimentale Claude Code, multi-sessions coordonnées

## Decision

Implémenter des **agents spécialisés** dans `agents/` du plugin, architecturés pour une migration future vers Agent Teams quand la feature sera stable.

## Rationale

### Pourquoi pas Agent Teams maintenant

La documentation officielle Anthropic est explicite :

> "Agent teams are experimental and disabled by default."

Limitations documentées :
- Pas de session resumption avec teammates in-process
- Task status qui peut lag (teammates oublient de marquer les tâches)
- Shutdown lent
- Un seul team par session
- Pas de teams imbriquées

Pour un plugin distribué à des utilisateurs, ces limitations sont inacceptables.

### Pourquoi des agents dans le plugin

Les agents dans `agents/` sont :
- **Stables** — feature GA (Generally Available) de Claude Code
- **Distribuables** — copiés dans le cache plugin à l'installation
- **Testables** — invocables individuellement via `/agents`
- **Personnalisables** — chaque agent a ses tools, son model, ses skills préchargés

### Architecture prête pour les teams

Les 4 agents sont conçus pour devenir des teammates :

```
Aujourd'hui (subagents)              Demain (agent teams)
───────────────────────              ────────────────────
art-director (opus)        →        Team lead
visual-designer (sonnet)   →        Teammate: visuels
carousel-copywriter (sonnet) →      Teammate: copy
design-system-engineer (sonnet) →   Teammate: code
```

Les agents ont :
- Des rôles clairement séparés (pas de chevauchement)
- Des skills préchargés qui définissent leur expertise
- Des descriptions suffisamment détaillées pour la delegation automatique
- L'agent `art-director` a `memory: user` pour apprendre les préférences

### Applied principles

- **OCP** : quand Agent Teams sera stable, on ajoute un `settings.json` avec `"agent": "art-director"` sans modifier les agents
- **ISP** : chaque agent est utilisable indépendamment
- **SRP** : chaque agent a un seul rôle créatif

## Consequences

- 4 fichiers dans `agents/` distribués avec le plugin
- Les agents fonctionnent immédiatement comme subagents
- La migration vers Agent Teams sera un changement de configuration, pas de code
- L'agent `art-director` utilise opus (plus cher mais justifié pour les décisions créatives)
- Les 3 autres utilisent sonnet (bon rapport qualité/coût pour l'exécution)
