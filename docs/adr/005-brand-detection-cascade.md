# ADR-005: Détection de DA par cascade contextuelle

**Date** : 2026-03-14
**Statut** : accepted

## Contexte

Le skill `brand-visuals` génère des visuels qui doivent être cohérents avec l'identité visuelle du projet en cours. Le problème : comment obtenir la palette de couleurs et le style sans demander à l'utilisateur de configurer manuellement un fichier à chaque fois ?

## Décision

Implémenter un **pattern de cascade** (Chain of Responsibility) qui résout la DA dans un ordre de priorité décroissant, en s'arrêtant à la première source trouvée.

### Ordre de résolution

```
1. brand.json / brand.yaml    ← Source explicite (plus haute priorité)
2. tailwind.config.*           ← Extraction des couleurs custom
3. CSS custom properties       ← Variables --color-* dans les CSS racine
4. .claude/CLAUDE.md           ← Mentions de palette dans le contexte projet
5. package.json                ← Nom et description pour le contexte
6. Demander à l'utilisateur    ← Fallback ultime
```

## Justification

**Principes appliqués :**

- **Open/Closed Principle (OCP)** : la cascade est extensible — ajouter une nouvelle source (ex: Figma tokens) ne nécessite pas de modifier les sources existantes, juste d'insérer un nouveau niveau dans la chaîne.

- **Convention over Configuration** : dans 90% des projets web modernes, la palette est dans Tailwind ou des CSS variables. Le skill la trouve sans que l'utilisateur n'ait rien à configurer.

- **Explicit is better than implicit** : malgré l'auto-détection, le skill **affiche toujours** la palette détectée et **demande validation** avant de générer. L'utilisateur garde le contrôle.

- **Fail gracefully** : si aucune source n'est trouvée, on ne fail pas — on demande à l'utilisateur. Pas d'erreur, pas de blocage.

**Pourquoi pas une config obligatoire (`brand.json` requis) :**
- Friction d'onboarding trop élevée pour un non-technique
- La plupart des projets ont déjà leurs couleurs dans Tailwind
- Forcer un fichier supplémentaire viole le principe de moindre surprise

**Pourquoi pas un seul point d'entrée (ex: Tailwind uniquement) :**
- Tous les projets n'utilisent pas Tailwind
- Certains projets ont un `brand.json` plus riche (style, mood, keywords)
- La cascade couvre le maximum de cas sans assomption

## Conséquences

- Le skill doit documenter clairement l'ordre de résolution
- Le `brand.json` est le format recommandé dans la doc pour les utilisateurs qui veulent un contrôle total
- La validation utilisateur avant génération est obligatoire (pas d'auto-génération silencieuse)
- Les sources sont lues de manière paresseuse (on s'arrête à la première trouvée)
