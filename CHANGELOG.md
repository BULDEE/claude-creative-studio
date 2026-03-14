# Changelog

## [2.1.0] - 2026-03-14

### Added
- Hooks system: `bias-detector.sh` (UserPromptSubmit) — detecte 6 biais cognitifs créatifs (brief drift, perfectionnisme DA, phase skip, scope creep visuel, palette anarchie, acceleration)
- Hooks system: `brand-consistency-check.sh` (PostToolUse Write|Edit) — vérifie couleurs hardcodées, styles inline, convention CSS custom properties
- `hooks/hooks.json` — registration des hooks plugin

## [2.0.0] - 2026-03-14

### Added
- Skill `social-carousels`: carrousels LinkedIn/Instagram viraux (10 slides, hooks psychologiques, export `.pptx` Canva/Figma)
- Skill `brand-pipeline`: Process Manager orchestrant le pipeline brand-to-code en 5 phases avec validation gates
- Agent `art-director`: lead créatif (opus) avec memory utilisateur pour les préférences DA
- Agent `visual-designer`: spécialiste Nano Banana pour la génération d'images brandées
- Agent `carousel-copywriter`: copywriting stratégique carrousels avec 6 stratégies de hooks
- Agent `design-system-engineer`: React tokens, composants Tailwind, cross-plugin (craftsman, frontend-design)
- Knowledge base `carousel-references/`: méthodologies copywriting, exemples carrousels viraux, stratégies hooks
- Supporting files pour `social-carousels`: `copywriting-rules.md`, `hook-strategies.md`
- Supporting files pour `brand-pipeline`: `phase-templates.md`, `brand-json-schema.md`
- ADR-008: Social Media Carousels comme Bounded Context
- ADR-009: Agents spécialisés plutôt que Agent Teams

### Changed
- Pipeline passe de 4 à 5 phases (ajout Phase 5: Social Carousels) — **BREAKING**
- `brand-pipeline` restructuré de 588 → 242 lignes (supporting files pattern)
- Plugin version bumped to 2.0.0
- `plugin.json` description et keywords étendus pour couvrir carousels et design system
- `ARCHITECTURE.md` réécrit pour documenter les 4 BCs, agents, et cross-plugin dependencies

### Fixed
- Ajout `argument-hint` manquant sur `brand-visuals` et `app-guide-generator`
- Ajout `disable-model-invocation` sur `setup-gemini` (spec Anthropic)

## [1.0.0] - 2026-03-14

### Added
- Skill `design-logo`: professional logo creation with DA reference knowledge base
- Skill `brand-visuals`: branded visual generation via Gemini API (Nano Banana) with auto-detection of project design system
- Skill `app-guide-generator`: automated user guides with Playwright screenshots
- Command `setup-gemini`: guided Gemini API key configuration
- MCP `creative-knowledge`: filesystem access to knowledge base (logo references, brand assets)
- Knowledge base structure with `logo-references/` and `brand-assets/` directories
