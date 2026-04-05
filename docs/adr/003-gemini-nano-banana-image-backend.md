# ADR-003: Gemini (Nano Banana) as Image Generation Backend

**Date**: 2026-03-14
**Status**: accepted

## Context

Several image generation APIs are available: DALL-E (OpenAI), Midjourney (via proxy), Stable Diffusion (Stability AI, Replicate), Flux (fal.ai), and Gemini Image / Nano Banana (Google). The choice impacts cost, quality, ease of integration, and accessibility for non-technical users.

## Decision

Use the Gemini API (Nano Banana 2 / Nano Banana Pro) as the primary image generation backend.

## Rationale

| Criteria | Gemini | DALL-E 3 | Midjourney | Stable Diffusion |
|----------|--------|----------|------------|------------------|
| Free tier | ~500/day | 0 | 0 | Limited |
| Paid cost | ~$0.04/img | $0.04-0.08 | $10-60/month | Variable |
| Direct API | ✅ REST | ✅ REST | ❌ Discord/proxy | ✅ REST |
| Logo quality | Good | Good | Excellent | Variable |
| Text in image | Excellent (Pro) | Medium | Good | Weak |
| Style transfer | ✅ Multi-ref | ❌ | ❌ | ✅ |
| Setup | 1 API key | 1 API key | Complex | Complex |

**Decisive arguments:**
- **500 free images/day** — eliminates the financial barrier for non-technical users
- **Simple REST API** — a single endpoint, no webhook or polling
- **Native style transfer** — send a reference image + text prompt
- **Text in images** — Nano Banana Pro renders readable text (useful for logos)
- **No vendor lock-in** — the skill generates a standard Node.js script, replaceable

**Accepted risks:**
- Dependency on Google (mitigated: the script is a template, not an opaque abstraction)
- Lower quality than Midjourney for artistic style (acceptable for logo prototyping)
- Free tier may evolve (mitigated: 500/day is more than sufficient, paid tier remains competitive)

## Consequences

- The `GEMINI_API_KEY` is the only prerequisite for image generation
- Image generation is optional — skills work without it (text description mode)
- The generation script is inline in the SKILL.md, not an npm dependency
- If a better backend emerges, only the script template in the skills needs modification (SRP)
