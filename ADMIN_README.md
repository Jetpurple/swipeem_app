# Système d'Administration - HireMe

Ce document explique comment utiliser le système d'administration de la plateforme HireMe.

## 🚀 Fonctionnalités Admin

### 1. Rôle Administrateur
- **Champ `isAdmin`** : Ajouté au modèle `UserModel` pour identifier les administrateurs
- **Vérification des droits** : Le service `AdminService` vérifie automatiquement les droits admin
- **Accès sécurisé** : Seuls les utilisateurs avec `isAdmin: true` peuvent accéder aux fonctionnalités admin

### 2. Interface d'Administration

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

### 3. Données de Test

#### Script de Création (`create_admin_test_data.dart`)
```bash
# Exécuter le script de création de données avec admin
dart run lib/scripts/create_admin_test_data.dart
```

#### Données Créées
- **Utilisateur admin** : `admin@hireme.com` avec tous les droits
- **Utilisateurs de test** : 5 candidats + 3 recruteurs + 1 admin
- **Posts variés** : 7+ posts avec différents tags et contenus
- **Messages de test** : Conversations entre différents utilisateurs
- **Matches automatiques** : Création de matches pour les conversations

## 🔧 Utilisation

### 1. Créer un Utilisateur Admin

#### Méthode 1 : Via le script
```bash
dart run lib/scripts/create_admin_test_data.dart
```

#### Méthode 2 : Manuellement dans Firestore
```json
{
  "uid": "admin_user",
  "email": "admin@hireme.com",
  "firstName": "Admin",
  "lastName": "HireMe",
  "isAdmin": true,
  "isRecruiter": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 2. Accéder à l'Interface Admin

1. **Se connecter** avec un compte admin
2. **Naviguer** vers l'écran de test des données
3. **Cliquer** sur "Tableau de Bord Admin"
4. **Explorer** les différentes fonctionnalités

### 3. Créer des Posts Admin

1. **Accéder** à "Gérer les Posts"
2. **Cliquer** sur "Nouveau Post"
3. **Remplir** le formulaire :
   - Titre du post
   - Contenu détaillé
   - Tags (séparés par des virgules)
4. **Valider** la création

### 4. Créer des Messages Admin

1. **Accéder** à "Gérer les Messages"
2. **Cliquer** sur "Nouveau Message"
3. **Sélectionner** l'expéditeur et le destinataire
4. **Rédiger** le contenu du message
5. **Valider** la création

## 📁 Structure des Fichiers

```
lib/
├── features/admin/
│   ├── admin_dashboard_screen.dart          # Tableau de bord principal
│   ├── admin_post_management_screen.dart    # Gestion des posts
│   ├── admin_message_management_screen.dart # Gestion des messages
│   └── test_data_screen.dart               # Interface de test
├── services/
│   ├── admin_service.dart                   # Service principal admin
│   └── admin_test_data_service.dart         # Service de données de test
├── models/
│   └── user_model.dart                      # Modèle utilisateur (avec isAdmin)
└── scripts/
    └── create_admin_test_data.dart          # Script de création de données
```

## 🔒 Sécurité

### Vérifications de Sécurité
- **Authentification requise** : L'utilisateur doit être connecté
- **Vérification des droits** : Contrôle du champ `isAdmin` à chaque action
- **Validation des données** : Vérification de l'existence des utilisateurs
- **Gestion des erreurs** : Messages d'erreur appropriés pour les accès refusés

### Bonnes Pratiques
- **Ne jamais exposer** les fonctionnalités admin dans l'interface utilisateur normale
- **Vérifier les droits** avant chaque action admin
- **Logger les actions** admin pour audit
- **Limiter l'accès** aux comptes admin

## 🚨 Notes Importantes

1. **Données de Test** : Les scripts créent des données de test, ne pas utiliser en production
2. **Sécurité** : Toujours vérifier les droits admin avant d'exposer les fonctionnalités
3. **Performance** : Les requêtes admin peuvent être coûteuses, utiliser la pagination
4. **Backup** : Sauvegarder les données avant d'utiliser les fonctions de suppression

## 🎯 Prochaines Étapes

- [ ] Ajouter la gestion des utilisateurs (modification, suppression)
- [ ] Implémenter les statistiques avancées
- [ ] Créer un système de logs des actions admin
- [ ] Ajouter la gestion des rôles et permissions
- [ ] Implémenter la modération de contenu
- [ ] Créer des rapports d'activité

## 📞 Support

Pour toute question concernant le système d'administration :
1. Vérifier les logs de l'application
2. Consulter la documentation Firebase
3. Tester avec les données de test fournies
4. Vérifier la configuration des règles Firestore
