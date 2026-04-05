# ADR-001: Claude Code Plugin over Bash Script

**Date**: 2026-03-14
**Status**: accepted

## Context

The project was initially distributed via a bash script (`setup-creative-studio.sh`) that manually created folders, copied skills, and configured MCP servers via `claude mcp add`. This approach worked but posed problems in terms of maintainability, reproducibility, and accessibility for non-technical users.

## Decision

Migrate to the official **Claude Code Plugin** format (Anthropic spec, October 2025) with a `plugin.json` manifest, a `.mcp.json` for automatic MCP configuration, and the standard `skills/`, `commands/`, `knowledge/` structure.

## Rationale

**For the plugin:**
- One-command installation: `/plugin install BULDEE/claude-creative-studio`
- Auto-configured MCP via `.mcp.json` (zero manual `claude mcp add`)
- Auto-discovered and namespaced skills (`claude-creative-studio:design-logo`)
- Distribution via official Anthropic marketplace or GitHub
- Centralized updates — the user pulls a version, not re-runs a script
- Shared convention with the Claude Code ecosystem

**Against the bash script:**
- Fragile: depends on the shell, paths, and availability of commands
- No built-in versioning
- No namespace — risk of collision with other skills
- Manual update maintenance
- Outside the ecosystem — invisible in `/plugin list`

## Consequences

- The `setup-creative-studio.sh` script is deprecated
- Existing skills in `~/.claude/skills/` must be migrated to the plugin
- Manually configured MCPs (`knowledge-base`) are replaced by the plugin's `.mcp.json`
- Users install via the native plugin system
