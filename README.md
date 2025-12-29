# Swipeem - Documentation Technique

> **Source of Truth** pour tous les développeurs du projet Swipeem.  
> Ce document définit l'architecture, les conventions, les règles de sécurité et le workflow de développement.

---

## 📋 Table des matières

- [Vision & Principes](#vision--principes)
- [Architecture](#architecture)
- [Structure du Projet](#structure-du-projet)
- [Firebase Design Rules](#firebase-design-rules)
- [Sécurité & RGPD](#sécurité--rgpd)
- [Messagerie & Matching](#messagerie--matching)
- [Standards de Code](#standards-de-code)
- [Workflow Développeur](#workflow-développeur)
- [Anti-patterns](#anti-patterns)
- [Installation](#installation)
- [Documentation Complémentaire](#documentation-complémentaire)

---

## Vision & Principes

### Mission

Swipeem connecte candidats et recruteurs via un **matching basé uniquement sur les compétences**, en excluant toute discrimination basée sur l'apparence, l'origine ou le genre.

### Principes Fondamentaux

#### 1. Matching Basé sur les Compétences
- **Hard Skills** : Compétences techniques (Flutter, Python, Firebase, etc.)
- **Soft Skills** : Compétences comportementales (communication, leadership, etc.)
- **Expérience** : Parcours professionnel et académique
- **Personnalité** : Résultats de tests (avec consentement explicite)

#### 2. Lutte Contre les Discriminations
- ✅ **Avatar par défaut** : Tous les utilisateurs ont un avatar générique
- ✅ **Photo réelle masquée** : Photo optionnelle, **non visible dans le matching**
- ✅ **Données privées exclues** : Nationalité, âge, genre, nom complet exclus de l'algorithme
- ✅ **Prénom uniquement** : Dans le profil public visible pour matching

#### 3. IA = Suggestion Uniquement
- ✅ **IA suggère** : Compétences, tags, descriptions améliorées
- ✅ **Utilisateur valide** : Toujours demander confirmation avant application
- ✅ **Traçabilité** : Chaque suggestion IA est tracée avec `source: "ai_suggestion"` et `validatedByUser: true/false`
- ❌ **Jamais source de vérité** : L'IA ne remplace jamais la validation humaine

#### 4. Séparation Client / Serveur
- **Flutter (Client)** : UI, validation UX, affichage, événements utilisateur
- **Cloud Functions (Serveur)** : Logique métier, algorithmes, notifications, sécurité
- **Règle d'or** : Jamais de logique métier critique dans Flutter

---

## Architecture

### Schéma des Flux

```
┌─────────────────────────────────────────┐
│         FLUTTER (Client)                 │
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ Features │→ │ Services │→ │Providers│ │
│  │   (UI)   │  │  (API)   │  │ (State) │ │
│  └──────────┘  └──────────┘  └────────┘ │
└──────────────────┬───────────────────────┘
                   │
                   │ HTTPS / WebSocket
                   │
┌──────────────────▼───────────────────────┐
│      FIREBASE (Serveur)                   │
│  ┌────────────┐  ┌────────────┐          │
│  │ Firestore │  │  Storage   │          │
│  │ (Données) │  │ (Fichiers) │          │
│  └─────┬──────┘  └────────────┘          │
│        │                                  │
│  ┌─────▼──────────────────────────────┐  │
│  │   Cloud Functions                  │  │
│  │  - onSwipeCreate (match)           │  │
│  │  - onMessageCreate (notif)         │  │
│  │  - computeCompatibility (scoring)   │  │
│  │  - getPublicProfile (sécurité)      │  │
│  └────────────────────────────────────┘  │
│  ┌────────────┐  ┌────────────┐          │
│  │    Auth    │  │ Messaging  │          │
│  │ (Sessions) │  │   (FCM)    │          │
│  └────────────┘  └────────────┘          │
└───────────────────────────────────────────┘
```

### Séparation des Responsabilités

#### Flutter - Features (UI)
- ✅ Rendu des écrans
- ✅ Gestion des événements utilisateur (clics, formulaires)
- ✅ Validation UX (format email, champs requis)
- ❌ **Interdit** : Logique métier, appels Firestore directs, calculs d'algorithmes

#### Flutter - Services
- ✅ Appels API vers Firebase (Firestore, Storage, Functions)
- ✅ Transformation de données (Firestore Document → Model Dart)
- ✅ Gestion des erreurs réseau
- ❌ **Interdit** : Logique métier complexe, validation métier

#### Flutter - Providers (Riverpod)
- ✅ State management global
- ✅ Streams Firestore (écoute des mises à jour)
- ✅ Cache en mémoire
- ✅ Synchronisation état UI ↔ Services
- ❌ **Interdit** : Logique métier, appels API directs

#### Cloud Functions
- ✅ **Algorithmes de matching** : Calcul du score de compatibilité
- ✅ **Création de matches** : Détection de like mutuel (`onSwipeCreate`)
- ✅ **Notifications FCM** : Envoi push après match/message (`onMessageCreate`)
- ✅ **Sécurité** : Vérification des droits, validation serveur
- ✅ **Extraction IA** : Extraction de compétences depuis CV (si implémenté)
- ❌ **Interdit** : Logique simple de CRUD (utiliser Firestore direct)

### Flux Typique : Création d'un Match

```
1. User swipe "like" (Flutter Feature)
   ↓
2. FirebaseSwipeService.createSwipe() (Flutter Service)
   ↓
3. Firestore: Document créé dans collection 'swipes'
   ↓
4. Cloud Function: onSwipeCreate trigger
   ↓
5. Function vérifie like mutuel
   ↓
6. Si mutuel → Crée document 'matches/{matchId}'
   ↓
7. Function envoie notification FCM aux 2 parties
   ↓
8. Firestore Stream → Provider (Flutter)
   ↓
9. UI mise à jour (nouveau match affiché)
```

---

## Structure du Projet

### Organisation Feature-First

```
lib/
├── core/                    # Configuration centrale (1 seule fois)
│   ├── app_router.dart      # Routes GoRouter
│   ├── app_theme.dart       # Thèmes Material Design
│   └── di.dart              # Injection de dépendances
│
├── features/                # Modules fonctionnels (feature-first)
│   ├── auth/                # Authentification
│   ├── swipe/               # Interface de swipe
│   ├── messages/            # Messagerie
│   ├── profile/             # Profil utilisateur
│   ├── recruiter/           # Fonctionnalités recruteur
│   ├── admin/               # Administration
│   ├── interviews/          # Gestion des entretiens
│   ├── posts/               # Gestion des offres
│   └── ...
│
├── services/                # Services métier (API calls)
│   ├── auth_service.dart
│   ├── firebase_user_service.dart
│   ├── firebase_match_service.dart
│   ├── firebase_message_service.dart
│   ├── firebase_swipe_service.dart
│   └── ...
│
├── models/                  # Modèles de données Dart
│   ├── user_model.dart
│   ├── post_model.dart
│   ├── match_model.dart
│   └── message_model.dart
│
├── providers/               # State management (Riverpod)
│   ├── user_provider.dart
│   ├── message_provider.dart
│   └── ...
│
└── widgets/                 # Composants réutilisables

functions/
└── src/
    └── index.ts            # Cloud Functions (TypeScript)
```

### Règles par Couche

#### ✅ Autorisé dans `features/`
- Écrans (screens)
- Widgets spécifiques à la feature
- Validation UX (format, champs requis)
- Navigation locale à la feature

#### ❌ Interdit dans `features/`
- Appels Firestore directs → Utiliser les services
- Logique métier complexe → Cloud Functions
- State management global → Providers

#### ✅ Autorisé dans `services/`
- Appels API vers Firebase
- Transformation Firestore → Model
- Gestion des erreurs réseau
- Cache local si nécessaire

#### ❌ Interdit dans `services/`
- Logique métier complexe → Cloud Functions
- Validation métier → Firestore Rules + Functions
- Calculs d'algorithmes → Cloud Functions

#### ✅ Autorisé dans `providers/`
- State management global
- Streams Firestore
- Cache en mémoire
- Synchronisation état UI ↔ Services

#### ❌ Interdit dans `providers/`
- Logique métier
- Appels API directs → Utiliser les services

---

## Firebase Design Rules

### Firestore

#### Pagination Obligatoire
- ✅ **Toujours paginer** les listes de plus de 20 éléments
- ✅ Utiliser `limit()` et `startAfter()` pour la pagination
- ❌ Jamais charger tous les documents d'une collection

```dart
// ✅ BON
final query = FirebaseFirestore.instance
  .collection('posts')
  .orderBy('createdAt', descending: true)
  .limit(20);

// ❌ MAUVAIS
final query = FirebaseFirestore.instance.collection('posts');
```

#### Indexes Requis
- ✅ Créer les index Firestore pour toutes les requêtes avec `where()` + `orderBy()`
- ✅ Vérifier `firestore.indexes.json` avant de déployer
- ❌ Requêtes non indexées → Erreur en production

#### Duplication Raisonnée
- ✅ Dupliquer les données fréquemment lues (ex: `displayName` dans `messages`)
- ✅ Éviter les jointures coûteuses
- ❌ Ne pas dupliquer les données sensibles

#### Structure Collections

```
users/{uid}
  - uid, email, firstName, lastName
  - profileImageUrl (Firebase Storage URL)
  - skills, softSkills, hardSkills
  - isRecruiter, isAdmin (gérés côté serveur uniquement)
  - createdAt, updatedAt

matches/{matchId}
  - candidateUid, recruiterUid
  - matchedAt, lastMessageAt
  - isActive, readBy: {uid: bool}

messages/{messageId}
  - matchId, senderUid, receiverUid
  - content, type, sentAt
  - isRead, readAt

swipes/{pairId}
  - fromUid, toEntityId, type, value
  - createdAt

posts/{postId}
  - authorUid, title, content, tags
  - isActive, createdAt
```

### Storage

#### Conventions de Chemins
```
users/{userId}/profile.jpg    # Photo de profil (max 5 MB, image/*)
users/{userId}/cv.pdf          # CV (max 10 MB, application/pdf)
```

#### Règles de Sécurité
- ✅ Authentification requise
- ✅ Validation des types (images, PDF uniquement)
- ✅ Limitation de taille (5 MB photos, 10 MB CV)
- ✅ Vérification propriétaire (uniquement son propre dossier)

#### ⚠️ Important
- **Storage = Fichiers uniquement** : Jamais de logique, jamais de données structurées
- **Données structurées → Firestore** : Utiliser Firestore pour les métadonnées

### Auth

#### Création Automatique Users
- ✅ Créer automatiquement `users/{uid}` lors de la première connexion
- ✅ Utiliser Cloud Function `onUserCreate` trigger (à implémenter si absent)
- ✅ Initialiser les champs par défaut (avatar, publicProfile, etc.)

#### Rôles Sécurisés
- **Candidat** : `isRecruiter: false, isAdmin: false`
- **Recruteur** : `isRecruiter: true, isAdmin: false`
- **Admin** : `isAdmin: true` (défini **uniquement** côté serveur)

#### ⚠️ Sécurité Critique
- ❌ **Jamais modifier `isAdmin` depuis Flutter**
- ✅ Vérifier les rôles dans Firestore Rules
- ✅ Vérifier les rôles dans Cloud Functions

### Cloud Functions

#### Functions Existantes

**Triggers Firestore** :
- `onSwipeCreate` : Détecte like mutuel et crée un match
- `onMessageCreate` : Met à jour `lastMessageAt` dans le match

**Callable Functions** :
- `computeCompatibility` : Calcule le score de compatibilité candidat/poste
- `getPublicProfile` : Récupère uniquement le profil public (sécurité)

**HTTP Functions** :
- `seedAllTestData` : Seeding de données de test (développement uniquement)

#### Règles de Conception
- ✅ **Logique sensible uniquement** : Algorithmes, scoring, notifications
- ✅ **Validation serveur** : Toujours valider les inputs
- ✅ **Gestion d'erreurs** : Retourner des erreurs HTTP standardisées
- ❌ **Pas de logique simple** : CRUD basique → Firestore direct

---

## Sécurité & RGPD

### Minimisation des Données

- ✅ **Collecter uniquement** ce qui est nécessaire
- ✅ **Ne pas stocker** de données sensibles inutiles
- ✅ **Anonymiser** les données d'analytics
- ✅ **Supprimer** les données obsolètes

### Séparation Public / Privé

#### publicProfile (Utilisé pour Matching)
```dart
{
  "firstName": "Marie",           // Prénom uniquement
  "skills": {
    "hard": ["Flutter", "Dart"],
    "soft": ["Communication", "Leadership"]
  },
  "experiences": [...],
  "academicPath": [...],
  "personalityTest": {...}        // Avec consentement
}
```

#### privateProfile (Jamais dans Matching)
```dart
{
  "lastName": "Dupont",           // Nom complet
  "email": "marie@example.com",
  "phone": "+33612345678",
  "address": "...",
  "nationality": "French",        // Exclu du matching
  "dateOfBirth": "1990-01-01"     // Exclu du matching
}
```

### Champs Exclus du Matching

Ces champs **ne doivent jamais** être utilisés dans l'algorithme :

- ❌ `profileImageUrl` (photo réelle)
- ❌ `nationality` / `countryOfOrigin`
- ❌ `age` / `dateOfBirth`
- ❌ `gender`
- ❌ `ethnicity`
- ❌ `religion`
- ❌ `lastName` (nom complet)

### Consentements

Chaque utilisateur doit avoir :
```dart
{
  "consents": {
    "analytics": true/false,
    "aiSuggestions": true/false,
    "personalityTest": true/false,
    "marketing": true/false,
    "dataSharing": true/false
  },
  "consentsUpdatedAt": "timestamp"
}
```

### Droit à l'Oubli (Roadmap)

- ⏳ **Endpoint Cloud Function** : `deleteUserData(userId)` (à implémenter)
- ⏳ **Suppression complète** : Firestore, Storage, Auth
- ⏳ **Délai de grâce** : 30 jours avant suppression définitive

### Export des Données (Roadmap)

- ⏳ **Endpoint Cloud Function** : `exportUserData(userId)` (à implémenter)
- ⏳ **Format JSON** : Toutes les données utilisateur
- ⏳ **Inclure** : Profil, messages, matches, posts

### Secrets & .gitignore

#### ⚠️ Ce qui ne doit JAMAIS être dans le code

- ❌ **Clés API** : Jamais dans Flutter
- ❌ **Secrets** : Tokens, credentials
- ❌ **Service Account JSON** : Fichiers de credentials Firebase Admin
- ❌ **Données sensibles** : Numéros de carte, mots de passe

#### ✅ Utiliser des Variables d'Environnement

```dart
// ✅ BON
const String apiKey = String.fromEnvironment('API_KEY');

// ❌ MAUVAIS
const String apiKey = 'sk_live_1234567890abcdef';
```

#### Fichiers Ignorés (voir `.gitignore`)

- `**/credentials.json`
- `**/service-account.json`
- `**/*_key.json`
- `.env`, `.env.local`
- `firebase_options.dart` (généré, peut contenir des infos sensibles)

Voir [SECURITY.md](./SECURITY.md) pour plus de détails.

---

## Messagerie & Matching

### Création d'un Match

#### Règle : Match Uniquement si Like Mutuel

1. **User A swipe "like" sur User B** → Document créé dans `swipes/{pairId}`
2. **Cloud Function `onSwipeCreate` trigger** :
   - Vérifie si User B a aussi swipé "like" sur User A
   - Si oui → Crée document `matches/{matchId}`
   - Envoie notification FCM aux 2 parties
3. **Flutter reçoit le match** via Firestore Stream → Provider → UI

#### ⚠️ Interdit
- ❌ Créer un match depuis Flutter directement
- ❌ Créer un match sans vérification de like mutuel

### Modèle Messages

```dart
messages/{messageId}
  - matchId: string
  - senderUid: string
  - receiverUid: string
  - content: string
  - type: "text" | "image" | "system"
  - sentAt: timestamp
  - isRead: boolean
  - readAt: timestamp?
```

### Unread Count

- ✅ **Calculé côté serveur** : Cloud Function maintient le compteur
- ✅ **Stocké dans** : `users/{uid}/unreadMessageCount` (à implémenter si absent)
- ✅ **Stream Firestore** : Flutter écoute les mises à jour

### Notifications FCM

#### Règle : Notifications Uniquement depuis Cloud Functions

- ✅ **Toutes les notifications** sont envoyées par Cloud Functions
- ✅ **Triggers Firestore** : `onCreate`, `onUpdate` pour matches/messages
- ❌ **Jamais depuis Flutter** : Pas d'envoi direct depuis le client

#### Exemples de Notifications

- **Nouveau match** : `onSwipeCreate` → Notification aux 2 parties
- **Nouveau message** : `onMessageCreate` → Notification au receiver
- **Entretien proposé** : Function dédiée → Notification

---

## Standards de Code

### State Management : Riverpod (Obligatoire)

#### Règles
- ✅ **Providers pour état global** : User, thème, messages
- ✅ **Providers pour streams** : Firestore streams
- ✅ **Auto-dispose** : Utiliser `autoDispose` pour les providers temporaires
- ❌ **Pas de setState** : Utiliser Riverpod partout

#### Exemple
```dart
// ✅ BON
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ❌ MAUVAIS
setState(() {
  _user = newUser;
});
```

### Navigation : GoRouter (Obligatoire)

#### Règles
- ✅ **Routes déclaratives** : Définir toutes les routes dans `app_router.dart`
- ✅ **Type-safe** : Utiliser les paramètres typés
- ✅ **Redirections** : Basées sur l'état d'authentification
- ❌ **Pas de Navigator.push** : Utiliser `context.go()` ou `context.push()`

### Gestion des Erreurs Standardisée

#### Structure d'Erreur
```dart
class AppException implements Exception {
  final String message;
  final String? code;
  AppException(this.message, {this.code});
}

// Types d'erreurs
class NetworkException extends AppException {}
class AuthException extends AppException {}
class ValidationException extends AppException {}
```

#### Gestion dans les Services
```dart
try {
  // Appel Firebase
} on FirebaseException catch (e) {
  throw AppException(e.message ?? 'Erreur Firebase', code: e.code);
} catch (e) {
  throw AppException('Erreur inattendue: ${e.toString()}');
}
```

### Tests Minimum Requis

#### Par Feature Critique
- ✅ **Auth** : Tests de connexion, inscription
- ✅ **Matching** : Tests d'algorithme (Cloud Functions)
- ✅ **Messages** : Tests d'envoi, réception
- ⏳ **Firestore Rules** : Tests de sécurité (à implémenter)

#### Outils
- `flutter_test` : Tests unitaires Flutter
- `firebase-emulator` : Tests d'intégration Firebase
- `test` (Dart) : Tests unitaires Dart

---

## Workflow Développeur

### Installation

#### Prérequis
- **Flutter SDK** 3.9.2+
- **Dart SDK** 3.9.2+
- **Node.js** 18+ (pour Firebase Functions)
- **Firebase CLI** : `npm install -g firebase-tools`

#### Setup Initial

```bash
# 1. Cloner le repo
git clone https://github.com/Jetpurple/swipeem_app.git
cd swipeem_app

# 2. Installer dépendances Flutter
flutter pub get

# 3. Installer dépendances Functions
cd functions && npm install && cd ..

# 4. Configurer Firebase (voir section Installation ci-dessous)
```

### Commandes Utiles

```bash
# Analyse du code
flutter analyze

# Formatage
dart format .

# Tests
flutter test

# Build
flutter build web --release
flutter build ios --release
flutter build apk --release

# Firebase Emulators
firebase emulators:start

# Déployer Functions
firebase deploy --only functions

# Déployer Firestore Rules
firebase deploy --only firestore:rules
```

### Convention Branches / Commits

#### Branches
- `main` : Production
- `develop` : Développement
- `feature/xxx` : Nouvelle feature
- `fix/xxx` : Correction de bug
- `refactor/xxx` : Refactoring

#### Commits
Format : `type: description`

Types :
- `feat:` : Nouvelle feature
- `fix:` : Correction de bug
- `docs:` : Documentation
- `refactor:` : Refactoring
- `test:` : Tests
- `chore:` : Maintenance

Exemple : `feat: add pagination to posts list`

### PR Checklist (Definition of Done)

Avant de créer une Pull Request, vérifier :

- [ ] **Code Review** : Auto-review du code
- [ ] **Tests** : Tests passent (si applicable)
- [ ] **Linter** : `flutter analyze` sans erreurs
- [ ] **Format** : `dart format .` appliqué
- [ ] **Firestore Rules** : Vérifiées et testées
- [ ] **Sécurité** : Pas de secrets dans le code
- [ ] **Performance** : Pagination pour les listes
- [ ] **RGPD** : Consentements gérés si nouvelle feature
- [ ] **Documentation** : Code commenté si complexe

Voir [CONTRIBUTING.md](./CONTRIBUTING.md) pour plus de détails.

---

## Anti-patterns

### ❌ Logique Métier dans les Widgets

```dart
// ❌ MAUVAIS
class SwipeScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final score = calculateMatchScore(user, post); // Logique dans widget
    return Text('Score: $score');
  }
}

// ✅ BON
class SwipeScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(matchScoreProvider(userId, postId));
    return Text('Score: $score');
  }
}
// Le calcul se fait dans un Provider ou Cloud Function
```

### ❌ Appels Firestore Directs dans l'UI

```dart
// ❌ MAUVAIS
class PostsList extends StatelessWidget {
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) { ... }
    );
  }
}

// ✅ BON
class PostsList extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    return ListView(...);
  }
}
// L'appel Firestore est dans le service, le Provider expose le stream
```

### ❌ Clés API dans Flutter

```dart
// ❌ MAUVAIS
const String API_KEY = 'sk_live_1234567890abcdef';

// ✅ BON
const String apiKey = String.fromEnvironment('API_KEY');
// Ou Cloud Functions pour les appels API sensibles
```

### ❌ Champs Discriminants dans les Algorithmes

```dart
// ❌ MAUVAIS
double calculateMatchScore(User user, Post post) {
  double score = 0;
  if (user.nationality == post.preferredNationality) score += 10;
  if (user.age < 30) score += 5;
  // ...
}

// ✅ BON
double calculateMatchScore(User user, Post post) {
  double score = 0;
  // Uniquement compétences et expérience
  score += matchSkills(user.skills, post.requiredSkills);
  score += matchExperience(user.experiences, post.requirements);
  // ...
}
```

### ❌ Modification de Rôles Admin depuis Flutter

```dart
// ❌ MAUVAIS
await FirebaseFirestore.instance
  .collection('users')
  .doc(uid)
  .update({'isAdmin': true});

// ✅ BON
// Utiliser Cloud Function ou Firebase Console uniquement
```

### ❌ Requêtes Firestore Non Indexées

```dart
// ❌ MAUVAIS
final query = FirebaseFirestore.instance
  .collection('posts')
  .where('isActive', isEqualTo: true)
  .orderBy('createdAt', descending: true);
// Erreur si index manquant

// ✅ BON
// Créer l'index dans firestore.indexes.json avant
```

### ❌ Notifications depuis Flutter

```dart
// ❌ MAUVAIS
Future<void> sendNotification(String userId, String message) async {
  await FirebaseMessaging.instance.send(...);
}

// ✅ BON
// Utiliser Cloud Function trigger
// Firestore → Cloud Function → Notification
```

---

## Installation

### Configuration Firebase

#### 1. Créer un Projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet
3. Activez les services nécessaires :
   - **Authentication** : Email/Password, Google, LinkedIn, GitHub
   - **Firestore Database** : Mode production
   - **Storage** : Activer
   - **Cloud Functions** : Activer

#### 2. Télécharger les Fichiers de Configuration

**Android** :
- Téléchargez `google-services.json`
- Placez-le dans `android/app/google-services.json`

**iOS** :
- Téléchargez `GoogleService-Info.plist`
- Placez-le dans `ios/Runner/GoogleService-Info.plist`

#### 3. Configurer Firebase CLI

```bash
firebase login
firebase use --add  # Sélectionner votre projet
```

#### 4. Configurer les Émulateurs (Développement)

```bash
# Démarrer les émulateurs
firebase emulators:start

# Lancer l'app avec le flag
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true
```

### Configuration OAuth

#### Google Sign-In
1. Firebase Console → Authentication → Sign-in method
2. Activez Google
3. Copiez le **Web client ID**
4. Configurez dans `web/index.html` ou via `--dart-define`

#### LinkedIn
1. [LinkedIn Developers](https://www.linkedin.com/developers/apps)
2. Créez une app
3. Notez **Client ID** et **Client Secret**
4. Configurez les Redirect URLs
5. **⚠️ Ne jamais commiter les credentials**

#### GitHub
1. GitHub Settings → Developer settings → OAuth Apps
2. Créez une OAuth App
3. Notez **Client ID** et **Client Secret**
4. **⚠️ Ne jamais commiter les credentials**

### Scripts Utiles

```bash
# Vérifier les credentials
./scripts/check-credentials.sh

# Seeding des données de test (émulateur uniquement)
dart run lib/scripts/create_admin_test_data.dart

# Synchroniser users Auth ↔ Firestore
cd scripts && npm run sync:users
```

---

## Documentation Complémentaire

### Modèles de Données

Voir les fichiers dans `lib/models/` :
- `user_model.dart` : Modèle utilisateur
- `post_model.dart` : Modèle post/offre
- `match_model.dart` : Modèle match
- `message_model.dart` : Modèle message

### Services

Voir les fichiers dans `lib/services/` :
- `auth_service.dart` : Authentification
- `firebase_user_service.dart` : CRUD utilisateurs
- `firebase_match_service.dart` : Gestion des matches
- `firebase_message_service.dart` : Messagerie
- `firebase_swipe_service.dart` : Swipes

### Cloud Functions

Voir `functions/src/index.ts` pour :
- `onSwipeCreate` : Création de match
- `onMessageCreate` : Mise à jour lastMessageAt
- `computeCompatibility` : Calcul de score
- `getPublicProfile` : Récupération profil public

### Routes

Voir `lib/core/app_router.dart` pour toutes les routes de l'application.

### Fichiers de Configuration

- `firestore.rules` : Règles de sécurité Firestore
- `storage.rules` : Règles de sécurité Storage
- `firestore.indexes.json` : Index Firestore
- `firebase.json` : Configuration Firebase

### Documentation Additionnelle

- [CONTRIBUTING.md](./CONTRIBUTING.md) : Workflow de contribution
- [SECURITY.md](./SECURITY.md) : Règles de sécurité détaillées

---

## 📄 Licence

Ce projet est propriétaire. Tous droits réservés.

---

**Dernière mise à jour** : 2024
