# Swipeem - Plateforme de Matching Emploi

## 📋 Description Fonctionnelle

**Swipeem** est une application mobile et web de matching emploi inspirée de Tinder, permettant de connecter des candidats et des recruteurs de manière intuitive et moderne. L'application offre une expérience utilisateur fluide avec un système de swipe pour découvrir des opportunités d'emploi ou des profils candidats, une messagerie en temps réel, et un système complet de gestion de profil.

### 🎯 Objectif Principal

Faciliter la mise en relation entre candidats et recruteurs grâce à une interface moderne et intuitive, en combinant le principe du swipe avec des fonctionnalités avancées de matching, de communication et de gestion de carrière.

### 👥 Types d'Utilisateurs

1. **Candidats** : Recherchent des offres d'emploi, swipent sur des postes, communiquent avec les recruteurs
2. **Recruteurs** : Publient des offres, swipent sur des profils candidats, gèrent leurs recrutements
3. **Administrateurs** : Gèrent la plateforme, modèrent le contenu, administrent les données

---

## 🚀 Fonctionnalités Principales

### Pour les Candidats

#### 🔍 Découverte d'Offres
- **Swipe Screen** : Interface Tinder-like pour découvrir des offres d'emploi
- **Filtres et Recherche** : Filtrage par secteur, localisation, type de contrat
- **Détails des Offres** : Affichage complet des informations (salaire, localisation, description, entreprise)
- **Système de Match** : Notification et animation lors d'un match mutuel

#### 💬 Communication
- **Messagerie en Temps Réel** : Chat instantané avec les recruteurs après un match
- **Liste des Conversations** : Vue d'ensemble de toutes les discussions
- **Notifications Push** : Alertes pour nouveaux messages et matches
- **Badge de Messages Non Lus** : Compteur visuel dans la navigation

#### 📅 Gestion de Carrière
- **Profil Complet** : CV détaillé avec expériences, formations, compétences
- **Test de Personnalité** : Évaluation des soft skills
- **Gestion des Compétences** : Hard skills et soft skills
- **Parcours Académique** : Historique des formations
- **Expériences Professionnelles** : Historique des emplois

#### ⚙️ Paramètres
- **Gestion du Compte** : Modification du profil, photo, informations personnelles
- **Sécurité** : Gestion du mot de passe, 2FA, sessions actives
- **Abonnements** : Plans Gratuit, Premium, Pro avec fonctionnalités différenciées
- **Notifications** : Personnalisation des alertes (push, email, SMS)
- **Intégrations** : Connexion avec LinkedIn, Google, GitHub, etc.
- **Apparence** : Thème clair/sombre, accessibilité

### Pour les Recruteurs

#### 👥 Découverte de Talents
- **Swipe sur Candidats** : Interface dédiée pour découvrir des profils
- **Détails Candidat** : Vue complète du CV, compétences, expériences
- **Filtres Avancés** : Recherche par compétences, expérience, localisation
- **Statistiques** : Tableau de bord avec métriques de recrutement

#### 📝 Gestion des Offres
- **Création d'Offres** : Publication d'annonces détaillées avec tags et catégories
- **Gestion des Posts** : Liste, modification, suppression des offres publiées
- **Suivi des Candidatures** : Vue d'ensemble des candidats intéressés

#### 💬 Communication
- **Messagerie** : Chat avec les candidats matchés
- **Propositions d'Entretiens** : Calendrier intégré pour planifier des rendez-vous
- **Notifications** : Alertes pour nouveaux matches et messages

### Pour les Administrateurs

#### 🛠️ Administration
- **Tableau de Bord** : Statistiques globales (utilisateurs, posts, messages, matches)
- **Gestion des Posts** : Création, modification, suppression de posts
- **Gestion des Messages** : Création de messages entre utilisateurs, modération
- **Gestion des Données de Test** : Seeding et réinitialisation des données

---

## 🏗️ Description Technique

### Architecture

L'application suit une architecture **modulaire** basée sur Flutter avec une séparation claire des responsabilités :

