# Changelog

## [2.1.0] - 2026-03-14

### Added
- Hooks system: `bias-detector.sh` (UserPromptSubmit) — detects 6 creative cognitive biases (brief drift, DA perfectionism, phase skip, visual scope creep, palette anarchy, rush mode)
- Hooks system: `brand-consistency-check.sh` (PostToolUse Write|Edit) — checks for hardcoded colors, inline styles, CSS custom property conventions
- `hooks/hooks.json` — plugin hooks registration

## [2.0.0] - 2026-03-14

### Added
- Skill `social-carousels`: viral LinkedIn/Instagram carousels (10 slides, psychological hooks, `.pptx` export for Canva/Figma)
- Skill `brand-pipeline`: Process Manager orchestrating the brand-to-code pipeline in 5 phases with validation gates
- Agent `art-director`: creative lead (opus) with user memory for DA preferences
- Agent `visual-designer`: Nano Banana specialist for branded image generation
- Agent `carousel-copywriter`: strategic carousel copywriting with 6 hook strategies
- Agent `design-system-engineer`: React tokens, Tailwind components, cross-plugin (craftsman, frontend-design)
- Knowledge base `carousel-references/`: copywriting methodologies, viral carousel examples, hook strategies
- Supporting files for `social-carousels`: `copywriting-rules.md`, `hook-strategies.md`
- Supporting files for `brand-pipeline`: `phase-templates.md`, `brand-json-schema.md`
- ADR-008: Social Media Carousels as a Bounded Context
- ADR-009: Specialized Agents over Agent Teams

### Changed
- Pipeline upgraded from 4 to 5 phases (added Phase 5: Social Carousels) — **BREAKING**
- `brand-pipeline` restructured from 588 -> 242 lines (supporting files pattern)
- Plugin version bumped to 2.0.0
- `plugin.json` description and keywords extended to cover carousels and design system
- `ARCHITECTURE.md` rewritten to document the 4 BCs, agents, and cross-plugin dependencies

### Fixed
- Added missing `argument-hint` on `brand-visuals` and `app-guide-generator`
- Added `disable-model-invocation` on `setup-gemini` (Anthropic spec)

## [1.0.0] - 2026-03-14

### Added
- Skill `design-logo`: professional logo creation with DA reference knowledge base
- Skill `brand-visuals`: branded visual generation via Gemini API (Nano Banana) with auto-detection of project design system
- Skill `app-guide-generator`: automated user guides with Playwright screenshots
- Command `setup-gemini`: guided Gemini API key configuration
- MCP `creative-knowledge`: filesystem access to knowledge base (logo references, brand assets)
- Knowledge base structure with `logo-references/` and `brand-assets/` directories
