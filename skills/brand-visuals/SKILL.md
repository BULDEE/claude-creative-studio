---
name: brand-visuals
description: Génère des visuels brandés (hero images, illustrations, bannières, OG images) via l'API Gemini (Nano Banana). Détecte automatiquement la DA du projet courant via Tailwind config, CSS variables, brand.json ou CLAUDE.md. Déclenché par 'visual', 'hero image', 'illustration', 'banner', 'OG image', 'brand asset', 'Nano Banana', 'visuel brandé', 'generate image'.
argument-hint: [asset-type] [subject]
---

# Visuels Brandés — Gemini Image API (Nano Banana)

Génère des visuels cohérents avec l'identité visuelle du projet en cours.

## Prérequis

- `GEMINI_API_KEY` en variable d'environnement — si absente, rediriger vers `/claude-creative-studio:setup-gemini`
- Clé gratuite : https://aistudio.google.com/apikey (~500 images/jour)
- Référence API : voir [gemini-api-reference.md](../gemini-api-reference.md) pour les templates de génération et le fallback

## Modèles disponibles

| Modèle | API ID | Usage | Free tier |
|--------|--------|-------|-----------|
| Nano Banana 2 | `gemini-3.1-flash-image-preview` | Itération rapide | ~500/jour |
| Nano Banana Pro | `gemini-3-pro-image-preview` | Assets finaux 4K | ~3/jour |

**Défaut** : `gemini-3.1-flash-image-preview` pour itérer, Pro pour les assets finaux.

## Détection automatique de la DA

Détecter le contexte du projet plutôt qu'utiliser une palette hardcodée.

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

## Fallback si Nano Banana échoue

Si la génération échoue (quota, erreur API, image non conforme) :
1. **Simplifier le prompt** — retirer les hex codes, garder 3 mots-clés de style max
2. **Réduire la complexité** — demander une composition plus simple (fond uni + sujet centré)
3. **Si toujours en échec** — documenter le prompt détaillé dans un fichier `visual-brief.md` pour que l'utilisateur génère manuellement via AI Studio

<avoid>
- Palette hardcodée sans vérifier le contexte projet
- Visuels stock-photo génériques
- Style incohérent entre les pages
- Texte dans les images sans Nano Banana Pro
- Générer sans brief
- Clés API hardcodées
</avoid>

<example>
**Brief** : Hero image pour une fintech, palette brand.json détectée (#6366F1, #8B5CF6, #06B6D4)

**Prompt construit** :
```
Hero image for fintech landing page.
Style: modern, clean, premium. Abstract 3D shapes and gradients.
Color palette: #6366F1 primary, #8B5CF6 secondary, #06B6D4 accent.
Mood: professional, innovative, trustworthy.
Composition: 40% left for text overlay, key visual right.
Format: 16:9. No text. Premium quality.
```

**Self-check** : palette fidèle, espace texte suffisant, pas de texte dans l'image, mood cohérent avec les keywords brand.json.
</example>

## Self-check avant livraison

Avant de présenter un visuel, vérifier :
1. La palette utilisée correspond aux hex codes de `brand.json` ou de la source détectée
2. Le style respecte les keywords et le mood définis
3. Il n'y a pas de texte dans l'image (sauf demande explicite + utilisation de Pro)
4. L'espace pour l'overlay texte est suffisant (40% minimum pour hero/social)
5. Le visuel fonctionne au ratio demandé
