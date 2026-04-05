# ADR-009: Specialized Agents over Agent Teams

**Date**: 2026-03-14
**Status**: accepted

## Context

The brand-to-code pipeline involves several distinct creative roles (art director, visual designer, copywriter, design system engineer). Two approaches are possible:

1. **Agents** in `agents/` — classic subagents, stable, production-ready
2. **Agent Teams** — experimental Claude Code feature, coordinated multi-session

## Decision

Implement **specialized agents** in the plugin's `agents/` directory, architected for future migration to Agent Teams when the feature becomes stable.

## Rationale

### Why not Agent Teams now

The official Anthropic documentation is explicit:

> "Agent teams are experimental and disabled by default."

Documented limitations:
- No session resumption with teammates in-process
- Task status can lag (teammates forget to mark tasks)
- Slow shutdown
- Only one team per session
- No nested teams

For a plugin distributed to users, these limitations are unacceptable.

### Why agents in the plugin

Agents in `agents/` are:
- **Stable** — GA (Generally Available) Claude Code feature
- **Distributable** — copied into the plugin cache at installation
- **Testable** — individually invocable via `/agents`
- **Customizable** — each agent has its own tools, model, and preloaded skills

### Architecture ready for teams

The 4 agents are designed to become teammates:

```
Today (subagents)                Tomorrow (agent teams)
─────────────────                ────────────────────
art-director (opus)        →    Team lead
visual-designer (sonnet)   →    Teammate: visuals
carousel-copywriter (sonnet) →  Teammate: copy
design-system-engineer (sonnet) → Teammate: code
```

The agents have:
- Clearly separated roles (no overlap)
- Preloaded skills that define their expertise
- Sufficiently detailed descriptions for automatic delegation
- The `art-director` agent has `memory: user` to learn preferences

### Applied principles

- **OCP**: when Agent Teams becomes stable, a `settings.json` with `"agent": "art-director"` is added without modifying the agents
- **ISP**: each agent is usable independently
- **SRP**: each agent has a single creative role

## Consequences

- 4 files in `agents/` distributed with the plugin
- Agents work immediately as subagents
- Migration to Agent Teams will be a configuration change, not a code change
- The `art-director` agent uses opus (more expensive but justified for creative decisions)
- The other 3 use sonnet (good quality/cost ratio for execution)
