# ADR-006: Un Skill par Bounded Context métier

**Date** : 2026-03-14
**Statut** : accepted

## Contexte

Le plugin couvre trois activités créatives distinctes : la création de logos, la génération de visuels brandés, et la documentation d'applications. La question est de structurer ces capacités en un seul mega-skill ou en skills séparés.

## Décision

Chaque **Bounded Context** métier est encapsulé dans un **Skill dédié** avec sa propre responsabilité, son propre SKILL.md, et ses propres règles de déclenchement.

### Mapping DDD → Skills

```
Bounded Context: Logo Design
  Skill: design-logo
  Aggregate Root: Brief client (nom, secteur, valeurs)
  Value Objects: Piste créative, Palette, Déclinaison
  Domain Service: Génération Nano Banana (optionnel)
  Repository: knowledge/logo-references/ (via MCP)

Bounded Context: Brand Visual Production
  Skill: brand-visuals
  Aggregate Root: Asset brief (type, sujet, dimensions)
  Value Objects: Brand tokens (couleurs, style, mood)
  Domain Service: Détection DA (cascade), Génération Nano Banana
  Repository: Contexte projet (tailwind, CSS, brand.json)

Bounded Context: User Documentation
  Skill: app-guide-generator
  Aggregate Root: Guide (audience, périmètre, pages)
  Value Objects: Screenshot, Étape documentée
  Domain Service: Navigation Playwright, Capture
  Repository: docs/guide/ (output filesystem)
```

## Justification

**Principes appliqués :**

- **Single Responsibility Principle (SRP)** : chaque skill a une seule raison de changer. Si la méthode de génération d'images évolue, seul `brand-visuals` et `design-logo` sont impactés. Si Playwright change, seul `app-guide-generator` est touché.

- **Interface Segregation Principle (ISP)** : un utilisateur qui ne fait que des logos n'est pas forcé de comprendre la détection de DA ou Playwright. Chaque skill expose exactement ce qui est nécessaire à son contexte.

- **Bounded Context (DDD)** : les trois domaines ont un langage ubiquitaire différent :
  - Logo : "piste créative", "déclinaison", "zone de protection"
  - Visuels : "asset", "palette détectée", "itération"
  - Guides : "screenshot", "étape", "flow interactif"
  
  Mélanger ces langages dans un seul skill créerait de la confusion dans les instructions.

- **Loose Coupling** : les skills communiquent via des conventions partagées (le `brand.json`), pas via des appels directs. Le logo produit un `brand.json` → le visual le consomme. C'est un **Domain Event** implicite.

- **Dependency Inversion Principle (DIP)** : les skills dépendent d'abstractions (le format `brand.json`, l'API Gemini standard), pas de détails d'implémentation. Changer le backend d'image ne casse pas la structure.

**Pourquoi pas un seul skill "creative-studio" :**
- SKILL.md trop long → Claude Code aurait du mal à le charger efficacement
- Déclenchement ambigu → un prompt "crée un visuel" activerait inutilement la logique logo
- Violation du SRP → une modification de la logique screenshot impacterait le flow de logo
- Testabilité réduite → impossible de valider un skill indépendamment

## Conséquences

- Chaque skill est autonome et testable isolément
- L'intégration entre skills passe par des conventions (fichiers `brand.json`, dossier `knowledge/`)
- L'ajout d'un nouveau Bounded Context (ex: "social media templates") = un nouveau skill, pas une modification des existants (OCP)
- Le couplage inter-skills est documenté dans ARCHITECTURE.md
