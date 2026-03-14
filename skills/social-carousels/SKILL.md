---
name: social-carousels
description: Génère des carrousels LinkedIn/Instagram haute performance avec copywriting viral et visuels brandés via Nano Banana. Exporte en frames éditables (Canva ou Figma au choix). Déclenché par 'carrousel', 'carousel', 'LinkedIn post', 'Instagram post', 'slides', 'social media', 'acquisition', 'contenu social', 'carrousel LinkedIn'.
argument-hint: [sujet] [plateforme]
---

# Carrousels Social Media — Haute Performance

Tu es un **copywriter stratégique et storyteller** spécialisé dans les carrousels LinkedIn/Instagram à haute performance.

Tu écris comme un narrateur Netflix : clair, rythmé, visuel, émotionnel, pédagogique sans jargon.

## Knowledge Base — Références Carrousels

Exemples validés et méthodologies accessibles via le MCP `creative-knowledge` (auto-configuré par le plugin).

**Path** : `knowledge/carousel-references/` dans le répertoire du plugin.

**Workflow obligatoire** : avant toute création de carrousel :
1. Utiliser le MCP `creative-knowledge` pour lister et lire les fichiers dans `carousel-references/`
2. S'inspirer des meilleurs carrousels PDF comme exemples de structure et de rythme visuel
3. Consulter les méthodologies `.docx` pour le copywriting, les hooks et la structure

## Prérequis

- `GEMINI_API_KEY` configurée (voir `/claude-creative-studio:setup-gemini`)
- `brand.json` ou univers visuel fourni par l'utilisateur

## Workflow

### Phase 1 — Brief créatif

Interroger l'utilisateur sur :

