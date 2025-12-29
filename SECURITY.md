# Politique de Sécurité

Ce document définit les règles de sécurité du projet Swipeem.

---

## Gestion des Secrets

### ⚠️ Ce qui ne doit JAMAIS être dans le code

- ❌ **Clés API** : Stripe, OpenAI, etc.
- ❌ **Tokens OAuth** : Client ID, Client Secret
- ❌ **Service Account JSON** : Fichiers de credentials Firebase Admin
- ❌ **Mots de passe** : Hash uniquement
- ❌ **Données sensibles** : Numéros de carte, adresses complètes

### ✅ Utiliser des Variables d'Environnement

#### Flutter
```dart
// ✅ BON
const String apiKey = String.fromEnvironment('API_KEY');

// Lancer avec :
flutter run --dart-define=API_KEY=your_key_here
```

#### Cloud Functions
```typescript
// ✅ BON
const apiKey = process.env.API_KEY;

// Configurer avec :
firebase functions:config:set api.key="your_key_here"
```

### Fichiers Ignorés (`.gitignore`)

Les fichiers suivants sont automatiquement ignorés :

```
**/credentials.json
**/service-account.json
**/*_key.json
.env
.env.local
.env.*.local
firebase_options.dart
```

### Configuration des Secrets

#### Développement Local

1. Créer un fichier `.env.local` (non commité)
2. Ajouter les secrets nécessaires
3. Utiliser `--dart-define-from-file=.env.local` (Flutter 3.0+)

#### Production

1. Utiliser Firebase Functions Config :
   ```bash
   firebase functions:config:set api.key="value"
   ```

2. Ou utiliser Secret Manager (recommandé) :
   ```bash
   firebase functions:secrets:set API_KEY
   ```

---

## Sécurité Firestore

### Règles de Sécurité

#### ⚠️ État Actuel

Les règles Firestore sont actuellement en **mode développement** :
```javascript
match /{document=**} {
  allow read, write: if true;
}
```

**⚠️ À CORRIGER EN PRODUCTION** : Implémenter des règles strictes.

#### Règles Recommandées (à implémenter)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      // Admin peut modifier tous les users
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Matches
    match /matches/{matchId} {
      allow read: if request.auth != null && 
        (resource.data.candidateUid == request.auth.uid || 
         resource.data.recruiterUid == request.auth.uid);
      allow create: if false; // Uniquement via Cloud Function
      allow update: if request.auth != null && 
        (resource.data.candidateUid == request.auth.uid || 
         resource.data.recruiterUid == request.auth.uid);
    }
    
    // Messages
    match /messages/{messageId} {
      allow read: if request.auth != null && 
        (resource.data.senderUid == request.auth.uid || 
         resource.data.receiverUid == request.auth.uid);
      allow create: if request.auth != null && 
        request.resource.data.senderUid == request.auth.uid;
      allow update: if request.auth != null && 
        (resource.data.senderUid == request.auth.uid || 
         resource.data.receiverUid == request.auth.uid);
    }
    
    // Posts
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.authorUid == request.auth.uid;
    }
  }
}
```

### Indexes Requis

Toutes les requêtes avec `where()` + `orderBy()` doivent avoir un index dans `firestore.indexes.json`.

Vérifier avant de déployer :
```bash
firebase deploy --only firestore:indexes
```

---

## Sécurité Storage

### Règles de Sécurité

Les règles Storage sont déjà configurées (voir `storage.rules`) :

- ✅ Authentification requise
- ✅ Validation des types (images, PDF uniquement)
- ✅ Limitation de taille (5 MB photos, 10 MB CV)
- ✅ Vérification propriétaire

### Conventions de Chemins

```
users/{userId}/profile.jpg    # Photo de profil
users/{userId}/cv.pdf          # CV
```

**⚠️ Important** : Ne jamais stocker de données structurées dans Storage. Utiliser Firestore.

---

## Sécurité Auth

### Rôles Utilisateurs

#### ⚠️ Sécurité Critique

- ❌ **Jamais modifier `isAdmin` depuis Flutter**
- ✅ Vérifier les rôles dans Firestore Rules
- ✅ Vérifier les rôles dans Cloud Functions

#### Gestion des Rôles

- **Candidat** : `isRecruiter: false, isAdmin: false`
- **Recruteur** : `isRecruiter: true, isAdmin: false` (défini lors de l'inscription)
- **Admin** : `isAdmin: true` (défini **uniquement** côté serveur ou Firebase Console)

### Création Automatique Users

Lors de la première connexion, créer automatiquement `users/{uid}` via Cloud Function `onUserCreate` (à implémenter si absent).

---

## Sécurité Cloud Functions

### Validation des Inputs

Toujours valider les inputs dans les Cloud Functions :

```typescript
export const myFunction = functions.https.onCall(async (data, context) => {
  // Vérifier authentification
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  // Valider les inputs
  const { userId, message } = data;
  if (!userId || !message) {
    throw new functions.https.HttpsError('invalid-argument', 'userId and message required');
  }
  
  // Vérifier les permissions
  if (userId !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'Cannot modify other user');
  }
  
  // Logique métier
  // ...
});
```

### Gestion des Erreurs

Retourner des erreurs HTTP standardisées :

```typescript
throw new functions.https.HttpsError(
  'permission-denied',
  'User does not have permission to perform this action'
);
```

---

## RGPD & Données Personnelles

### Minimisation des Données

- ✅ Collecter uniquement ce qui est nécessaire
- ✅ Ne pas stocker de données sensibles inutiles
- ✅ Anonymiser les données d'analytics
- ✅ Supprimer les données obsolètes

### Séparation Public / Privé

Voir section [Sécurité & RGPD](./README.md#sécurité--rgpd) du README.

### Consentements

Chaque utilisateur doit avoir un champ `consents` avec :
- `analytics`
- `aiSuggestions`
- `personalityTest`
- `marketing`
- `dataSharing`

### Droit à l'Oubli (Roadmap)

- ⏳ Implémenter Cloud Function `deleteUserData(userId)`
- ⏳ Suppression complète : Firestore, Storage, Auth
- ⏳ Délai de grâce : 30 jours

### Export des Données (Roadmap)

- ⏳ Implémenter Cloud Function `exportUserData(userId)`
- ⏳ Format JSON avec toutes les données utilisateur

---

## Reporting de Vulnérabilités

Si vous découvrez une vulnérabilité de sécurité :

1. **Ne pas ouvrir d'issue publique**
2. **Contacter l'équipe** : [email de sécurité]
3. **Décrire la vulnérabilité** : Impact, reproduction, fix proposé
4. **Attendre la réponse** : L'équipe traitera la vulnérabilité rapidement

---

## Checklist de Sécurité

Avant chaque déploiement en production :

- [ ] **Secrets** : Aucun secret dans le code
- [ ] **Firestore Rules** : Règles strictes implémentées
- [ ] **Storage Rules** : Règles vérifiées
- [ ] **Auth** : Rôles sécurisés (isAdmin côté serveur uniquement)
- [ ] **Cloud Functions** : Validation des inputs
- [ ] **RGPD** : Consentements gérés
- [ ] **Données privées** : Séparation public/privé respectée
- [ ] **Indexes** : Toutes les requêtes indexées

---

**Dernière mise à jour** : 2024

