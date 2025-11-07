RR# Système de Discussions - Hire Me

## Vue d'ensemble

Le système de discussions permet aux recruteurs et candidats de communiquer directement après avoir été matchés. Il comprend une interface de chat en temps réel, des notifications, et une gestion complète des messages.

## Fonctionnalités

### ✅ Fonctionnalités implémentées

- **Liste des discussions** : Affichage de toutes les conversations avec les derniers messages
- **Chat en temps réel** : Interface de conversation avec messages en temps réel
- **Badge de notifications** : Compteur de messages non lus dans la navigation
- **Marquage automatique** : Les messages sont marqués comme lus quand l'utilisateur ouvre une conversation
- **Interface moderne** : Bulles de messages avec avatars et indicateurs de statut
- **Données de test** : Génération automatique de conversations de test
- **Notifications push** : Support pour les notifications locales et push

### 🔄 Fonctionnalités en cours

- **Envoi d'images** : Interface préparée pour l'envoi de photos (nécessite image_picker)
- **Recherche de messages** : Fonctionnalité de recherche dans les conversations
- **Messages système** : Support pour les messages automatiques

## Architecture

### Modèles de données

#### MessageModel
```dart
class MessageModel {
  final String id;
  final String matchId;
  final String senderUid;
  final String receiverUid;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
}
```

#### MatchModel
```dart
class MatchModel {
  final String id;
  final String candidateUid;
  final String recruiterUid;
  final DateTime matchedAt;
  final DateTime? lastMessageAt;
  final String? lastMessageContent;
  final String? lastMessageSenderUid;
  final bool isActive;
  final Map<String, bool> readBy;
}
```

### Services

#### FirebaseMessageService
- `sendMessage()` : Envoyer un message texte
- `sendImageMessage()` : Envoyer un message avec image
- `getMessagesStream()` : Stream des messages d'un match
- `markMatchMessagesAsRead()` : Marquer tous les messages comme lus
- `getUnreadCountStream()` : Stream du nombre de messages non lus
- `getMessageStats()` : Statistiques des messages

#### FirebaseMatchService
- `createMatch()` : Créer un nouveau match
- `getUserMatchesStream()` : Stream des matches d'un utilisateur
- `updateLastMessage()` : Mettre à jour les infos du dernier message
- `markAsRead()` : Marquer un match comme lu

### Providers (Riverpod)

#### message_provider.dart
- `userMatchesProvider` : Stream des matches de l'utilisateur
- `matchMessagesProvider` : Stream des messages d'un match spécifique
- `unreadMessageCountProvider` : Stream du nombre de messages non lus

### Écrans

#### MessagesScreen
- Liste de toutes les conversations
- Affichage du dernier message et de l'heure
- Indicateurs de messages non lus
- Navigation vers les conversations individuelles

#### ChatRoomScreen
- Interface de chat en temps réel
- Bulles de messages avec avatars
- Champ de saisie avec bouton d'envoi
- Bouton pour envoyer des images (préparé)
- Marquage automatique des messages comme lus
- Scroll automatique vers les nouveaux messages

## Utilisation

### 1. Créer des données de test

Accédez à l'écran d'administration (`/admin/test-data`) et cliquez sur "Créer toutes les données" pour générer :
- Des matches entre recruteurs et candidats
- Des conversations avec messages variés
- Des annonces d'emploi et posts

### 2. Navigation

- **Onglet Messages** : Accès à la liste des conversations
- **Badge rouge** : Indique le nombre de messages non lus
- **Tap sur une conversation** : Ouvre le chat en temps réel

### 3. Chat

- **Saisie de message** : Tapez dans le champ et appuyez sur Entrée ou le bouton Envoi
- **Bouton image** : Prépare l'envoi d'images (nécessite configuration image_picker)
- **Messages en temps réel** : Les nouveaux messages apparaissent automatiquement
- **Marquage automatique** : Les messages sont marqués comme lus à l'ouverture

## Configuration

### Notifications

Le service de notifications est déjà configuré dans `NotificationService` :
- Notifications locales pour les messages reçus
- Support des notifications push Firebase
- Gestion des permissions

### Base de données Firestore

Collections utilisées :
- `messages` : Tous les messages
- `matches` : Les matches entre utilisateurs
- `users` : Informations des utilisateurs

## Extensions possibles

### Fonctionnalités avancées
- **Réactions** : Emojis sur les messages
- **Messages vocaux** : Enregistrement et envoi de notes vocales
- **Partage de fichiers** : Documents, PDF, etc.
- **Messages temporaires** : Auto-destruction après lecture
- **Typing indicators** : Indicateur "en train d'écrire"
- **Messages groupés** : Conversations à plusieurs

### Améliorations UX
- **Thèmes** : Mode sombre/clair pour les conversations
- **Personnalisation** : Couleurs des bulles de messages
- **Raccourcis** : Actions rapides sur les messages
- **Historique** : Recherche dans les anciens messages

## Dépannage

### Problèmes courants

1. **Messages non visibles** : Vérifiez que les utilisateurs sont bien matchés
2. **Notifications manquantes** : Vérifiez les permissions de notification
3. **Erreurs de chargement** : Vérifiez la connexion Firebase

### Logs utiles

Les services incluent des logs détaillés pour le débogage :
- Création/suppression de messages
- Erreurs de connexion Firebase
- Statuts de lecture des messages

## Support

Pour toute question ou problème avec le système de discussions, consultez :
- Les logs de la console
- La documentation Firebase
- Les tests dans `test_data_service.dart`
