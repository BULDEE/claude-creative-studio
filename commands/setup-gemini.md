Guide l'utilisateur pour configurer sa clé API Gemini (gratuite) afin de générer des images avec Nano Banana.

## Vérification

Vérifie d'abord si `GEMINI_API_KEY` est déjà configurée :
- Tester `echo $GEMINI_API_KEY` via bash
- Si la variable existe et n'est pas vide → informer l'utilisateur qu'il est prêt et arrêter

## Configuration

Si la clé n'est pas configurée :

1. **Expliquer** : "Pour générer des images (logos, visuels), il faut une clé API Gemini. C'est gratuit : 500 images par jour."

2. **Guider** vers https://aistudio.google.com/apikey
   - Cliquer "Create API Key"
   - Copier la clé

3. **Demander** à l'utilisateur de coller sa clé

4. **Ajouter** la clé dans le shell profile :
   - Détecter le shell : `.zshrc` (macOS par défaut) ou `.bashrc`
   - Vérifier que `GEMINI_API_KEY` n'est pas déjà dans le fichier
   - Ajouter : `export GEMINI_API_KEY="la-clé"`
   - Informer : "Exécutez `source ~/.zshrc` ou ouvrez un nouveau terminal"

5. **Tester** : exécuter un appel minimal pour vérifier que la clé fonctionne

## Important

- Ne JAMAIS afficher la clé en clair dans les logs
- Ne JAMAIS committer la clé dans un dépôt git
- Si l'utilisateur est dans un contexte CI/CD, suggérer de passer par les secrets GitHub/GitLab
