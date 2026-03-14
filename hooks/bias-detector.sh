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
[BIAS: Brief Drift] Changement de direction detecte en cours de process.
  Risque: Perdre la coherence avec le brief original et les decisions validees.
  Action: Verifier brand.json et les decisions Phase 1/2 avant de pivoter.
  Question: Ce changement invalide-t-il le brandbook valide?"
fi

# --- BIAS 2: Perfectionnisme DA (infinite iteration) ---
# User keeps iterating without shipping
if echo "$PROMPT_LOWER" | grep -qiE "encore (une|des) variante|re-?g[eé]n[eè]re|pas (encore|tout [aà] fait)|presque|affine|peaufine|un peu plus|slightly|one more|try again|not quite|almost|tweak|ajuste encore|iterate more"; then
  WARNINGS="${WARNINGS}
[BIAS: Perfectionnisme DA] Iteration repetee detectee.
  Risque: Boucle infinie de raffinement sans livrer.
  Action: Apres 3-5 variantes, choisir et avancer.
  Question: Est-ce que cette iteration apporte une difference percevable par le client?"
fi

# --- BIAS 3: Phase Skip (wanting to jump ahead) ---
# User wants to skip pipeline phases
if echo "$PROMPT_LOWER" | grep -qiE "skip|saute(r)?|passe(r)? (la|cette) phase|direct(ement)? (phase|[aà] la)|pas besoin (de|du) brandbook|sans (le |la )?(brand|logo|exploration)|go straight|jump to|shortcut"; then
  WARNINGS="${WARNINGS}
[BIAS: Phase Skip] Tentative de sauter une phase du pipeline.
  Risque: Generer des assets sans fondation DA validee = incoherence visuelle.
  Action: Chaque phase valide les hypotheses de la precedente. brand.json est le contrat.
  Question: Les decisions de la phase precedente sont-elles validees?"
fi

# --- BIAS 4: Scope Creep Visuel (adding too much) ---
# User keeps adding visual elements or variations beyond scope
if echo "$PROMPT_LOWER" | grep -qiE "et aussi|tant qu'on y est|ajout(e|ons)|en plus|rajoute|while we'?re at it|also add|let'?s also|and also|en m[eê]me temps|on peut aussi|pendant qu'on y est|plus (de|d') (slides|visuels|variantes|directions)"; then
  WARNINGS="${WARNINGS}
[BIAS: Scope Creep Visuel] Ajout de scope detecte.
  Risque: Diluer la qualite en multipliant les livrables.
  Action: Terminer le deliverable en cours avant d'en ajouter un nouveau.
  Question: Est-ce dans le brief original ou c'est un nouveau besoin?"
fi

# --- BIAS 5: Palette Anarchie (introducing colors outside brand) ---
if echo "$PROMPT_LOWER" | grep -qiE "une? (autre|nouvelle|diff[eé]rent) couleur|ajoute(r)? (du|un|le) (rouge|vert|bleu|jaune|orange|rose|violet)|add (red|green|blue|yellow|orange|pink|purple)|change(r)? la couleur|more color"; then
  WARNINGS="${WARNINGS}
[BIAS: Palette Anarchie] Introduction de couleurs hors charte detectee.
  Risque: Briser la coherence visuelle definie dans brand.json.
  Action: Verifier si la couleur existe dans la palette brand.json avant de l'utiliser.
  Question: Cette couleur est-elle dans brand.json ou faut-il mettre a jour la charte?"
fi

# --- BIAS 6: Acceleration (rushing creative work) ---
if echo "$PROMPT_LOWER" | grep -qiE "vite|rapide(ment)?|pas le temps|no time|just do it|code direct|skip|quick|hurry|asap|urgent|fast|d[eé]p[eê]che|rush"; then
  WARNINGS="${WARNINGS}
[BIAS: Acceleration] Tentative d'acceleration detectee.
  Risque: Livrer un branding bacle = refaire 3x plus tard.
  Action: Un bon brandbook prend du temps. Chaque phase a sa valeur.
  Question: Quelle phase peut-on simplifier sans compromettre la qualite?"
fi

# Output warnings if any
if [ -n "$WARNINGS" ]; then
  echo "$WARNINGS"
fi

exit 0
