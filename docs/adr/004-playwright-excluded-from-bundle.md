# ADR-004: Playwright MCP Excluded from Plugin Bundle

**Date**: 2026-03-14
**Status**: accepted

## Context

The `app-guide-generator` skill depends on the Playwright MCP to navigate web applications and capture screenshots. The question is whether this MCP should be included in the plugin's `.mcp.json` or installed separately by the user.

## Decision

The Playwright MCP is **excluded** from the plugin bundle. It is installed separately at user scope.

## Rationale

**Why exclude:**

1. **Single Responsibility Principle (SRP)**: the plugin is a creative toolkit, not a browser automation tool. Playwright serves many other purposes (tests, QA, scraping, exploration).

2. **Avoid duplication**: if the user already has Playwright MCP installed (very common among developers), including it in the plugin would create a duplicate that unnecessarily consumes context window.

3. **Different scope**: the `creative-knowledge` MCP is plugin-specific (plugin scope). Playwright is a cross-cutting tool (user scope). Mixing scopes violates separation of responsibilities.

4. **Optional**: only 1 out of 3 skills uses Playwright. Forcing its installation for the 2/3 of users who won't create guides is waste.

**How it works:**
- The `app-guide-generator` skill documents the prerequisite in its SKILL.md
- If Playwright is not installed and the user requests a guide, Claude Code informs them and provides the installation command
- The plugin README lists Playwright as an optional prerequisite

## Consequences

- Installing the plugin is not sufficient for the `app-guide-generator` skill — an additional step is required
- Accepted trade-off: plugin simplicity > guide generator completeness
- If other skills require Playwright in the future, this decision should be re-evaluated
