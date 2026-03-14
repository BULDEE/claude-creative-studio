# Gemini Image Generation API — Reference

Fichier de référence unique pour tous les skills utilisant Nano Banana (Gemini Image API).
Modifier ce fichier si l'API Gemini change — les skills `design-logo`, `brand-visuals` et `social-carousels` le référencent.

## Pre-flight check

Avant toute génération, vérifier :
1. `GEMINI_API_KEY` est définie dans l'environnement
2. Si absente, rediriger vers `/claude-creative-studio:setup-gemini`

```javascript
if (!process.env.GEMINI_API_KEY) {
  console.error("GEMINI_API_KEY manquante. Lancez /claude-creative-studio:setup-gemini");
  process.exit(1);
}
```

## Modèles disponibles

| Modèle | API ID | Usage | Free tier |
|--------|--------|-------|-----------|
| Nano Banana 2 (Flash) | `gemini-3.1-flash-image-preview` | Itération rapide, exploration | ~500/jour |
| Nano Banana Pro | `gemini-3-pro-image-preview` | Assets finaux 4K, texte dans image | ~3/jour |

**Règle** : Flash pour itérer, Pro uniquement pour l'asset final ou si texte requis dans l'image.

## Génération simple (sans référence)

```javascript
import { GoogleGenAI } from "@google/genai";
import fs from "fs";

const client = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const response = await client.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: [{ parts: [{ text: PROMPT }] }],
  generationConfig: { responseModalities: ["IMAGE"] }
});

const part = response.candidates[0].content.parts.find(p => p.inlineData);
if (part) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  fs.writeFileSync(`${OUTPUT_DIR}/asset-${Date.now()}.png`,
    Buffer.from(part.inlineData.data, "base64"));
}
```

## Génération avec style transfer (image de référence)

```javascript
const ref = fs.readFileSync(REFERENCE_IMAGE_PATH);
const response = await client.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: [{
    parts: [
      { inlineData: { mimeType: "image/png", data: ref.toString("base64") } },
      { text: `Create a new visual in the exact same style. ${PROMPT}` }
    ]
  }],
  generationConfig: { responseModalities: ["IMAGE"] }
});
```

## Fallback en cas d'échec

1. **Simplifier le prompt** — retirer les hex codes, garder 3 mots-clés de style max
2. **Réduire la complexité** — fond uni + sujet centré
3. **Si toujours en échec** — documenter le prompt dans un fichier `visual-brief.md` pour génération manuelle via [AI Studio](https://aistudio.google.com)

## Prompt template standard

```
[TYPE] pour [PRODUIT/MARQUE].
Sujet : [DESCRIPTION].
Style : [KEYWORDS]. Color palette: [HEX CODES].
Mood : [MOOD KEYWORDS].
Composition : [LAYOUT + ESPACE TEXTE].
Format : [RATIO]. No text in image. Premium quality.
```

## Variables à remplacer

| Variable | Source | Exemple |
|----------|--------|---------|
| `PROMPT` | Construit par le skill | Voir template ci-dessus |
| `OUTPUT_DIR` | Défini par le skill | `logos/`, `visuals/`, `carousels/slides/` |
| `REFERENCE_IMAGE_PATH` | Image validée précédente | `visuals/approved-reference.png` |
| `HEX CODES` | `brand.json.colors` | `#6366F1 primary, #8B5CF6 secondary` |
