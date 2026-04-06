---
description: Generates comprehensive user guides with automatic screenshots via Playwright MCP. Triggered by 'guide', 'documentation', 'tutorial', 'walkthrough', 'onboarding', 'help doc', 'user manual', 'screenshot guide'.
argument-hint: [app-url]
---

# User Guides with Automatic Screenshots

Automates the creation of professional guides by navigating a web application via Playwright MCP.

## Prerequisites

- **Playwright MCP** installed at user scope:
  ```bash
  claude mcp add --scope user playwright npx @playwright/mcp@latest
  ```
- Target application accessible (localhost or public URL)

> **Note**: The Playwright MCP is intentionally outside the plugin because it serves many other uses (testing, QA, scraping). It is recommended to install it at user scope once.

## Workflow

### Phase 1 — Guide scoping

Before touching the browser, define:
- **Audience**: new user, admin, developer, end customer
- **Scope**: full walkthrough OR specific feature/flow
- **Pages/flows**: list each screen and user action
- **Format**: Markdown (default) or PDF

If not specified, ask the user. Propose a table of contents before starting.

### Phase 2 — Authentication (if needed)

If the application requires login:
1. `browser_navigate` to the login page
2. Inform the user: "I've opened the login page. Log in manually, then tell me to continue."
3. Wait for confirmation before proceeding

**NEVER enter passwords or credentials.**

### Phase 3 — Systematic capture

For each page/screen in the guide:
1. **Navigate** via `browser_navigate`
2. **Wait** for full load (no visible spinners/skeletons)
3. **Capture** the full screenshot via `browser_take_screenshot`
4. **Specific elements** if needed (forms, modals, buttons)
5. **Responsive** if requested — `browser_resize`:
   - Mobile: 375x667
   - Tablet: 768x1024
   - Desktop: 1440x900

Naming convention:
```
docs/guide/screenshots/
  01-dashboard-overview.png
  02-campaigns-list.png
  03-campaign-create-form.png
  04-campaign-create-form-mobile.png
```

### Phase 4 — Interactive flow capture

For multi-step processes:
- Screenshot **before and after** each user action
- Describe which button/field the user should use
- Capture **success and error states**
- Capture **empty states** (before data)

### Phase 5 — Guide assembly

```markdown
# [App Name] — User Guide

> Version: [date] | Audience: [target]

## Table of Contents
- [Section 1](#section-1)
...

## 1. [Section Name]

### Objective
[What the user accomplishes — 1-2 sentences]

### Steps

**1. [Action description]**

![Description](./screenshots/01-name.png)

[Concise explanation of what the user sees and does.]

**2. [Next action]**

![Description](./screenshots/02-name.png)

### Points of attention
- [Pitfalls, tips, warnings]
```

### Phase 6 — Delivery

- `docs/guide/screenshots/` for images
- `docs/guide/README.md` for the guide

## Quality standards

- **Language**: English by default unless otherwise requested
- **Text**: imperative and concise ("Click on..." not "The user can click...")
- **Structure**: 1 action = 1 step = 1 screenshot
- **Viewport**: consistent across all screenshots unless comparing responsive layouts
- **Naming**: descriptive, numbered, zero ambiguity

## Anti-patterns

- Screenshots taken before full page load (visible spinners)
- Sensitive data captured (API keys, real emails, passwords)
- Screenshots with visible console errors
- Guide without table of contents
- Screenshots without textual context
- Assuming the user knows the app — write for a beginner
