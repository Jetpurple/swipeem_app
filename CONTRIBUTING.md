# Guide de Contribution

Ce document définit le workflow de contribution au projet Swipeem.

---

## Workflow Git

### Branches

- **`main`** : Branche de production (protégée)
- **`develop`** : Branche de développement (protégée)
- **`feature/xxx`** : Nouvelle feature
- **`fix/xxx`** : Correction de bug
- **`refactor/xxx`** : Refactoring
- **`docs/xxx`** : Documentation

### Convention de Commits

Format : `type: description`

**Types** :
- `feat:` : Nouvelle feature
- `fix:` : Correction de bug
- `docs:` : Documentation
- `refactor:` : Refactoring
- `test:` : Tests
- `chore:` : Maintenance (dépendances, config, etc.)
- `perf:` : Amélioration de performance
- `style:` : Formatage, pas de changement de code

**Exemples** :
```
feat: add pagination to posts list
fix: resolve memory leak in message provider
docs: update README with new architecture
refactor: extract matching logic to Cloud Function
test: add unit tests for auth service
```

### Processus de Pull Request

1. **Créer une branche** depuis `develop`
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/my-feature
   ```

2. **Développer la feature**
   - Suivre les conventions de code
   - Écrire des tests si applicable
   - Documenter le code complexe

3. **Vérifier avant de push**
   ```bash
   flutter analyze
   dart format .
   flutter test
   ```

4. **Push et créer la PR**
   ```bash
   git push origin feature/my-feature
   ```
   - Créer la PR sur GitHub vers `develop`
   - Remplir le template de PR

5. **Code Review**
   - Attendre l'approbation d'au moins 1 reviewer
   - Corriger les commentaires si nécessaire

6. **Merge**
   - Le reviewer merge la PR
   - La branche est supprimée automatiquement

---

## Definition of Done

Avant de créer une Pull Request, vérifier :

### Code Quality
- [ ] **Linter** : `flutter analyze` sans erreurs
- [ ] **Format** : `dart format .` appliqué
- [ ] **Tests** : Tests passent (si applicable)
- [ ] **Documentation** : Code commenté si complexe

### Sécurité
- [ ] **Pas de secrets** : Aucune clé API, token, credential dans le code
- [ ] **Firestore Rules** : Vérifiées et testées
- [ ] **Validation serveur** : Logique sensible dans Cloud Functions

### Performance
- [ ] **Pagination** : Listes de plus de 20 éléments paginées
- [ ] **Indexes** : Requêtes Firestore indexées
- [ ] **Images** : Compression et optimisation

### RGPD & Conformité
- [ ] **Consentements** : Gérés si nouvelle feature
- [ ] **Données privées** : Séparation public/privé respectée
- [ ] **Champs exclus** : Pas de champs discriminants dans matching

### Tests
- [ ] **Tests unitaires** : Pour les services critiques
- [ ] **Tests d'intégration** : Pour les features critiques (auth, match, messages)
- [ ] **Tests manuels** : Feature testée sur émulateur/production

---

## Template de Pull Request

```markdown
## Description
Brève description de la feature/fix.

## Type de changement
- [ ] Feature
- [ ] Fix
- [ ] Refactor
- [ ] Documentation
- [ ] Test

## Checklist
- [ ] Code conforme aux standards
- [ ] Tests ajoutés/mis à jour
- [ ] Documentation mise à jour
- [ ] Pas de secrets dans le code
- [ ] Firestore Rules vérifiées
- [ ] Performance vérifiée

## Screenshots (si applicable)
...

## Issues liées
Closes #XXX
```

---

## Code Review Guidelines

### Pour le Reviewer

- ✅ Vérifier la conformité aux standards
- ✅ Vérifier la sécurité (pas de secrets, validation serveur)
- ✅ Vérifier les tests
- ✅ Vérifier la performance
- ✅ Vérifier la documentation

### Pour le Développeur

- ✅ Répondre aux commentaires
- ✅ Corriger les problèmes identifiés
- ✅ Pousser les corrections dans la même branche

---

## Conventions de Code

### Nommage
- **Variables** : `camelCase`
- **Classes** : `PascalCase`
- **Fichiers** : `snake_case.dart`
- **Constantes** : `UPPER_SNAKE_CASE`

### Structure
- **Features** : Feature-first dans `lib/features/`
- **Services** : Dans `lib/services/`
- **Providers** : Dans `lib/providers/`
- **Models** : Dans `lib/models/`

### Documentation
- **Commentaires** : Expliquer le "pourquoi", pas le "comment"
- **Docstrings** : Pour les fonctions publiques complexes

---

## Questions ?

Pour toute question, ouvrir une issue sur GitHub ou contacter l'équipe de développement.

