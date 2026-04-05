# ADR-005: Brand Identity Detection via Contextual Cascade

**Date**: 2026-03-14
**Status**: accepted

## Context

The `brand-visuals` skill generates visuals that must be consistent with the current project's visual identity. The problem: how to obtain the color palette and style without requiring the user to manually configure a file each time?

## Decision

Implement a **cascade pattern** (Chain of Responsibility) that resolves the brand identity in descending priority order, stopping at the first source found.

### Resolution Order

```
1. brand.json / brand.yaml    ← Explicit source (highest priority)
2. tailwind.config.*           ← Custom color extraction
3. CSS custom properties       ← --color-* variables in root CSS
4. .claude/CLAUDE.md           ← Palette mentions in project context
5. package.json                ← Name and description for context
6. Ask the user                ← Ultimate fallback
```

## Rationale

**Applied principles:**

- **Open/Closed Principle (OCP)**: the cascade is extensible — adding a new source (e.g., Figma tokens) does not require modifying existing sources, just inserting a new level in the chain.

- **Convention over Configuration**: in 90% of modern web projects, the palette is in Tailwind or CSS variables. The skill finds it without any user configuration.

- **Explicit is better than implicit**: despite auto-detection, the skill **always displays** the detected palette and **asks for validation** before generating. The user retains control.

- **Fail gracefully**: if no source is found, it doesn't fail — it asks the user. No error, no blocking.

**Why not a mandatory config (`brand.json` required):**
- Onboarding friction too high for non-technical users
- Most projects already have their colors in Tailwind
- Forcing an additional file violates the principle of least surprise

**Why not a single entry point (e.g., Tailwind only):**
- Not all projects use Tailwind
- Some projects have a richer `brand.json` (style, mood, keywords)
- The cascade covers the maximum number of cases without assumptions

## Consequences

- The skill must clearly document the resolution order
- `brand.json` is the recommended format in the docs for users who want full control
- User validation before generation is mandatory (no silent auto-generation)
- Sources are read lazily (stops at the first one found)