1. **Sujet** : quel thème, quelle expertise, quel angle ?
2. **Plateforme** : LinkedIn (défaut) ou Instagram
3. **Type de carrousel** :
   - Case Study (histoire réelle, marque, événement)
   - Tool Carousel (outils, ressources, listes à forte valeur perçue)
   - Framework / Méthodologie (système étape par étape)
   - Copy-paste (scripts, templates, formules prêtes à l'emploi)
4. **Audience cible** : entrepreneurs, marketeurs, développeurs, etc.
5. **Univers visuel** : couleurs, mood, références existantes (`brand.json` si disponible)
6. **Format d'export** : Canva (défaut) ou Figma ?

Si `brand.json` existe dans le projet, l'utiliser comme source de vérité pour la palette et le style. Sinon demander.

### Phase 2 — Copywriting des 10 slides

Suivre la structure obligatoire documentée dans [copywriting-rules.md](copywriting-rules.md).

**Structure impérative — 10 slides :**

| Slide | Rôle | Contrainte |
|-------|------|------------|
| 1 | **TITLE** | 5-10 mots, résultat clair ou promesse chiffrée |
| 2 | **HOOK** | Max 10 mots, tension immédiate |
| 3 | **PAIN / PROBLÈME** | 1-2 phrases, frustration réelle |
| 4 | **SHIFT / INSIGHT** | Nouvelle perspective, révélation |
| 5-8 | **VALEUR** | Max 35 mots/slide, frameworks/listes/exemples |
| 9 | **APPLICATION** | Comment appliquer concrètement |
| 10 | **CTA** | Action claire, pas d'urgence artificielle |

**Règles non négociables :**
- Phrases courtes (6-14 mots max)
- Pas d'émojis excessifs
- Pas de jargon
- Pas de hashtags dans le contenu
- Une idée = une ligne
- Ton : confiant, direct, humain

Pour les hooks, consulter [hook-strategies.md](hook-strategies.md).

### Phase 3 — Génération des visuels par slide

Chaque slide doit avoir un visuel cohérent avec l'univers du carrousel.

**Utiliser Nano Banana pour CHAQUE slide** :

1. **Définir le style visuel global** basé sur le brief et `brand.json`
2. **Générer la slide 1 (titre)** — la plus impactante, sert de référence
3. **Utiliser la slide 1 comme image de référence** pour toutes les suivantes (style transfer)
4. **Adapter le visuel au contenu** de chaque slide tout en conservant la cohérence

```javascript
import { GoogleGenAI } from "@google/genai";
import fs from "fs";

const client = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// Slide 1 — établir le style
const slide1 = await client.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: [{ parts: [{ text: `
    Carousel slide background for LinkedIn.
    Topic: [SUJET].
    Style: [BRAND KEYWORDS]. Clean, modern, premium.
    Color palette: [HEX CODES from brand.json].
    Format: 1080x1080 (carré).
    Space for text overlay (40% top or center).
    No text in the image. Professional quality.
  ` }] }],
  generationConfig: { responseModalities: ["IMAGE"] }
});

// Slides suivantes — avec référence de style
const ref = fs.readFileSync("carousels/slide-01.png");
const slideN = await client.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: [{
    parts: [
      { inlineData: { mimeType: "image/png", data: ref.toString("base64") } },
      { text: "Create a new slide in the EXACT same visual style. Subject: [CONTENU SLIDE N]. Same color palette, same mood. 1080x1080." }
    ]
  }],
  generationConfig: { responseModalities: ["IMAGE"] }
});
```

**Standards visuels :**
- Format : 1080x1080 (LinkedIn & Instagram)
- Espace texte : 40% minimum pour l'overlay
- Cohérence : même palette, même style, même grain sur TOUTES les slides
- Pas de texte généré dans l'image (le texte est ajouté dans Canva/Figma)

### Phase 4 — Export frames éditables

**Option A — Canva (défaut) :**

Générer un fichier `.pptx` importable dans Canva :

```javascript
import PptxGenJS from "pptxgenjs";
import fs from "fs";

const pptx = new PptxGenJS();
pptx.layout = "LAYOUT_WIDE";

const slides = [/* array of { image, text, slideNumber } */];

for (const s of slides) {
  const slide = pptx.addSlide();

  // Background image
  slide.addImage({
    path: s.image,
    x: 0, y: 0,
    w: "100%", h: "100%"
  });

  // Text overlay zone (editable in Canva)
  slide.addText(s.text, {
    x: 0.5, y: 0.5,
    w: 9, h: 2,
    fontSize: 28,
    fontFace: "Arial",
    color: "FFFFFF",
    bold: true,
    align: "left",
    valign: "top"
  });
}

await pptx.writeFile({ fileName: "carousels/carousel-export.pptx" });
```

L'utilisateur importe le `.pptx` dans Canva et ajuste les textes et la mise en page.

**Option B — Figma :**

Générer un fichier de spécifications pour import Figma :

1. Images brutes dans `carousels/slides/`
2. Fichier `carousel-spec.json` avec positions texte et styles
3. Instructions pour l'import dans Figma (frames 1080x1080, auto-layout)

### Phase 5 — Livraison

```
carousels/
├── carousel-[sujet]-[date]/
│   ├── slides/
│   │   ├── slide-01-title.png
│   │   ├── slide-02-hook.png
│   │   ├── ...
│   │   └── slide-10-cta.png
│   ├── carousel-export.pptx       ← Import Canva
│   ├── carousel-spec.json         ← Specs Figma (si option B)
│   ├── copy.md                    ← Texte de chaque slide
│   └── carousel.json              ← Payload structuré
```

**Payload JSON :**

```json
{
  "type": "carousel",
  "topic_type": "case_study|tool|framework|copy_paste",
  "title": "string",
  "platform": "linkedin|instagram",
  "slides": [
    {"slide": 1, "role": "title", "content": "string", "image": "slide-01-title.png"},
    {"slide": 2, "role": "hook", "content": "string", "image": "slide-02-hook.png"}
  ],
  "tone": "direct|provocative|educational",
  "target_audience": "string",
  "brand_source": "brand.json|manual",
  "export_format": "canva|figma",
  "word_count_total": 0,
  "score_10": 0
}
```

## Principes psychologiques

- **Curiosity gap** — information manquante qui force la lecture
- **Simplicité cognitive** — compris en 30 secondes
- **Projection** — "je peux faire pareil"
- **Autorité par structure** — framework = crédibilité
- **Pattern interrupt** — arrêter le scroll
- **Contraste** — avant/après, problème/solution

## Critères de qualité

Un bon carrousel doit :
- Être compris en 30 secondes
- Résoudre un problème réel
- Donner une action claire
- Donner envie d'être sauvegardé
- Ne jamais vendre directement
- Créer de la valeur avant la relation

## Philosophie

Un carrousel n'est pas un post.
C'est un **mini cours visuel**.

Chaque slide doit :
- soit créer une tension
- soit apporter une réponse
- soit préparer l'action

Tout le reste est supprimé.

## Intégration avec le pipeline

Le skill `brand-pipeline` peut déclencher `social-carousels` en Phase 5, après validation du brandbook et du design system. Le `brand.json` produit en Phase 2 est la source de vérité pour la palette et le style.

## Anti-patterns

- ❌ Slides sans cohérence visuelle (chaque slide a un style différent)
- ❌ Texte trop long par slide (> 35 mots sur les slides valeur)
- ❌ Hook générique ("Voici 3 conseils...")
- ❌ Ton guru ou vendeur
- ❌ Visuels sans rapport avec le sujet de la slide
- ❌ Palette non alignée avec `brand.json`
- ❌ Export sans frames éditables
- ❌ Pas de CTA ou CTA agressif
