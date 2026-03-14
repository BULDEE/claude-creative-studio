# ADR-003: Gemini (Nano Banana) comme backend de génération d'images

**Date** : 2026-03-14
**Statut** : accepted

## Contexte

Plusieurs API de génération d'images sont disponibles : DALL-E (OpenAI), Midjourney (via proxy), Stable Diffusion (Stability AI, Replicate), Flux (fal.ai), et Gemini Image / Nano Banana (Google). Le choix impacte le coût, la qualité, la facilité d'intégration et l'accessibilité pour des non-techniques.

## Décision

Utiliser l'API Gemini (Nano Banana 2 / Nano Banana Pro) comme backend principal de génération d'images.

## Justification

| Critère | Gemini | DALL-E 3 | Midjourney | Stable Diffusion |
|---------|--------|----------|------------|------------------|
| Free tier | ~500/jour | 0 | 0 | Limité |
| Coût payant | ~$0.04/img | $0.04-0.08 | $10-60/mois | Variable |
| API directe | ✅ REST | ✅ REST | ❌ Discord/proxy | ✅ REST |
| Qualité logo | Bonne | Bonne | Excellente | Variable |
| Texte dans image | Excellent (Pro) | Moyen | Bon | Faible |
| Style transfer | ✅ Multi-ref | ❌ | ❌ | ✅ |
| Setup | 1 clé API | 1 clé API | Complexe | Complexe |

**Arguments décisifs :**
- **500 images/jour gratuites** — élimine la barrière financière pour les non-techniques
- **API REST simple** — un seul endpoint, pas de webhook ni de polling
- **Style transfer natif** — envoyer une image de référence + prompt textuel
- **Texte dans les images** — Nano Banana Pro rend du texte lisible (utile pour les logos)
- **Pas de vendor lock-in** — le skill génère un script Node.js standard, remplaçable

**Risques acceptés :**
- Dépendance à Google (mitigé : le script est un template, pas une abstraction opaque)
- Qualité inférieure à Midjourney sur le style artistique (acceptable pour du prototypage de logos)
- Free tier peut évoluer (mitigé : 500/jour est largement suffisant, payant reste compétitif)

## Conséquences

- La clé `GEMINI_API_KEY` est le seul prérequis pour la génération d'images
- La génération est optionnelle — les skills fonctionnent sans (mode description textuelle)
- Le script de génération est inline dans le SKILL.md, pas une dépendance npm
- Si un meilleur backend émerge, seul le template de script dans les skills est à modifier (SRP)
