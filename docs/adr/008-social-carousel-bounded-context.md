# ADR-008: Social Media Carousels comme Bounded Context

**Date**: 2026-03-14
**Status**: accepted

## Context

Le pipeline brand-to-code s'arrêtait à la Phase 4 (Design System). L'utilisateur a besoin de générer des carrousels LinkedIn/Instagram pour l'acquisition, utilisant la même identité visuelle. La question est : ce besoin fait-il partie d'un BC existant ou nécessite-t-il un nouveau BC ?

## Decision

Créer un **nouveau Bounded Context** "Social Media Acquisition" avec un skill dédié `social-carousels` et un agent spécialisé `carousel-copywriter`.

## Rationale

### Pourquoi un nouveau BC

Le carrousel a son propre langage ubiquitaire distinct des autres contextes :
- **Carousel** (agrégat : 10 slides, plateforme, type)
- **Slide** (value object : rôle, contenu, visuel)
- **Hook** (value object : stratégie, lignes, levier psychologique)
- **Copy** (value object : ton, contraintes mots, style)

Ce vocabulaire n'existe dans aucun des BC existants. Le forcer dans `brand-visuals` violerait SRP (le skill aurait deux raisons de changer : évolution de la génération d'images ET évolution du copywriting social).

### Pourquoi un seul skill (pas LinkedIn + Instagram séparés)

- Les deux plateformes partagent le même format (1080x1080, slides séquentielles)
- Le copywriting est identique (structure 10 slides, mêmes principes psychologiques)
- La différenciation est dans l'export, pas dans la création
- Deux skills créeraient de la duplication sans valeur ajoutée (violation DRY)

### Structure avec fichiers supporting

Le skill utilise des fichiers supporting (spec Anthropic) pour rester sous 500 lignes :
- `SKILL.md` — orchestrateur (workflow, génération, export)
- `copywriting-rules.md` — règles de copywriting (loaded on demand)
- `hook-strategies.md` — matrice des 6 stratégies de hooks (loaded on demand)

### Intégration dans le pipeline

Le carrousel consomme `brand.json` comme tous les autres BC downstream (DIP respecté). Il devient la Phase 5 du `brand-pipeline`.

## Consequences

- Le pipeline passe de 4 à 5 phases
- `knowledge/carousel-references/` ajouté pour les exemples et méthodologies
- L'agent `carousel-copywriter` est spécialisé en copywriting (séparation des concerns avec `visual-designer`)
- Le skill est utilisable indépendamment du pipeline (ISP)
- L'export `.pptx` pour Canva introduit une dépendance optionnelle sur `pptxgenjs`
