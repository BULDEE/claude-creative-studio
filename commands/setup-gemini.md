---
name: setup-gemini
description: Configures the Gemini API key for image generation with Nano Banana. Use only on explicit user request.
disable-model-invocation: true
---

Guides the user through configuring their Gemini API key (free) to generate images with Nano Banana.

## Verification

First check if `GEMINI_API_KEY` is already configured:
- Test `echo $GEMINI_API_KEY` via bash
- If the variable exists and is not empty → inform the user they're ready and stop

## Configuration

If the key is not configured:

1. **Explain**: "To generate images (logos, visuals), you need a Gemini API key. It's free: 500 images per day."

2. **Guide** to https://aistudio.google.com/apikey
   - Click "Create API Key"
   - Copy the key

3. **Ask** the user to paste their key

4. **Add** the key to the shell profile:
   - Detect the shell: `.zshrc` (macOS default) or `.bashrc`
   - Verify that `GEMINI_API_KEY` is not already in the file
   - Add: `export GEMINI_API_KEY="the-key"`
   - Inform: "Run `source ~/.zshrc` or open a new terminal"

5. **Test**: run a minimal call to verify the key works

## Important

- NEVER display the key in plaintext in logs
- NEVER commit the key to a git repository
- If the user is in a CI/CD context, suggest using GitHub/GitLab secrets
