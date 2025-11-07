# 🔐 Identifiants de Test - Hire Me

## Mot de passe universel
**Tous les comptes utilisent le mot de passe : `password123`**

## 👑 Compte Administrateur

| Email | Mot de passe | Rôle |
|-------|--------------|------|
| `admin@hireme.com` | `password123` | Administrateur + Recruteur |

## 👥 Comptes Candidats

| Email | Mot de passe | Nom | Poste |
|-------|--------------|-----|-------|
| `marie.dupont@email.com` | `password123` | Marie Dupont | Développeuse Flutter |
| `pierre.martin@email.com` | `password123` | Pierre Martin | Développeur Full-Stack |
| `sophie.bernard@email.com` | `password123` | Sophie Bernard | UX/UI Designer |
| `thomas.leroy@email.com` | `password123` | Thomas Leroy | DevOps Engineer |
| `laura.simon@email.com` | `password123` | Laura Simon | Product Manager |

## 🏢 Comptes Recruteurs

| Email | Mot de passe | Nom | Entreprise |
|-------|--------------|-----|------------|
| `jean.recruteur@techcorp.com` | `password123` | Jean Recruteur | TechCorp France |
| `sarah.hr@startup.io` | `password123` | Sarah Johnson | StartupIO |

## 🚀 Comment créer ces comptes

### Méthode 1 : Via l'interface d'administration
1. Lancez votre application Flutter
2. Allez dans `/admin/test-data`
3. Cliquez sur **"Créer données avec Admin"**
4. Les comptes seront créés automatiquement dans Firebase Auth ET Firestore

### Méthode 2 : Via le code
```dart
import 'package:hire_me/services/admin_test_data_service.dart';

// Créer tous les comptes avec identifiants
await AdminTestDataService.createAllAdminTestData();
```

## 📱 Comment se connecter

1. **Ouvrez votre application Hire Me**
2. **Allez sur l'écran de connexion**
3. **Utilisez n'importe quel email** de la liste ci-dessus
4. **Entrez le mot de passe** : `password123`
5. **Vous serez connecté** avec le profil correspondant

## 🎯 Recommandations de test

### Pour tester le système de discussions :
1. **Connectez-vous en tant qu'admin** : `admin@hireme.com`
2. **Allez dans l'onglet Messages**
3. **Vous verrez les conversations** avec les candidats
4. **Testez l'envoi de messages** en temps réel

### Pour tester différents profils :
- **Admin** : Accès complet + fonctionnalités de recruteur
- **Candidat** : Interface candidat + discussions avec recruteurs
- **Recruteur** : Interface recruteur + discussions avec candidats

## 🔧 Dépannage

### Si les comptes ne se créent pas :
1. Vérifiez la connexion Firebase
2. Vérifiez les permissions Firebase Auth
3. Regardez les logs dans la console

### Si vous ne pouvez pas vous connecter :
1. Vérifiez que le compte existe dans Firebase Auth
2. Vérifiez l'orthographe de l'email
3. Utilisez exactement le mot de passe : `password123`

## 📊 Données créées

Quand vous utilisez "Créer données avec Admin", cela génère :
- ✅ **8 comptes utilisateurs** (1 admin + 5 candidats + 2 recruteurs)
- ✅ **5 conversations** entre différents utilisateurs
- ✅ **Messages variés** dans chaque conversation
- ✅ **7 posts** créés par l'admin
- ✅ **Matches** entre recruteurs et candidats

## 🔄 Réinitialisation

Pour supprimer tous les comptes et recommencer :
1. Allez dans `/admin/test-data`
2. Cliquez sur **"Nettoyer"**
3. Puis **"Créer données avec Admin"** pour recréer

---

**Note :** Ces comptes sont uniquement pour les tests. Ne les utilisez pas en production !
