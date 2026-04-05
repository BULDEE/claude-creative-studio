# Contributing

## Quick Start

1. Fork the repo
2. Clone: `git clone git@github.com:YOUR_USER/claude-creative-studio.git`
3. Test locally: `claude --plugin-dir ./claude-creative-studio`
4. Create a branch: `git checkout -b feat/my-addition`
5. Commit: `git commit -m "feat: description"`
6. Push + PR

## Conventions

### Commits

**Conventional Commits** format in English:

```
feat: add social media template skill
fix: correct brand detection for CSS modules
docs: add ADR for Figma token support
refactor: extract prompt template in design-logo
```

Types: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`

### Branches

```
feat/feature-name
fix/bug-description
docs/topic
```

### SKILL.md

Each skill must follow these conventions:

1. **Frontmatter**: `name`, `description` (including triggers), `argument-hint`
2. **Structure**: Prerequisites -> Workflow (numbered phases) -> Deliverable -> Anti-patterns -> Self-check
3. **Language**: French for content, English for code
4. **Tone**: clear and direct instructions (no aggressive language, Claude 4.6 does not need it)
5. **XML tags**: use `<constraints>`, `<avoid>`, `<example>`, `<validation_checkpoint>` for structure
6. **Anti-patterns**: explicit list in an `<avoid>` block
7. **Self-check**: validation section before delivery
8. **Limit**: max 500 lines — extract details into supporting files (e.g., `copywriting-rules.md`)

### Supporting Files

For complex skills, extract reference content into separate files:

```
skills/my-skill/
├── SKILL.md              <- Orchestrator (< 500 lines)
├── reference-rules.md    <- Detailed rules (loaded on demand)
└── examples.md           <- Complete examples (loaded on demand)
```

Reference from SKILL.md: `[reference-rules.md](reference-rules.md)`

### Agents

Each agent in `agents/` must have:

1. **Frontmatter**: `name`, `description`, `model`, `skills`, `tools`
2. **Optional**: `memory: user` if the agent needs to retain preferences
3. **Clear role**: one agent = one responsibility (SRP)
4. **Self-check**: validation section before delivery
5. **Output format**: document how the agent presents its results

### Gemini API

Image API call templates are centralized in `skills/image-provider-reference.md`. This file covers Gemini (Nano Banana) and OpenAI (gpt-image-1). If an API changes, modify this single file — skills reference it.

### ADR

For any significant architectural decision:

1. Create `docs/adr/NNN-title-kebab.md`
2. Follow the template: Context -> Decision -> Rationale -> Consequences
3. Update `docs/adr/README.md`

## Adding a New Skill

1. Create `skills/my-skill/SKILL.md` (follow conventions above)
2. Add supporting files if content exceeds 500 lines
3. Document integration with existing skills
4. Reference `image-provider-reference.md` if the skill generates images
5. Update the main README.md (components table)
6. Create an ADR if the skill introduces a new Bounded Context

## Adding a New Agent

1. Create `agents/my-agent.md` with full frontmatter
2. Associate required skills in the `skills` field
3. Declare required tools in the `tools` field
4. Update `docs/ARCHITECTURE.md` (agents table + agent-to-phase mapping)
5. Update the main README.md

## Adding to the Knowledge Base

1. Place files in the appropriate subfolder of `knowledge/`
   - `logo-references/`: brand guidelines, existing logos
   - `brand-assets/`: final logos, palettes, guidelines
   - `carousel-references/`: carousel examples, copywriting methodologies
2. Update `knowledge/README.md` if needed
3. Supported formats: PDF, PNG, JPG, SVG, JSON, YAML, MD, DOCX

## Adding a DA Source to the Cascade

1. Edit `skills/brand-visuals/SKILL.md`
2. Insert the new source at the correct position in the priority order
3. Document in ADR-005 (or create an ADR if the strategy changes)

## Testing

Testing a skill:

```bash
# Run Claude Code with the plugin locally
claude --plugin-dir /path/to/claude-creative-studio

# Verify the plugin is loaded
/plugin list

# Check MCPs
/mcp

# Test a skill
"Create a logo for TestCorp in the tech sector"

# Test an agent
"@art-director propose 3 directions for TestCorp"
```
