# ADR-002: Knowledge Base via MCP Filesystem

**Date**: 2026-03-14
**Status**: accepted

## Context

Design skills need access to reference files (brand guideline PDFs, existing logo images, moodboards). Several approaches are possible: embedding in the prompt, manual upload each session, vector database (RAG), or filesystem access via MCP.

## Decision

Use the `@modelcontextprotocol/server-filesystem` MCP pointed at the plugin's `knowledge/` folder via `.mcp.json`.

## Rationale

**Why MCP Filesystem:**
- **Zero infrastructure**: no vector server, no database, no third-party API
- **Native access**: Claude Code reads files as if they were in the context
- **Trivial updates**: the user drops a file into the folder, and it's immediately available
- **Multi-format**: PDF, PNG, SVG, JSON — the MCP filesystem handles everything

**Why not RAG / vector database:**
- YAGNI — the volume of references is low (a dozen files at most)
- Semantic search adds no value here: Claude reads each reference sequentially
- Adds a heavy infrastructure dependency (embedding model, vector store)
- Complicates installation for non-technical users

**Why not embedding in the prompt:**
- PDFs and images cannot be embedded as text in a SKILL.md
- Context window size would be permanently wasted
- No updates possible without modifying the skill

## Consequences

- The `knowledge/` folder is the source of truth for references
- Reference files are ignored by git (`.gitignore`) — each user has their own references
- `.gitkeep` files maintain the empty folder structure in the repo
- If the volume of references exceeds ~50 files, reconsider an index or lightweight RAG (future ADR)
