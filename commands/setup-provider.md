---
name: setup-provider
description: Configures the image provider (Gemini or OpenAI) for logo generation, visuals, and 3D renders. Use only on explicit request.
disable-model-invocation: true
---

Guides the user through configuring their professional image provider.

## Provider detection

Check `userConfig.image_provider` in the plugin configuration:
- `gemini` (default) → configure `GEMINI_API_KEY`
- `openai` → configure `OPENAI_IMAGE_KEY`

## Verification

First check if the key is already configured:
- Gemini: `echo $GEMINI_API_KEY`
- OpenAI: `echo $OPENAI_IMAGE_KEY`
- If the variable exists and is not empty → inform that it's ready

## Gemini configuration (Nano Banana)

1. **Explain**: "To generate images (logos, 3D visuals), you need a Gemini API key. It's free: ~500 images/day with Flash."
2. **Guide** to https://aistudio.google.com/apikey → "Create API Key" → copy
3. **Ask** the user to paste their key
4. **Add** to the shell profile (`.zshrc` or `.bashrc`): `export GEMINI_API_KEY="the-key"`
5. **Test** with a minimal call

## OpenAI configuration

1. **Explain**: "To generate images with OpenAI (gpt-image-1), you need a paid API key. ~$0.04-0.19 per image depending on size."
2. **Guide** to https://platform.openai.com/api-keys → "Create new secret key" → copy
3. **Ask** the user to paste their key
4. **Add** to the shell profile: `export OPENAI_IMAGE_KEY="the-key"`
5. **Test** with a minimal call

## Switching providers

To change the default provider, update the plugin configuration:
```
/plugin config claude-creative-studio image_provider openai
```
or
```
/plugin config claude-creative-studio image_provider gemini
```

## Important

- NEVER display the key in plaintext in logs
- NEVER commit the key to a git repository
- CI/CD: use GitHub/GitLab secrets
- The Gemini key is free, OpenAI is paid