```
lib/
├── core/                    # Configuration centrale
│   ├── app_router.dart      # Navigation avec GoRouter
│   ├── app_theme.dart       # Thèmes (clair/sombre)
│   └── di.dart              # Injection de dépendances
├── features/                # Modules fonctionnels
│   ├── auth/               # Authentification
│   ├── swipe/              # Interface de swipe
│   ├── messages/           # Messagerie
│   ├── profile/            # Profil utilisateur
│   ├── recruiter/          # Fonctionnalités recruteur
│   ├── admin/              # Administration
│   ├── interviews/         # Gestion des entretiens
│   └── posts/              # Gestion des offres
├── services/               # Services métier
│   ├── auth_service.dart
│   ├── firebase_*_service.dart
│   └── notification_service.dart
├── models/                 # Modèles de données
├── providers/             # State management (Riverpod)
└── widgets/                # Composants réutilisables
```

### Stack Technique

#### Frontend
- **Flutter** : Framework cross-platform (iOS, Android, Web)
- **Dart** : Langage de programmation (SDK 3.9.2+)
- **Riverpod** : Gestion d'état réactive et type-safe
- **GoRouter** : Navigation déclarative et type-safe

#### Backend & Services
- **Firebase Authentication** : Authentification multi-providers
  - Email/Password
  - Google Sign-In
  - GitHub OAuth
  - LinkedIn OAuth
- **Cloud Firestore** : Base de données NoSQL en temps réel
- **Firebase Storage** : Stockage de fichiers (photos, CV)
- **Firebase Cloud Functions** : Backend serverless (TypeScript)
- **Firebase Messaging** : Notifications push
- **Firebase Analytics** : Analytics et tracking
- **Firebase Crashlytics** : Monitoring des erreurs

#### Design & UI
- **Material Design 3** : Design system moderne
- **Glassmorphism** : Effets de verre translucide
- **Animations** : Transitions fluides avec `flutter_animate`
- **Responsive Design** : Mobile-first, adaptatif desktop
- **Dark Mode** : Support complet du thème sombre

#### Dépendances Principales

**État & Navigation**
- `flutter_riverpod: ^3.0.1` - Gestion d'état
- `go_router: ^16.2.4` - Navigation

**Firebase**
- `firebase_core: ^4.1.1`
- `firebase_auth: ^6.1.0`
- `cloud_firestore: ^6.0.2`
- `firebase_storage: ^13.0.2`
- `firebase_messaging: ^16.0.2`
- `firebase_analytics: ^12.0.2`
- `firebase_crashlytics: ^5.0.2`
- `cloud_functions: ^6.0.2`

**UI & Animations**
- `flutter_animate: ^4.5.2` - Animations
- `lottie: ^3.3.2` - Animations vectorielles
- `carousel_slider: ^5.1.1` - Carrousels
- `google_fonts: ^6.3.2` - Polices Google

**Formulaires & Données**
- `flutter_form_builder: ^10.2.0` - Formulaires
- `intl: ^0.20.2` - Internationalisation
- `table_calendar: ^3.1.2` - Calendrier

**Médias**
- `image_picker: ^1.0.7` - Sélection d'images
- `image_cropper: ^11.0.0` - Recadrage d'images
- `video_player: ^2.10.1` - Lecture vidéo

**Authentification Sociale**
- `google_sign_in: ^6.2.1` - Google
- `linkedin_login: ^3.1.3` - LinkedIn
- `font_awesome_flutter: ^10.8.0` - Icônes sociales

**Utilitaires**
- `shared_preferences: ^2.5.3` - Stockage local
- `url_launcher: ^6.3.1` - Ouverture de liens
- `path_provider: ^2.1.1` - Chemins système

### Modèles de Données

#### UserModel
```dart
- String uid
- String email
- String displayName
- String? photoURL
- bool isRecruiter
- bool isAdmin
- bool isPremium
- Map<String, dynamic> profileData
  - experiences
  - academicPath
  - skills (hard/soft)
  - personalityTest
```

#### PostModel (Offres d'Emploi)
```dart
- String id
- String recruiterUid
- String title
- String description
- List<String> tags
- String location
- String? salary
- DateTime createdAt
```

#### MatchModel
```dart
- String id
- String candidateUid
- String recruiterUid
- DateTime matchedAt
- DateTime? lastMessageAt
- bool isActive
- Map<String, bool> readBy
```

