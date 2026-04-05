# ADR-006: One Skill per Business Bounded Context

**Date**: 2026-03-14
**Status**: accepted

## Context

The plugin covers three distinct creative activities: logo creation, branded visual generation, and application documentation. The question is whether to structure these capabilities as a single mega-skill or as separate skills.

## Decision

Each business **Bounded Context** is encapsulated in a **dedicated Skill** with its own responsibility, its own SKILL.md, and its own trigger rules.

### DDD to Skills Mapping

```
Bounded Context: Logo Design
  Skill: design-logo
  Aggregate Root: Client brief (name, industry, values)
  Value Objects: Creative direction, Palette, Variation
  Domain Service: Nano Banana generation (optional)
  Repository: knowledge/logo-references/ (via MCP)

Bounded Context: Brand Visual Production
  Skill: brand-visuals
  Aggregate Root: Asset brief (type, subject, dimensions)
  Value Objects: Brand tokens (colors, style, mood)
  Domain Service: Brand identity detection (cascade), Nano Banana generation
  Repository: Project context (tailwind, CSS, brand.json)

Bounded Context: User Documentation
  Skill: app-guide-generator
  Aggregate Root: Guide (audience, scope, pages)
  Value Objects: Screenshot, Documented step
  Domain Service: Playwright navigation, Capture
  Repository: docs/guide/ (output filesystem)
```

## Rationale

**Applied principles:**

- **Single Responsibility Principle (SRP)**: each skill has a single reason to change. If the image generation method evolves, only `brand-visuals` and `design-logo` are impacted. If Playwright changes, only `app-guide-generator` is affected.

- **Interface Segregation Principle (ISP)**: a user who only creates logos is not forced to understand brand identity detection or Playwright. Each skill exposes exactly what is necessary for its context.

- **Bounded Context (DDD)**: the three domains have a different ubiquitous language:
  - Logo: "creative direction", "variation", "safe zone"
  - Visuals: "asset", "detected palette", "iteration"
  - Guides: "screenshot", "step", "interactive flow"
  
  Mixing these languages in a single skill would create confusion in the instructions.

- **Loose Coupling**: skills communicate via shared conventions (`brand.json`), not via direct calls. The logo produces a `brand.json` -> the visual consumes it. This is an implicit **Domain Event**.

- **Dependency Inversion Principle (DIP)**: skills depend on abstractions (the `brand.json` format, the standard Gemini API), not on implementation details. Changing the image backend doesn't break the structure.

**Why not a single "creative-studio" skill:**
- SKILL.md too long -> Claude Code would have difficulty loading it efficiently
- Ambiguous triggering -> a prompt "create a visual" would unnecessarily activate the logo logic
- SRP violation -> a change to screenshot logic would impact the logo flow
- Reduced testability -> impossible to validate a skill independently

## Consequences

- Each skill is autonomous and independently testable
- Integration between skills is achieved through conventions (`brand.json` files, `knowledge/` folder)
- Adding a new Bounded Context (e.g., "social media templates") = a new skill, not a modification of existing ones (OCP)
- Inter-skill coupling is documented in ARCHITECTURE.md
