# Hire Me — MVP (Flutter + Firebase)

## 🚀 Application de matching emploi avec interface Tinder-like

Application Flutter permettant aux candidats de swiper des offres d'emploi et aux entreprises de swiper des candidats, avec système de messagerie en temps réel.

## 👥 Utilisateurs de test

### Candidat
- **Email:** `candidat@example.com`
- **Mot de passe:** `password123`
- **Profil:** Développeuse Flutter avec 3 ans d'expérience
- **Fonctionnalités:** Swiper des offres, envoyer des messages, recevoir des notifications

### Entreprise
- **Email:** `contact@techcorp.com`
- **Mot de passe:** `password123`
- **Profil:** TechCorp - Entreprise tech spécialisée en développement mobile
- **Fonctionnalités:** Poster des offres, swiper des candidats, recevoir des notifications

## 🔧 Configuration

### Prérequis
- Flutter SDK (vendored at `/Users/ludo/flutter_sdk` for local use)
- Xcode (pour iOS), Android Studio ou outils en ligne de commande (pour Android)
- Homebrew installé

### Démarrage rapide

```bash
# Utiliser Flutter vendored pour ce shell
export PATH="/Users/ludo/flutter_sdk/bin:$PATH"
flutter pub get
flutter run -d chrome
```

## 📱 Fonctionnalités

### Pour les candidats
- ✅ Swipe des offres d'emploi (interface Tinder-like)
- ✅ Messagerie en temps réel avec les entreprises
- ✅ Notifications pour nouveaux messages
- ✅ Modification du profil
- ✅ Basculement entre utilisateurs pour les tests

### Pour les entreprises
- ✅ Swipe des profils candidats
- ✅ Publication d'offres d'emploi
- ✅ Messagerie en temps réel avec les candidats
- ✅ Notifications pour nouveaux messages
- ✅ Modification du profil

## 🛠 Technologies utilisées

### Dépendances principales
- **flutter_riverpod, riverpod** - Gestion d'état
- **go_router** - Navigation
- **firebase_core, firebase_auth, cloud_firestore** - Backend Firebase
- **firebase_messaging** - Notifications push
- **flutter_local_notifications** - Notifications locales
- **flutter_form_builder** - Formulaires
- **intl** - Internationalisation
- **shared_preferences** - Stockage local

### Architecture
- **Firebase Firestore** - Base de données NoSQL
- **Firebase Authentication** - Authentification
- **Riverpod** - Gestion d'état réactive
- **GoRouter** - Navigation déclarative
- **Material Design 3** - Interface utilisateur

## 🗄 Structure des données

### Collections Firestore
- **users** - Profils utilisateurs (candidats et entreprises)
- **job_offers** - Offres d'emploi publiées
- **matches** - Correspondances entre candidats et entreprises
- **messages** - Messages échangés dans les conversations
- **swipes** - Historique des swipes (likes/dislikes)

## 🔐 Étapes Firebase (tests locaux)

1) Créer le projet et l'app web
- Ouvrir Firebase Console → Créer un projet (ex: hire-me-28191)
- Section « Vos applications » → Web (« </> ») → Enregistrer l'app
- Copier la config et/ou exécuter: `dart pub global activate flutterfire_cli` puis `flutterfire configure`

2) Activer les produits
- Authentication → Méthodes de connexion → activer Email/Password et (optionnel) Google
- Firestore Database → Créer une base en mode test (ou règles dev ci-dessous)
- Storage → Créer le bucket par défaut

3) Règles de développement (à restreindre pour la prod)
```javascript
// Firestore (dev uniquement)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null; // autoriser uniquement les utilisateurs connectés
    }
  }
}
```

```javascript
// Storage (dev uniquement)
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

4) Données minimales pour tester
- Collection `users` (exemples)
```json
{
  "uid": "recruiter_1",
  "firstName": "Sophie",
  "lastName": "Martin",
  "email": "r",
  "companyName": "TechCorp",
  "isRecruiter": true,
  "createdAt": {".sv": "timestamp"}
}
```

```json
{
  "uid": "candidate_1",
  "firstName": "Elodie",
  "lastName": "Durand",
  "email": "candidat@example.com",
  "isRecruiter": false,
  "createdAt": {".sv": "timestamp"}
}
```

- Collection `posts` (annonces publiées par un recruteur)
```json
{
  "id": "auto-généré",
  "authorUid": "recruiter_1",
  "title": "Développeur Flutter",
  "content": "CDI · Paris · 2-5 ans",
  "imageUrl": "https://…",
  "tags": ["CDI", "Paris", "Flutter"],
  "isActive": true,
  "createdAt": {".sv": "timestamp"}
}
```

- Collections optionnelles selon l’usage: `matches`, `messages`, `favorites`/`swipes`

5) Côté application
- Mettre à jour `lib/firebase_options.dart` avec votre config Web
- Lancer: `flutter pub get && flutter run -d chrome`

Astuce (Web): si les assets ne se chargent pas après un changement, faire un Hard Reload (Cmd+Shift+R).

### Seeding automatique des données de test

Le seeding se fait automatiquement au démarrage de l'app en mode émulateur. Pour le faire manuellement :

```dart
import 'package:hire_me/utils/seed_helper.dart';

