---
name: brand-visuals
description: Génère des visuels brandés (hero images, illustrations, bannières, OG images) via l'API Gemini (Nano Banana). Détecte automatiquement la DA du projet courant via Tailwind config, CSS variables, brand.json ou CLAUDE.md. Déclenché par 'visual', 'hero image', 'illustration', 'banner', 'OG image', 'brand asset', 'Nano Banana', 'visuel brandé', 'generate image'.
---

# Visuels Brandés — Gemini Image API (Nano Banana)

Génère des visuels cohérents avec l'identité visuelle du projet en cours.

## Prérequis

- `GEMINI_API_KEY` en variable d'environnement (voir `/claude-creative-studio:setup-gemini`)
- Clé gratuite : https://aistudio.google.com/apikey (~500 images/jour)

## Modèles disponibles

| Modèle | API ID | Usage | Free tier |
|--------|--------|-------|-----------|
| Nano Banana 2 | `gemini-3.1-flash-image-preview` | Itération rapide | ~500/jour |
| Nano Banana Pro | `gemini-3-pro-image-preview` | Assets finaux 4K | ~3/jour |

**Défaut** : `gemini-3.1-flash-image-preview` pour itérer, Pro pour les assets finaux.

## Détection automatique de la DA

**Ne jamais utiliser une palette hardcodée.** Toujours détecter le contexte du projet.

### Ordre de résolution (du plus spécifique au plus général)

1. **`brand.json`** ou `brand.yaml` dans la racine du projet ou `.claude/`
2. **`tailwind.config.*`** → extraire `theme.extend.colors`
3. **CSS custom properties** → scanner les fichiers CSS racine pour `--color-primary`, etc.
4. **`.claude/CLAUDE.md`** du projet → chercher des mentions de palette, couleurs, style
5. **`package.json`** → le champ `name` et `description` donnent le contexte produit
6. **Demander à l'utilisateur** → si aucune source trouvée

**Toujours afficher la palette détectée et demander validation avant de générer.**

### Format brand.json recommandé

```json
{
  "name": "MonProduit",
  "tagline": "Description courte",
  "colors": {
    "primary": "#6366F1",
    "secondary": "#8B5CF6",
    "accent": "#06B6D4",
    "background": "#0F172A",
    "surface": "#F8FAFC"
  },
  "style": {
    "keywords": ["modern", "clean", "premium"],
    "mood": ["professional", "innovative"],
    "avoid": ["clipart", "stock-photo", "cartoon"]
  }
}
```

## Workflow

### 1. Détecter la DA
Suivre l'ordre de résolution ci-dessus. Afficher la palette trouvée.

### 2. Définir le brief
- **Type d'asset** : hero, feature, OG image, social, banner
- **Sujet** : ce que l'image doit représenter
- **Dimensions** : 16:9 (hero), 1:1 (social), 1200x630 (OG)

### 3. Construire le prompt

```
[TYPE] pour [PRODUIT].
Sujet : [DESCRIPTION].
Style : [KEYWORDS BRAND].
Palette : [HEX CODES].
Ambiance : [MOOD].
Composition : [LAYOUT].
Format : [RATIO].
Pas de texte sauf demande explicite. Qualité premium.
```

### 4. Générer

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
  fs.mkdirSync("visuals", { recursive: true });
  fs.writeFileSync(`visuals/asset-${Date.now()}.png`,
    Buffer.from(part.inlineData.data, "base64"));
}
```

### 5. Itérer avec référence

Pour la cohérence, envoyer une image validée comme référence :

```javascript
const ref = fs.readFileSync("visuals/approved-reference.png");
const response = await client.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: [{
    parts: [
      { inlineData: { mimeType: "image/png", data: ref.toString("base64") } },
      { text: "Create a new visual in the exact same style. New subject: [DESC]." }
    ]
  }],
  generationConfig: { responseModalities: ["IMAGE"] }
});
```

## Types d'assets

| Type | Ratio | Composition |
|------|-------|-------------|
| Hero | 16:9 / 21:9 | 40% espace texte overlay, high-impact |
| Feature | 1:1 / 4:3 | Sujet centré, fond clean, un concept |
| OG Image | 1200x630 | Lisible en petit, texte via Pro |
| Social | 1:1 / 16:9 | Eye-catching, brand-consistent |
| Banner | variable | Haut contraste, éléments minimaux |

## Standards

- **Itérer** : 3-5 variantes minimum, sélectionner, raffiner
- **Cohérence** : une fois un style validé, l'utiliser en référence pour la suite
- **Pas de texte par défaut** : sauf demande explicite
- **Fidélité couleur** : toujours inclure les hex codes dans le prompt

## Anti-patterns

- ❌ Palette hardcodée sans vérifier le contexte projet
- ❌ Visuels stock-photo génériques
- ❌ Style incohérent entre les pages
- ❌ Texte dans les images sans Nano Banana Pro
- ❌ Générer sans brief
- ❌ Clés API hardcodées
