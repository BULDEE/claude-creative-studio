# ADR-002: Knowledge base via MCP Filesystem

**Date** : 2026-03-14
**Statut** : accepted

## Contexte

Les skills de design ont besoin d'accéder à des fichiers de référence (PDFs de chartes graphiques, images de logos existants, moodboards). Plusieurs approches sont possibles : embedding dans le prompt, upload manuel à chaque session, base vectorielle (RAG), ou accès filesystem via MCP.

## Décision

Utiliser le MCP `@modelcontextprotocol/server-filesystem` pointé sur le dossier `knowledge/` du plugin via le `.mcp.json`.

## Justification

**Pourquoi MCP Filesystem :**
- **Zéro infrastructure** : pas de serveur vectoriel, pas de base de données, pas d'API tierce
- **Accès natif** : Claude Code lit les fichiers comme s'ils étaient dans le contexte
- **Mise à jour triviale** : l'utilisateur dépose un fichier dans le dossier, c'est immédiatement disponible
- **Multi-format** : PDF, PNG, SVG, JSON — le MCP filesystem gère tout

**Pourquoi pas RAG / base vectorielle :**
- YAGNI — le volume de références est faible (dizaine de fichiers max)
- La recherche sémantique n'apporte rien ici : Claude lit chaque référence séquentiellement
- Ajoute une dépendance infrastructure lourde (embedding model, vector store)
- Complexifie l'installation pour un non-technique

**Pourquoi pas embedding dans le prompt :**
- Les PDFs et images ne peuvent pas être embarqués en texte dans un SKILL.md
- La taille du context window serait gaspillée en permanence
- Pas de mise à jour possible sans modifier le skill

## Conséquences

- Le dossier `knowledge/` est la source de vérité pour les références
- Les fichiers de référence sont ignorés par git (`.gitignore`) — chaque utilisateur a ses propres références
- Les `.gitkeep` maintiennent la structure de dossiers vide dans le repo
- Si le volume de références dépasse ~50 fichiers, reconsidérer un index ou un RAG léger (→ ADR future)
