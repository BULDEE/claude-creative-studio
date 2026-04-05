# ADR-008: Social Media Carousels as a Bounded Context

**Date**: 2026-03-14
**Status**: accepted

## Context

The brand-to-code pipeline stopped at Phase 4 (Design System). Users need to generate LinkedIn/Instagram carousels for acquisition, using the same visual identity. The question is: does this need belong to an existing BC or does it require a new one?

## Decision

Create a **new Bounded Context** "Social Media Acquisition" with a dedicated `social-carousels` skill and a specialized `carousel-copywriter` agent.

## Rationale

### Why a new BC

The carousel has its own distinct ubiquitous language, separate from other contexts:
- **Carousel** (aggregate: 10 slides, platform, type)
- **Slide** (value object: role, content, visual)
- **Hook** (value object: strategy, lines, psychological lever)
- **Copy** (value object: tone, word constraints, style)

This vocabulary does not exist in any of the existing BCs. Forcing it into `brand-visuals` would violate SRP (the skill would have two reasons to change: evolution of image generation AND evolution of social copywriting).

### Why a single skill (not separate LinkedIn + Instagram skills)

- Both platforms share the same format (1080x1080, sequential slides)
- The copywriting is identical (10-slide structure, same psychological principles)
- The differentiation is in the export, not in the creation
- Two skills would create duplication without added value (DRY violation)

### Structure with supporting files

The skill uses supporting files (Anthropic spec) to stay under 500 lines:
- `SKILL.md` — orchestrator (workflow, generation, export)
- `copywriting-rules.md` — copywriting rules (loaded on demand)
- `hook-strategies.md` — matrix of 6 hook strategies (loaded on demand)

### Pipeline integration

The carousel consumes `brand.json` like all other downstream BCs (DIP respected). It becomes Phase 5 of the `brand-pipeline`.

## Consequences

- The pipeline grows from 4 to 5 phases
- `knowledge/carousel-references/` added for examples and methodologies
- The `carousel-copywriter` agent specializes in copywriting (separation of concerns with `visual-designer`)
- The skill is usable independently of the pipeline (ISP)
- The `.pptx` export for Canva introduces an optional dependency on `pptxgenjs`
