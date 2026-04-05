#!/usr/bin/env bash
# Creative Bias Detector — Claude Creative Studio
# Runs on UserPromptSubmit to detect cognitive biases common in branding/creative work.
# Read-only: no file modifications, no network access, no command execution.

set -euo pipefail

# Read prompt from stdin (JSON: { "prompt": "..." })
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | grep -o '"prompt":"[^"]*"' 2>/dev/null | head -1 | sed 's/"prompt":"//;s/"$//' || echo "")

# If no prompt extracted, try alternate JSON format
if [ -z "$PROMPT" ]; then
  PROMPT=$(echo "$INPUT" | sed 's/.*"prompt"[[:space:]]*:[[:space:]]*"//;s/".*//' 2>/dev/null || echo "")
fi

# Lowercase for matching
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

WARNINGS=""

# --- BIAS 1: Brief Drift (creative scope creep) ---
# User wants to change direction mid-process without validating
if echo "$PROMPT_LOWER" | grep -qiE "change(r|ons)? (la|les|de) (palette|couleur|direction|typo|font)|nouveau(x|lle)? style|repartir de z[eé]ro|recommence|scrap|start over|different direction|change the (colors|palette|style|font)"; then
  WARNINGS="${WARNINGS}
[BIAS: Brief Drift] Direction change detected mid-process.
  Risk: Losing consistency with the original brief and validated decisions.
  Action: Check brand.json and Phase 1/2 decisions before pivoting.
  Question: Does this change invalidate the validated brandbook?"
fi

# --- BIAS 2: AD Perfectionism (infinite iteration) ---
# User keeps iterating without shipping
if echo "$PROMPT_LOWER" | grep -qiE "encore (une|des) variante|re-?g[eé]n[eè]re|pas (encore|tout [aà] fait)|presque|affine|peaufine|un peu plus|slightly|one more|try again|not quite|almost|tweak|ajuste encore|iterate more"; then
  WARNINGS="${WARNINGS}
[BIAS: AD Perfectionism] Repeated iteration detected.
  Risk: Infinite refinement loop without shipping.
  Action: After 3-5 variants, choose and move forward.
  Question: Does this iteration produce a difference the client will actually notice?"
fi

# --- BIAS 3: Phase Skip (wanting to jump ahead) ---
# User wants to skip pipeline phases
if echo "$PROMPT_LOWER" | grep -qiE "skip|saute(r)?|passe(r)? (la|cette) phase|direct(ement)? (phase|[aà] la)|pas besoin (de|du) brandbook|sans (le |la )?(brand|logo|exploration)|go straight|jump to|shortcut"; then
  WARNINGS="${WARNINGS}
[BIAS: Phase Skip] Attempt to skip a pipeline phase detected.
  Risk: Generating assets without a validated AD foundation = visual inconsistency.
  Action: Each phase validates the hypotheses of the previous one. brand.json is the contract.
  Question: Have the previous phase decisions been validated?"
fi

# --- BIAS 4: Visual Scope Creep (adding too much) ---
# User keeps adding visual elements or variations beyond scope
if echo "$PROMPT_LOWER" | grep -qiE "et aussi|tant qu'on y est|ajout(e|ons)|en plus|rajoute|while we'?re at it|also add|let'?s also|and also|en m[eê]me temps|on peut aussi|pendant qu'on y est|plus (de|d') (slides|visuels|variantes|directions)"; then
  WARNINGS="${WARNINGS}
[BIAS: Visual Scope Creep] Scope addition detected.
  Risk: Diluting quality by multiplying deliverables.
  Action: Finish the current deliverable before adding a new one.
  Question: Is this in the original brief or is it a new need?"
fi

# --- BIAS 5: Palette Anarchy (introducing colors outside brand) ---
if echo "$PROMPT_LOWER" | grep -qiE "une? (autre|nouvelle|diff[eé]rent) couleur|ajoute(r)? (du|un|le) (rouge|vert|bleu|jaune|orange|rose|violet)|add (red|green|blue|yellow|orange|pink|purple)|change(r)? la couleur|more color"; then
  WARNINGS="${WARNINGS}
[BIAS: Palette Anarchy] Off-brand color introduction detected.
  Risk: Breaking the visual consistency defined in brand.json.
  Action: Check if the color exists in the brand.json palette before using it.
  Question: Is this color in brand.json or does the brand guidelines need updating?"
fi

# --- BIAS 6: Rushing (rushing creative work) ---
if echo "$PROMPT_LOWER" | grep -qiE "vite|rapide(ment)?|pas le temps|no time|just do it|code direct|skip|quick|hurry|asap|urgent|fast|d[eé]p[eê]che|rush"; then
  WARNINGS="${WARNINGS}
[BIAS: Rushing] Attempt to rush detected.
  Risk: Delivering sloppy branding = redoing it 3x later.
  Action: Good branding takes time. Each phase has its value.
  Question: Which phase can be simplified without compromising quality?"
fi

# Output warnings if any
if [ -n "$WARNINGS" ]; then
  echo "$WARNINGS"
fi

exit 0