#### MessageModel
```dart
- String id
- String matchId
- String senderUid
- String receiverUid
- String content
- MessageType type (text, image, system)
- DateTime sentAt
- DateTime? readAt
- bool isRead
```

#### InterviewModel
```dart
- String id
- String matchId
- String proposerUid
- String receiverUid
- DateTime proposedDateTime
- InterviewStatus status
- String? location
- String? notes
```

### Services Métier

#### AuthService
- Authentification multi-providers
- Gestion des sessions
- Création automatique de documents utilisateur

#### FirebaseUserService
- CRUD utilisateurs
- Mise à jour de profil
- Gestion des abonnements

#### FirebaseSwipeService
- Gestion des swipes (like/pass)
- Détection des matches
- Algorithme de recommandation

#### FirebaseMatchService
- Création/gestion des matches
- Statut des matches
- Historique

#### FirebaseMessageService
- Envoi/réception de messages
- Marquage comme lu
- Notifications

#### FirebaseJobService
- CRUD des offres d'emploi
- Filtrage et recherche
- Gestion des tags

#### FirebaseInterviewService
- Création de propositions d'entretien
- Gestion du calendrier
- Statuts d'entretien

#### NotificationService
- Notifications push
- Notifications locales
- Gestion des permissions

#### StorageService
- Upload de photos
- Upload de CV
- Gestion des fichiers

#### AdminService
- Vérification des droits admin
- Gestion des données
- Modération

### State Management (Riverpod)

#### Providers Principaux
- `currentUserProvider` : Utilisateur connecté
- `appRouterProvider` : Configuration du routeur
- `themeNotifierProvider` : Gestion du thème
- `unreadMessageCountProvider` : Compteur de messages non lus
- `matchesProvider` : Liste des matches
- `messagesProvider` : Messages d'une conversation

### Navigation

L'application utilise **GoRouter** avec :
- **Routes publiques** : `/login`, `/register`
- **Routes protégées** : Toutes les autres routes nécessitent une authentification
- **ShellRoute** : Navigation avec footer (bottom navigation bar)
- **Redirection automatique** : Basée sur l'état d'authentification

**Routes principales** :
- `/swipe` : Interface de swipe (candidats ou recruteurs)
- `/messages` : Liste des conversations
- `/chat?matchId=xxx` : Chat en temps réel
- `/profile` : Tableau de bord profil
- `/edit-profile` : Édition du profil
- `/settings` : Paramètres
- `/calendar` : Calendrier des entretiens
- `/create-post` : Création d'offre (recruteurs)
- `/admin` : Dashboard admin

### Sécurité

#### Firestore Rules
- Authentification requise pour la plupart des opérations
- Vérification des propriétaires pour les modifications
- Règles spécifiques par collection
- Protection des données sensibles

#### Storage Rules
- Authentification requise pour les uploads
- Validation des types de fichiers
- Limitation de taille
- Vérification des propriétaires

### Performance

- **Lazy Loading** : Chargement progressif des données
- **Pagination** : Pour les listes longues
- **Cache** : Utilisation de SharedPreferences pour les données locales
- **Optimisation Web** : Désactivation de la persistance Firestore sur web
- **Images** : Compression et optimisation
- **Animations** : Utilisation de `Transform` et `Opacity` pour de meilleures performances

---

## 📦 Installation & Configuration

### Prérequis

- **Flutter SDK** 3.9.2 ou supérieur
- **Dart SDK** 3.9.2 ou supérieur
- **Node.js** (pour Firebase Functions)
- **Firebase CLI** (optionnel, pour le déploiement)
- **Xcode** (pour iOS)
- **Android Studio** (pour Android)

### Installation

1. **Cloner le projet**
```bash
git clone <repository-url>
cd hire_me
```

2. **Installer les dépendances Flutter**
```bash
flutter pub get
```