// Vérifier les données existantes
await SeedHelper.checkData();

// Créer les données de test
await SeedHelper.seedData();

// Supprimer toutes les données
await SeedHelper.clearData();

// Réinitialiser (supprimer + recréer)
await SeedHelper.resetData();
```

**Données créées automatiquement :**
- 2 candidats (Élodie, Marie)
- 2 recruteurs (Sophie @ TechCorp, Thomas @ StartupIO)
- 3 offres d'emploi
- 2 matches actifs
- 5 messages d'exemple

### Exemples de documents (autres collections)

- Collection `matches` (relation candidat ↔ recruteur)
```json
{
  "id": "auto-généré",
  "candidateUid": "candidate_1",
  "recruiterUid": "recruiter_1",
  "createdAt": {".sv": "timestamp"},
  "lastMessageAt": {".sv": "timestamp"}
}
```

## 🔒 Règles Firestore conseillées (ciblées par collection)

Remplacez les règles « dev » par ces règles plus strictes quand vous passez en pré-prod/prod.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }   

    // users — lecture/écriture limitée au propriétaire
    match /users/{uid} {
      allow read, update, delete: if isSignedIn() && request.auth.uid == uid;
      allow create: if isSignedIn();

      // Sous-collection favorites — seulement par le propriétaire
      match /favorites/{favoriteId} {
        allow read, write: if isSignedIn() && request.auth.uid == uid;
      }
    }

    // posts (annonces) — lecture publique, écriture par auteur connecté
    match /posts/{postId} {
      allow read: if true;
      allow create: if isSignedIn() && request.resource.data.authorUid == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.authorUid == request.auth.uid;
    }

    // matches — lecture/écriture par les participants uniquement
    match /matches/{matchId} {
      allow read, update, delete: if isSignedIn() &&
        (resource.data.candidateUid == request.auth.uid || resource.data.recruiterUid == request.auth.uid);
      allow create: if isSignedIn() &&
        (request.resource.data.candidateUid == request.auth.uid || request.resource.data.recruiterUid == request.auth.uid);
    }

    // messages — lecture/écriture par les participants du match
    match /messages/{messageId} {
      allow read, create: if isSignedIn() &&
        exists(/databases/$(database)/documents/matches/$(request.resource.data.matchId)) &&
        let match = get(/databases/$(database)/documents/matches/$(request.resource.data.matchId)).data in
        (match.candidateUid == request.auth.uid || match.recruiterUid == request.auth.uid);

      allow update, delete: if isSignedIn() &&
        let msg = resource.data in
        exists(/databases/$(database)/documents/matches/$(msg.matchId)) &&
        let match = get(/databases/$(database)/documents/matches/$(msg.matchId)).data in
        (match.candidateUid == request.auth.uid || match.recruiterUid == request.auth.uid);
    }

    // swipes — écriture par l'émetteur, lecture par l'émetteur (ajustez selon vos besoins)
    match /swipes/{swipeId} {
      allow create: if isSignedIn() && request.resource.data.fromUid == request.auth.uid;
      allow read, update, delete: if isSignedIn() && resource.data.fromUid == request.auth.uid;
    }
  }
}
```

- Collection `messages` (un document par message)
```json
{
  "id": "auto-généré",
  "matchId": "<match_id>",
  "senderUid": "candidate_1",
  "receiverUid": "recruiter_1",
  "content": "Bonjour !",
  "sentAt": {".sv": "timestamp"}
}
```

- Sous-collection `favorites` (par utilisateur)
Chemin recommandé: `users/{uid}/favorites/{jobId}`
```json
{
  "jobId": "<job_offer_id>",
  "createdAt": {".sv": "timestamp"}
}
```

- Collection `swipes` (historique des actions)
```json
{
  "id": "auto-généré",
  "fromUid": "candidate_1",
  "toEntityId": "<job_or_company_id>",
  "type": "candidate→job", // ou "company→candidate"
  "value": "like", // like | pass | superlike
  "createdAt": {".sv": "timestamp"}
}
```

## 🚀 Prochaines étapes

- [x] Tests unitaires et d'intégration
- [x] Configuration Firebase complète via `flutterfire configure`
- [ ] Optimisation des performances
- [ ] Ajout de nouvelles fonctionnalités (filtres, recherche, etc.)
- [ ] CI/CD avec GitHub Actions

## 📄 Licence

Ce projet est destiné à des fins de MVP/démonstration.
