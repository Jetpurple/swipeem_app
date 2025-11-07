# 📊 Données de Test - Hire Me

Ce guide vous explique comment créer et gérer des données de test pour votre application Hire Me.

## 🚀 Utilisation Rapide

### ⚠️ Prérequis Important
**Assurez-vous d'avoir un utilisateur avec l'UID `recruiter_1` dans votre base de données !**

### 1. Via l'interface utilisateur
Accédez à l'écran d'administration dans votre application :
```
/admin/test-data
```

### 2. Via les scripts de commande

#### Créer toutes les données de test :
```bash
dart run lib/scripts/create_test_data.dart
```

#### Nettoyer les données de test :
```bash
dart run lib/scripts/clean_test_data.dart
```

### 3. Configuration pour recruiter_1
Le service utilise automatiquement l'UID `recruiter_1` pour :
- ✅ Créer toutes les annonces d'emploi
- ✅ Créer tous les posts/annonces
- ✅ Créer des conversations avec les candidats

## 📋 Données Créées

### 💬 Messages de Test (20 messages)
- Conversations réalistes entre candidats et recruteurs
- Messages variés : salutations, questions techniques, négociations
- Statuts de lecture simulés (certains lus, d'autres non)
- Horodatage progressif pour simuler une conversation

### 💼 Annonces d'Emploi (10 offres)
- Postes variés : Développeur Flutter, React Native, DevOps, etc.
- Informations complètes : salaire, localisation, avantages
- Entreprises fictives réalistes
- Exigences et compétences détaillées

### 📝 Posts/Annonces (5 posts)
- Annonces de recrutement
- Posts communautaires
- Tags et catégories
- Contenu varié et réaliste

### 🤝 Matches (5 conversations)
- Correspondances entre utilisateurs existants
- Conversations actives avec historique
- Statuts de lecture simulés

## 🛠️ Configuration Requise

### Prérequis
1. **Utilisateur recruiter_1** : Un utilisateur avec l'UID `recruiter_1` et `isRecruiter: true`
2. **Candidats** : Au moins quelques utilisateurs avec `isRecruiter: false`
3. **Firebase configuré** : Connexion Firestore active
4. **Règles Firestore** : Permissions d'écriture/lecture

### Structure des Collections

#### Messages
```json
{
  "matchId": "string",
  "senderUid": "string", 
  "receiverUid": "string",
  "content": "string",
  "type": "text",
  "sentAt": "timestamp",
  "isRead": "boolean",
  "readAt": "timestamp"
}
```

#### Annonces d'Emploi
```json
{
  "title": "string",
  "company": "string",
  "location": "string",
  "type": "CDI",
  "salary": "string",
  "experience": "string",
  "description": "string",
  "requirements": ["array"],
  "benefits": ["array"],
  "postedBy": "string",
  "isActive": "boolean"
}
```

#### Posts
```json
{
  "title": "string",
  "content": "string",
  "authorUid": "string",
  "tags": ["array"],
  "createdAt": "timestamp",
  "isActive": "boolean"
}
```

## 🎯 Cas d'Usage

### Test de l'Application
1. **Messages** : Testez les conversations, notifications, statuts de lecture
2. **Annonces** : Testez la recherche d'emploi, filtres, candidatures
3. **Posts** : Testez le feed communautaire, interactions
4. **Matches** : Testez le système de correspondance

### Développement
- **Données réalistes** pour tester l'interface utilisateur
- **Scénarios variés** pour valider les fonctionnalités
- **Performance** : Testez avec un volume de données réaliste

## 🔧 Personnalisation

### Modifier les Messages
Éditez le fichier `lib/services/test_data_service.dart` :
```dart
static final List<Map<String, dynamic>> _testMessages = [
  {
    'content': 'Votre message personnalisé',
    'type': 'text',
  },
  // Ajoutez vos messages...
];
```

### Modifier les Annonces
```dart
static final List<Map<String, dynamic>> _testJobOffers = [
  {
    'title': 'Votre poste',
    'company': 'Votre entreprise',
    'location': 'Votre ville',
    // ... autres champs
  },
  // Ajoutez vos annonces...
];
```

## 🧹 Nettoyage

### Suppression Sélective
```dart
// Supprimer seulement les messages
await TestDataService.cleanTestData();

// Ou supprimer via l'interface
// Accédez à /admin/test-data et cliquez sur "Nettoyer"
```

### Suppression Manuelle
Si vous préférez supprimer manuellement :
1. Ouvrez la console Firebase
2. Allez dans Firestore Database
3. Supprimez les collections : `messages`, `matches`, `jobOffers`, `posts`

## 🚨 Précautions

### ⚠️ Environnement de Production
- **NE JAMAIS** utiliser ces scripts en production
- **Toujours** vérifier l'environnement avant d'exécuter
- **Sauvegarder** vos données importantes

### 🔒 Sécurité
- Les scripts créent des données fictives
- Aucune donnée sensible n'est incluse
- Tous les UIDs sont générés automatiquement

## 📞 Support

Si vous rencontrez des problèmes :

1. **Vérifiez les logs** dans la console
2. **Assurez-vous** d'avoir des utilisateurs dans la base
3. **Vérifiez** les règles Firestore
4. **Consultez** la documentation Firebase

## 🎉 Résultat

Après l'exécution, vous aurez :
- ✅ Des conversations réalistes à tester
- ✅ Des annonces d'emploi variées
- ✅ Un environnement de test complet
- ✅ Des données pour valider toutes les fonctionnalités

**Bon développement ! 🚀**