3. **Configurer Firebase**

   - Créer un projet sur [Firebase Console](https://console.firebase.google.com/)
   - Activer Authentication (Email/Password, Google, etc.)
   - Créer une base Firestore
   - Configurer Firebase Storage
   - Télécharger les fichiers de configuration :
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → `ios/Runner/`

4. **Configurer les credentials OAuth**

   - **Google** : Configurer dans Firebase Console → Authentication → Sign-in method
   - **LinkedIn** : Obtenir Client ID et Secret depuis [LinkedIn Developers](https://www.linkedin.com/developers/)
   - **GitHub** : Configurer OAuth App dans GitHub Settings

5. **Lancer l'application**

```bash
# Web
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

### Mode Émulateur Firebase (Développement)

Pour utiliser les émulateurs Firebase en local :

```bash
# Démarrer les émulateurs
firebase emulators:start

# Lancer l'app avec le flag
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true
```

### Scripts Utiles

```bash
# Vérifier les credentials
./scripts/check-credentials.sh

# Seeding des données de test (émulateur uniquement)
dart run lib/scripts/create_admin_test_data.dart

# Build pour production
flutter build web --release
flutter build ios --release
flutter build apk --release
```

---

## 📁 Structure du Projet

```
hire_me/
├── lib/
│   ├── core/                    # Configuration centrale
│   │   ├── app_router.dart      # Routes et navigation
│   │   ├── app_theme.dart       # Thèmes
│   │   └── di.dart              # Injection de dépendances
│   │
│   ├── features/                # Modules fonctionnels
│   │   ├── auth/                # Authentification
│   │   ├── swipe/               # Interface de swipe
│   │   ├── messages/            # Messagerie
│   │   ├── profile/             # Profil utilisateur
│   │   ├── recruiter/          # Fonctionnalités recruteur
│   │   ├── admin/               # Administration
│   │   ├── interviews/          # Gestion des entretiens
│   │   └── posts/               # Gestion des offres
│   │
│   ├── services/                # Services métier
│   │   ├── auth_service.dart
│   │   ├── firebase_user_service.dart
│   │   ├── firebase_swipe_service.dart
│   │   ├── firebase_match_service.dart
│   │   ├── firebase_message_service.dart
│   │   ├── firebase_job_service.dart
│   │   ├── firebase_interview_service.dart
│   │   ├── notification_service.dart
│   │   ├── storage_service.dart
│   │   └── admin_service.dart
│   │
│   ├── models/                  # Modèles de données
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   ├── match_model.dart
│   │   ├── message_model.dart
│   │   └── interview_model.dart
│   │
│   ├── providers/               # State management
│   │   ├── user_provider.dart
│   │   ├── message_provider.dart
│   │   └── theme_provider.dart
│   │
│   ├── widgets/                 # Composants réutilisables
│   ├── utils/                   # Utilitaires
│   └── main.dart               # Point d'entrée
│
├── assets/                      # Ressources
│   ├── ui/                      # Images et logos
│   └── animations/              # Animations
│
├── web/                         # Configuration web
│   ├── index.html
│   └── manifest.json
│
├── android/                     # Configuration Android
├── ios/                         # Configuration iOS
├── functions/                   # Firebase Cloud Functions
│   └── src/
│       └── index.ts
│
├── scripts/                     # Scripts utilitaires
│   ├── check-credentials.sh
│   └── *.ts                    # Scripts TypeScript
│
├── firestore.rules             # Règles de sécurité Firestore
├── storage.rules                # Règles de sécurité Storage
├── pubspec.yaml                # Dépendances Flutter
└── README.md                   # Ce fichier
```

---

## 🔐 Sécurité & Conformité

### Authentification
- Multi-factor authentication (2FA) disponible
- Sessions sécurisées avec Firebase Auth
- Gestion des tokens et refresh tokens

### Données Personnelles
- Conformité RGPD
- Gestion du consentement
- Droit à l'oubli
- Export des données

### Règles de Sécurité
- Firestore : Vérification des propriétaires, règles par collection
- Storage : Validation des types, limitation de taille
- API : Rate limiting, validation des inputs

---

## 🧪 Tests

### Données de Test

L'application inclut un système de seeding pour les données de test :

- **Utilisateurs de test** : Candidats, recruteurs, admin
- **Posts de test** : Offres d'emploi variées
- **Matches de test** : Correspondances pré-configurées
- **Messages de test** : Conversations d'exemple

### Comptes de Test

**Candidat**
- Email: `candidat@example.com`
- Password: `password123`

**Recruteur**
- Email: `contact@techcorp.com`
- Password: `password123`

**Admin**
- Email: `admin@swipeem.com`
- Password: `password123`

---

## 📚 Documentation Complémentaire

---

## 🛠️ Système d'Administration

### Rôle Administrateur
- **Champ `isAdmin`** : Ajouté au modèle `UserModel` pour identifier les administrateurs
- **Vérification des droits** : Le service `AdminService` vérifie automatiquement les droits admin
- **Accès sécurisé** : Seuls les utilisateurs avec `isAdmin: true` peuvent accéder aux fonctionnalités admin

### Interface d'Administration

#### Tableau de Bord Admin (`AdminDashboardScreen`)
- **Statistiques en temps réel** : Nombre d'utilisateurs, posts, messages, matches
- **Actions rapides** : Accès direct aux différentes fonctionnalités admin
- **Informations utilisateur** : Affichage du profil admin connecté

#### Gestion des Posts (`AdminPostManagementScreen`)
- **Créer des posts** : Interface intuitive avec formulaire de création
- **Lister tous les posts** : Vue d'ensemble de tous les posts de la plateforme
- **Supprimer des posts** : Possibilité de supprimer des posts inappropriés
- **Tags et catégorisation** : Système de tags pour organiser les posts

#### Gestion des Messages (`AdminMessageManagementScreen`)
- **Créer des messages** : Permet de créer des messages entre n'importe quels utilisateurs
- **Sélection des utilisateurs** : Interface de sélection avec informations détaillées
- **Création automatique de matches** : Les matches sont créés automatiquement si nécessaire
- **Gestion des conversations** : Suivi des conversations entre utilisateurs

### Créer un Utilisateur Admin

#### Méthode 1 : Via le script
```bash
dart run lib/scripts/create_admin_test_data.dart
```

#### Méthode 2 : Manuellement dans Firestore
```json
{
  "uid": "admin_user",
  "email": "admin@swipeem.com",
  "firstName": "Admin",
  "lastName": "Swipeem",
  "isAdmin": true,
  "isRecruiter": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 🔥 Configuration Firebase

### Mode Démo Actuel

L'application fonctionne actuellement en **mode démo** avec des données simulées. Cela permet de tester l'interface utilisateur sans configuration Firebase.

### Configuration Firebase (Optionnel)

Pour utiliser les vraies fonctionnalités Firebase, suivez ces étapes :

#### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Créer un projet"
3. Suivez les instructions pour créer votre projet

#### 2. Configurer l'authentification

1. Dans la console Firebase, allez dans "Authentication"
2. Activez "Sign-in method"
3. Activez "Email/Password" et "Anonymous"

#### 3. Configurer Firestore

1. Dans la console Firebase, allez dans "Firestore Database"
2. Créez une base de données en mode "test"
3. Les règles de sécurité sont déjà configurées dans `firestore.rules`

#### 4. Ajouter les fichiers de configuration

**Android**
1. Téléchargez `google-services.json` depuis la console Firebase
2. Placez-le dans `android/app/google-services.json`

**iOS**
1. Téléchargez `GoogleService-Info.plist` depuis la console Firebase
2. Placez-le dans `ios/Runner/GoogleService-Info.plist`

### Structure des données

#### Collections Firestore
- **users** : Informations des utilisateurs
- **matches** : Correspondances entre candidats et recruteurs
- **messages** : Messages dans les conversations

---

## 💬 Système de Discussions

### Vue d'ensemble

Le système de discussions permet aux recruteurs et candidats de communiquer directement après avoir été matchés. Il comprend une interface de chat en temps réel, des notifications, et une gestion complète des messages.

### Fonctionnalités implémentées

- **Liste des discussions** : Affichage de toutes les conversations avec les derniers messages
- **Chat en temps réel** : Interface de conversation avec messages en temps réel
- **Badge de notifications** : Compteur de messages non lus dans la navigation
- **Marquage automatique** : Les messages sont marqués comme lus quand l'utilisateur ouvre une conversation
- **Interface moderne** : Bulles de messages avec avatars et indicateurs de statut
- **Données de test** : Génération automatique de conversations de test
- **Notifications push** : Support pour les notifications locales et push

### Services

#### FirebaseMessageService
- `sendMessage()` : Envoyer un message texte
- `sendImageMessage()` : Envoyer un message avec image
- `getMessagesStream()` : Stream des messages d'un match
- `markMatchMessagesAsRead()` : Marquer tous les messages comme lus
- `getUnreadCountStream()` : Stream du nombre de messages non lus

#### FirebaseMatchService
- `createMatch()` : Créer un nouveau match
- `getUserMatchesStream()` : Stream des matches d'un utilisateur
- `updateLastMessage()` : Mettre à jour les infos du dernier message
- `markAsRead()` : Marquer un match comme lu

---

## 📝 Guide de Création de Posts

### Pour les Administrateurs

**Chemin d'accès :**
1. Dashboard Admin → **"Gérer les Posts"** (carte violette avec icône article)
2. Cliquez sur le bouton **"Nouveau Post"** (en haut à droite)
3. Le formulaire s'ouvre dans une boîte de dialogue

**Champs disponibles dans le formulaire :**
- ✅ Titre
- ✅ Contenu
- ✅ Tags (séparés par des virgules)
- ✅ **Soft Skills personnalisés** (champ de texte)
- ✅ **Liste de sélection de Soft Skills** (chips cliquables)
- ✅ **Hard Skills personnalisés** (champ de texte)
- ✅ **Liste de sélection de Hard Skills** (chips cliquables)

### Pour les Utilisateurs (Recruteurs et Candidats)

**Chemin d'accès :**
1. Profil → Section **"CRÉER UN POST"** (carte avec image)
2. L'écran de création s'ouvre

**Route :** `/create-post`

### Listes de compétences disponibles

#### Soft Skills (20 compétences)
Communication, Travail en équipe, Leadership, Gestion du stress, Adaptabilité, Créativité, Empathie, Organisation, Autonomie, Esprit d'initiative, Résolution de problèmes, Négociation, Gestion du temps, Motivation, Persévérance, Confiance en soi, Curiosité, Pensée critique, Intelligence émotionnelle, Flexibilité

#### Hard Skills (36 compétences)
Flutter, Dart, React Native, JavaScript, TypeScript, Python, Java, Kotlin, Swift, Node.js, Firebase, Git, Docker, Kubernetes, AWS, Azure, GCP, SQL, MongoDB, PostgreSQL, REST API, GraphQL, CI/CD, Agile, Scrum, Gestion de projet, UI/UX Design, Figma, Photoshop, Illustrator, Machine Learning, Data Science, DevOps, Cybersécurité, Blockchain, Web3

---

## 📦 Configuration Firebase Storage

### Activation de Firebase Storage

#### Étape 1 : Activer Storage dans Firebase Console
1. Ouvrir : https://console.firebase.google.com/project/hire-me-28191/storage
2. Cliquer sur "Commencer" / "Get Started"
3. Choisir la localisation (recommandé: `europe-west1` pour l'Europe)
4. Cliquer sur "Terminer"

#### Étape 2 : Déployer les règles de sécurité
```bash
firebase deploy --only storage:rules
```

### Règles de sécurité (storage.rules)

Les règles actuelles permettent :
- ✅ **Lecture** : Tous les utilisateurs authentifiés peuvent voir les photos de profil
- ✅ **Écriture** : Un utilisateur peut uniquement modifier sa propre photo
- ✅ **Validation** : Limite de 5 MB, format image uniquement

### Structure du stockage

```
storage/
  └── users/
      └── {userId}/
          └── profile.jpg
```

Chaque utilisateur a son dossier avec sa photo de profil au format JPEG optimisé (512x512px max).

---

## 🧪 Données de Test

### Utilisation Rapide

#### Via l'interface utilisateur
Accédez à l'écran d'administration dans votre application :
```
/admin/test-data
```

#### Via les scripts de commande

**Créer toutes les données de test :**
```bash
dart run lib/scripts/create_test_data.dart
```

**Nettoyer les données de test :**
```bash
dart run lib/scripts/clean_test_data.dart
```

### Données Créées

- **Messages de Test** (20 messages) : Conversations réalistes entre candidats et recruteurs
- **Annonces d'Emploi** (10 offres) : Postes variés avec informations complètes
- **Posts/Annonces** (5 posts) : Annonces de recrutement et posts communautaires
- **Matches** (5 conversations) : Correspondances entre utilisateurs existants

### Comptes de Test

**Mot de passe universel** : `password123`

#### Compte Administrateur
- Email: `admin@swipeem.com`
- Password: `password123`

#### Comptes Candidats
- `marie.dupont@email.com` - Développeuse Flutter
- `pierre.martin@email.com` - Développeur Full-Stack
- `sophie.bernard@email.com` - UX/UI Designer
- `thomas.leroy@email.com` - DevOps Engineer
- `laura.simon@email.com` - Product Manager

#### Comptes Recruteurs
- `jean.recruteur@techcorp.com` - TechCorp France
- `sarah.hr@startup.io` - StartupIO

---

## 🔐 Configuration OAuth

### Configuration Google Sign-In pour Web

#### 1. Obtenir le Client ID Google OAuth
1. Allez dans [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Sign-in method**
4. Cliquez sur **Google** dans la liste des providers
5. Si Google n'est pas activé, activez-le
6. Dans la section **Web client ID**, copiez le Client ID

#### 2. Configurer le Client ID dans le code

**Option A: Via le tag meta dans index.html (Recommandé)**
1. Ouvrez `web/index.html`
2. Trouvez la ligne : `<meta name="google-signin-client_id" content="YOUR_GOOGLE_CLIENT_ID">`
3. Remplacez `YOUR_GOOGLE_CLIENT_ID` par votre vrai Client ID

**Option B: Via le code Dart (Alternative)**
1. Ouvrez `lib/services/auth_service.dart`
2. Trouvez la ligne avec `static final GoogleSignIn _googleSignIn`
3. Remplacez `null` par votre Client ID

### Configuration LinkedIn Login

#### 1. Créer une application LinkedIn
1. Allez sur [LinkedIn Developers](https://www.linkedin.com/developers/apps)
2. Cliquez sur "Create app"
3. Remplissez les informations de votre application
4. Notez votre **Client ID** et **Client Secret**

#### 2. Configurer les Redirect URLs
- Pour Android: `linkedin://linkedin`
- Pour iOS: `linkedin://linkedin`
- Pour Web: `https://your-app.com/linkedin/callback`

#### 3. Mettre à jour le code
Dans `lib/features/auth/login_screen.dart`, trouvez la classe `LinkedInButtonWrapper` et remplacez :
```dart
static const String linkedInClientId = 'YOUR_LINKEDIN_CLIENT_ID';
static const String linkedInClientSecret = 'YOUR_LINKEDIN_CLIENT_SECRET';
static const String linkedInRedirectUrl = 'YOUR_LINKEDIN_REDIRECT_URL';
```

**Important** : Ne commitez jamais vos credentials dans le code source ! Utilisez des variables d'environnement ou un fichier de configuration sécurisé.

---

## 📁 Stockage Local des Images de Profil

### Système de stockage

Les images de profil sont stockées **localement** dans le projet au lieu de Firebase Storage.

### Structure des dossiers

```
Application Documents Directory/
└── profile_images/
    ├── {userId1}/
    │   └── profile.jpg
    ├── {userId2}/
    │   └── profile.jpg
    └── {userId3}/
        └── profile.jpg
```

### Emplacement selon la plateforme

- **iOS** : `~/Documents/profile_images/`
- **Android** : `/data/data/com.example.hire_me/app_flutter/profile_images/`
- **Web** : Pas de stockage disque (les images sont enregistrées en data URI dans Firestore)

### Avantages

- ✅ Pas besoin de Firebase Storage activé
- ✅ Pas de coûts de stockage cloud
- ✅ Accès instantané aux images
- ✅ Fonctionne hors ligne sur mobile/desktop

### Limitations

- ❌ Les images ne sont pas synchronisées entre appareils (hors web)
- ❌ Les images sont perdues si l'app est désinstallée
- ❌ Pas de partage d'images entre utilisateurs sur différents appareils

---

## 🐛 Débogage - Photo de Profil

### Logs activés

J'ai ajouté des logs détaillés pour diagnostiquer le problème. Voici ce qu'il faut vérifier :

#### Après avoir uploadé une photo

Dans la console de debug, vous devriez voir cette séquence :
```
📤 uploadUserProfileImage - uid: {votre_uid}, isWeb: true/false
💾 Mise à jour Firestore - uid: {votre_uid}
✅ Photo de profil mise à jour dans Firestore
🖼️ resolveProfileImage appelé avec: data:image/jpeg;base64,...
✅ Data URI détectée
```

### Vérifications manuelles

#### Sur Web (Chrome DevTools)
1. **Ouvrez les DevTools** (F12)
2. **Onglet Console** : regardez les logs
3. **Onglet Application** > Firestore : Vérifiez que `profileImageUrl` contient une data URI

#### Dans Firebase Console
1. Allez sur https://console.firebase.google.com
2. **Firestore Database** > Collection `users`
3. **Trouvez votre document** et vérifiez le champ `profileImageUrl`

---

## 📜 Scripts Utilitaires

### Scripts de synchronisation Firebase

Ce dossier contient les scripts utilitaires pour synchroniser les données entre Firebase Authentication et Firestore.

#### Prérequis
1. **Node.js** (version 18 ou supérieure)
2. **Credentials Firebase Admin** : Fichier de service account ou `gcloud auth`

#### Installation
```bash
cd scripts
npm install
npm run build
```

#### Utilisation

**Mode DRY-RUN (simulation, recommandé en premier)**
```bash
npm run sync:users:dry
```

**Mode PRODUCTION (modifications réelles)**
```bash
npm run sync:users
```

### Configuration des credentials Firebase Admin

#### Étapes pour télécharger le fichier de service account

1. Accéder à la console Firebase : https://console.firebase.google.com/project/hire-me-28191/settings/serviceaccounts/adminsdk
2. Cliquer sur **"Générer une nouvelle clé privée"**
3. Télécharger le fichier JSON
4. Configurer la variable d'environnement :
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.firebase-credentials/votre-fichier.json"
```

**Important** : Ne commitez jamais ce fichier dans Git ! Ajoutez-le à `.gitignore`.

---

## ⚙️ Pages Settings

### Pages disponibles

1. **Account Security Screen** (`/settings/account-security`)
   - Gestion du profil, sécurité, gestion du compte

2. **Subscription Billing Screen** (`/settings/subscription-billing`)
   - Affichage de l'abonnement, plans disponibles, gestion de la facturation

3. **Notifications Screen** (`/settings/notifications`)
   - Types de notifications, contenu, heures silencieuses

4. **Language Region Screen** (`/settings/language-region`)
   - Sélection de la langue, région, fuseau horaire, formats

5. **Integration Screen** (`/settings/integration`)
   - Réseaux sociaux, productivité, développement, stockage cloud

6. **Appearance Accessibility Screen** (`/settings/appearance-accessibility`)
   - Thème, typographie, accessibilité

7. **Privacy GDPR Screen** (`/settings/privacy-gdpr`)
   - Collecte de données, permissions, droits RGPD

---

## 🚧 Roadmap & Améliorations Futures

### Fonctionnalités Prévues
- [ ] Système de recommandation IA
- [ ] Vidéo de présentation candidat
- [ ] Tests techniques intégrés
- [ ] Intégration calendrier externe (Google Calendar, Outlook)
- [ ] Mode hors-ligne amélioré
- [ ] Multi-langues (i18n)
- [ ] Analytics avancés pour recruteurs
- [ ] Système de notation et avis

### Améliorations Techniques
- [ ] Tests unitaires et d'intégration
- [ ] CI/CD automatisé
- [ ] Performance monitoring
- [ ] A/B testing
- [ ] Cache distribué
- [ ] CDN pour les assets

---

## 📄 Licence

Ce projet est propriétaire. Tous droits réservés.

---

## 👥 Contribution

Pour contribuer au projet, veuillez :
1. Créer une branche depuis `main`
2. Développer la fonctionnalité
3. Créer une pull request avec une description détaillée
4. S'assurer que tous les tests passent

---

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur le repository
- Contacter l'équipe de développement

---

**Dernière mise à jour** : 2024
