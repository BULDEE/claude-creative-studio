# Architecture Decision Records

Ce dossier contient les ADR (Architecture Decision Records) du plugin Claude Creative Studio.

## Convention

Chaque décision architecturale significative est documentée dans un ADR numéroté.

**Format** : [ADR template de Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)

**Statuts** : `proposed` → `accepted` → `deprecated` / `superseded`

## Index

| # | Titre | Statut | Date |
|---|-------|--------|------|
| [001](001-plugin-over-script.md) | Plugin Claude Code plutôt que script bash | accepted | 2026-03-14 |
| [002](002-knowledge-base-as-mcp-filesystem.md) | Knowledge base via MCP Filesystem | accepted | 2026-03-14 |
| [003](003-gemini-nano-banana-image-backend.md) | Gemini (Nano Banana) comme backend de génération d'images | accepted | 2026-03-14 |
| [004](004-playwright-excluded-from-bundle.md) | Playwright MCP exclu du bundle plugin | accepted | 2026-03-14 |
| [005](005-brand-detection-cascade.md) | Détection de DA par cascade contextuelle | accepted | 2026-03-14 |
| [006](006-skill-per-bounded-context.md) | Un Skill par Bounded Context métier | accepted | 2026-03-14 |
| 007 | _(reserved)_ | — | — |
| [008](008-social-carousel-bounded-context.md) | Social Media Carousels comme Bounded Context | accepted | 2026-03-14 |
| [009](009-agents-over-teams.md) | Agents spécialisés plutôt que Agent Teams | accepted | 2026-03-14 |
