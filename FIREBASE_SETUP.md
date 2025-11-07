# Configuration Firebase

## Mode Démo Actuel

L'application fonctionne actuellement en **mode démo** avec des données simulées. Cela permet de tester l'interface utilisateur sans configuration Firebase.

## Configuration Firebase (Optionnel)

Pour utiliser les vraies fonctionnalités Firebase, suivez ces étapes :

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Créer un projet"
3. Suivez les instructions pour créer votre projet

### 2. Configurer l'authentification

1. Dans la console Firebase, allez dans "Authentication"
2. Activez "Sign-in method"
3. Activez "Email/Password" et "Anonymous"

### 3. Configurer Firestore

1. Dans la console Firebase, allez dans "Firestore Database"
2. Créez une base de données en mode "test"
3. Les règles de sécurité sont déjà configurées dans `firestore.rules`

### 4. Ajouter les fichiers de configuration

#### Android
1. Téléchargez `google-services.json` depuis la console Firebase
2. Placez-le dans `android/app/google-services.json`

#### iOS
1. Téléchargez `GoogleService-Info.plist` depuis la console Firebase
2. Placez-le dans `ios/Runner/GoogleService-Info.plist`

### 5. Activer le mode Firebase

Une fois Firebase configuré, modifiez le fichier `lib/providers/demo_provider.dart` :

```dart
final isDemoModeProvider = Provider<bool>((ref) {
  // Changez ceci à false pour utiliser Firebase
  return false; // Au lieu de true
});
```

## Structure des données

### Collections Firestore

- **users** : Informations des utilisateurs
- **matches** : Correspondances entre candidats et recruteurs
- **messages** : Messages dans les conversations

### Modèles de données

- `UserModel` : Utilisateur (candidat ou recruteur)
- `MatchModel` : Correspondance entre deux utilisateurs
- `MessageModel` : Message dans une conversation

## Fonctionnalités disponibles

### Mode Démo
- ✅ Interface utilisateur complète
- ✅ Navigation entre écrans
- ✅ Données simulées
- ✅ Envoi de messages (simulé)
- ✅ Authentification (simulée)

### Mode Firebase
- ✅ Authentification réelle
- ✅ Base de données Firestore
- ✅ Messages en temps réel
- ✅ Notifications push
- ✅ Gestion des utilisateurs

## Dépannage

### Erreur "Firebase has not been correctly initialized"
- Vérifiez que les fichiers de configuration sont présents
- Vérifiez que Firebase est correctement configuré dans votre projet

### L'app ne se lance pas
- L'app fonctionne en mode démo par défaut
- Vérifiez les logs pour plus d'informations

## Support

Pour toute question sur la configuration Firebase, consultez la [documentation officielle](https://firebase.google.com/docs/flutter/setup).
