---
name: app-guide-generator
description: Génère des guides utilisateurs complets avec screenshots automatiques via Playwright MCP. Déclenché par 'guide', 'documentation', 'tutoriel', 'walkthrough', 'onboarding', 'help doc', 'manuel utilisateur', 'screenshot guide'.
---

# Guides Utilisateurs avec Screenshots Automatiques

Automatise la création de guides professionnels en naviguant dans une application web via Playwright MCP.

## Prérequis

- **Playwright MCP** installé au niveau user :
  ```bash
  claude mcp add --scope user playwright npx @playwright/mcp@latest
  ```
- Application cible accessible (localhost ou URL publique)

> **Note** : Le MCP Playwright est volontairement hors du plugin car il sert à de nombreux autres usages (tests, QA, scraping). Il est recommandé de l'installer en scope user une seule fois.

## Workflow

### Phase 1 — Cadrage du guide

Avant de toucher le navigateur, définir :
- **Audience** : nouvel utilisateur, admin, développeur, client final
- **Périmètre** : walkthrough complet OU feature/flow spécifique
- **Pages/flows** : lister chaque écran et action utilisateur
- **Format** : Markdown (défaut) ou PDF

Si non spécifié, demander à l'utilisateur. Proposer une table des matières avant de commencer.

### Phase 2 — Authentification (si nécessaire)

Si l'application requiert un login :
1. `browser_navigate` vers la page de login
2. Informer l'utilisateur : "J'ai ouvert la page de connexion. Connectez-vous manuellement, puis dites-moi de continuer."
3. Attendre la confirmation avant de poursuivre

**NE JAMAIS saisir de mots de passe ou identifiants.**

### Phase 3 — Capture systématique

Pour chaque page/écran du guide :
1. **Naviguer** via `browser_navigate`
2. **Attendre** le chargement complet (pas de spinners/skeletons visibles)
3. **Capturer** le screenshot complet via `browser_take_screenshot`
4. **Éléments spécifiques** si besoin (formulaires, modales, boutons)
5. **Responsive** si demandé — `browser_resize` :
   - Mobile : 375x667
   - Tablet : 768x1024
   - Desktop : 1440x900

Convention de nommage :
```
docs/guide/screenshots/
  01-dashboard-overview.png
  02-campaigns-list.png
  03-campaign-create-form.png
  04-campaign-create-form-mobile.png
```

### Phase 4 — Capture des flows interactifs

Pour les processus multi-étapes :
- Screenshot **avant et après** chaque action utilisateur
- Décrire quel bouton/champ l'utilisateur doit utiliser
- Capturer les **états de succès et d'erreur**
- Capturer les **états vides** (avant données)

### Phase 5 — Assemblage du guide

```markdown
# [Nom App] — Guide utilisateur

> Version : [date] | Audience : [cible]

## Table des matières
- [Section 1](#section-1)
...

## 1. [Nom Section]

### Objectif
[Ce que l'utilisateur accomplit — 1-2 phrases]

### Étapes

**1. [Description action]**

![Description](./screenshots/01-nom.png)

[Explication concise de ce que l'utilisateur voit et fait.]

**2. [Action suivante]**

![Description](./screenshots/02-nom.png)

### Points d'attention
- [Pièges, astuces, avertissements]
```

### Phase 6 — Livraison

- `docs/guide/screenshots/` pour les images
- `docs/guide/README.md` pour le guide

## Standards de qualité

- **Langue** : français par défaut sauf demande contraire
- **Texte** : impératif et concis ("Cliquez sur..." pas "L'utilisateur peut cliquer...")
- **Structure** : 1 action = 1 étape = 1 screenshot
- **Viewport** : cohérent sur tous les screenshots sauf comparaison responsive
- **Nommage** : descriptif, numéroté, zéro ambiguïté

## Anti-patterns

- ❌ Screenshots avant chargement complet (spinners visibles)
- ❌ Données sensibles capturées (clés API, emails réels, mots de passe)
- ❌ Screenshots avec erreurs console visibles
- ❌ Guide sans table des matières
- ❌ Screenshots sans contexte textuel
- ❌ Assumer que l'utilisateur connaît l'app — écrire pour un débutant
