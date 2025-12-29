import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linkedin_login/linkedin_login.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Google Sign-In configuration
  // For web: Client ID should be set in web/index.html as a meta tag
  // OR you can set it here by replacing null with your Client ID:
  // To get your Client ID: Firebase Console > Authentication > Sign-in method > Google > Web client ID
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // TODO: Replace with your actual Google OAuth Web Client ID from Firebase Console
    // Format: xxxxx-xxxxx.apps.googleusercontent.com
    // If you set it in web/index.html, you can leave this as null
    clientId: kIsWeb ? null : null, // Set your Client ID here: 'YOUR_CLIENT_ID.apps.googleusercontent.com'
  );
  
  static const String _usersCollection = 'users';

  /// Crée un compte utilisateur dans Firebase Auth et le document Firestore correspondant
  /// 
  /// [email] - Email de l'utilisateur
  /// [password] - Mot de passe (minimum 6 caractères)
  /// [firstName] - Prénom de l'utilisateur
  /// [lastName] - Nom de famille de l'utilisateur
  /// [role] - Rôle de l'utilisateur (ex: 'candidate', 'recruiter')
  /// 
  /// Retourne l'UID de l'utilisateur créé
  /// 
  /// Lance une exception en cas d'erreur
  static Future<String> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      print('🔄 Création du compte utilisateur pour: $email');
      
      // 1. Créer le compte dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Erreur: Utilisateur non créé dans Firebase Auth');
      }
      
      print("✅ Compte Firebase Auth créé avec l'UID: ${user.uid}");
      
      // 2. Créer le document Firestore avec l'email comme ID
      final userData = {
        'uid': user.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'name': '$firstName $lastName',
        'role': role,
        'isRecruiter': role == 'recruiter',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection(_usersCollection)
          .doc(email) // Utiliser l'email comme ID du document
          .set(userData);
      
      print("✅ Document Firestore créé pour l'utilisateur: ${user.uid}");
      
      return user.uid;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Firebase Auth: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          throw Exception('Le mot de passe est trop faible');
        case 'email-already-in-use':
          throw Exception('Un compte existe déjà avec cet email');
        case 'invalid-email':
          throw Exception("Format d'email invalide");
        default:
          throw Exception("Erreur d'authentification: ${e.message}");
      }
    } on FirebaseException catch (e) {
      print('❌ Erreur Firestore: ${e.code} - ${e.message}');
      throw Exception('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Récupère les données de l'utilisateur connecté depuis Firestore
  /// 
  /// Retourne un Map contenant les données utilisateur ou null si non connecté
  /// 
  /// Lance une exception en cas d'erreur
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('⚠️ Aucun utilisateur connecté');
        return null;
      }
      
      print("🔄 Récupération des données pour l'utilisateur: ${currentUser.uid}");
      
      final DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .get();
      
      if (!doc.exists) {
        print("❌ Document utilisateur non trouvé pour l'UID: ${currentUser.uid}");
        return null;
      }
      
      final userData = doc.data()! as Map<String, dynamic>;
      print('✅ Données utilisateur récupérées: ${userData.keys.join(', ')}');
      
      return userData;
      
    } on FirebaseException catch (e) {
      print('❌ Erreur Firestore: ${e.code} - ${e.message}');
      throw Exception('Erreur de lecture des données: ${e.message}');
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Met à jour les données de l'utilisateur connecté dans Firestore
  /// 
  /// [newData] - Map contenant les champs à mettre à jour
  /// 
  /// Lance une exception en cas d'erreur
  static Future<void> updateUserData(Map<String, dynamic> newData) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }
      
      print("🔄 Mise à jour des données pour l'utilisateur: ${currentUser.uid}");
      print('📝 Données à mettre à jour: ${newData.keys.join(', ')}');
      
      // Ajouter le timestamp de mise à jour
      final dataToUpdate = {
        ...newData,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Vérifier si le document existe (utiliser l'email comme ID)
      final userEmail = currentUser.email;
      if (userEmail == null) {
        throw Exception('Email utilisateur non disponible');
      }
      
      final docRef = _firestore.collection(_usersCollection).doc(userEmail);
      final docSnapshot = await docRef.get();
      
      // Si le document n'existe pas avec l'email, vérifier avec l'UID (migration)
      if (!docSnapshot.exists) {
        final docRefByUid = _firestore.collection(_usersCollection).doc(currentUser.uid);
        final docSnapshotByUid = await docRefByUid.get();
        
        if (docSnapshotByUid.exists) {
          print('🔄 Migration automatique lors de la mise à jour...');
          
          // Récupérer les données existantes
          final existingData = docSnapshotByUid.data()!;
          
          // Créer le nouveau document avec l'email comme ID
          final migratedData = {
            ...existingData,
            ...dataToUpdate, // Inclure les nouvelles données
            'email': userEmail,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          
          await docRef.set(migratedData);
          await docRefByUid.delete(); // Supprimer l'ancien document
          
          print('✅ Document utilisateur migré et mis à jour avec succès');
          return;
        }
      }
      
      if (docSnapshot.exists) {
        // Le document existe, faire une mise à jour
        await docRef.update(dataToUpdate);
        print('✅ Données utilisateur mises à jour avec succès');
      } else {
        // Le document n'existe pas, le créer avec les données de base
        print('⚠️ Document utilisateur non trouvé, création en cours...');
        
        final userData = {
          'uid': currentUser.uid,
          'email': userEmail,
          'firstName': newData['firstName'] ?? 'Utilisateur',
          'lastName': newData['lastName'] ?? 'Anonyme',
          'name': newData['name'] ?? 'Utilisateur Anonyme',
          'role': 'candidate', // Rôle par défaut
          'isRecruiter': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          ...dataToUpdate, // Inclure les nouvelles données
        };
        
        await docRef.set(userData);
        print('✅ Document utilisateur créé avec succès');
      }
      
    } on FirebaseException catch (e) {
      print('❌ Erreur Firestore: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'permission-denied':
          throw Exception('Permission refusée pour la mise à jour');
        default:
          throw Exception('Erreur de mise à jour: ${e.message}');
      }
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Connexion avec email et mot de passe
  /// 
  /// [email] - Email de l'utilisateur
  /// [password] - Mot de passe
  /// 
  /// Lance une exception en cas d'erreur
  static Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print("🔄 Connexion de l'utilisateur: $email");
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        print("✅ Connexion réussie pour l'utilisateur: ${user.uid}");
      }
      
      return user;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur de connexion: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Aucun utilisateur trouvé avec cet email');
        case 'wrong-password':
          throw Exception('Mot de passe incorrect');
        case 'invalid-email':
          throw Exception("Format d'email invalide");
        case 'user-disabled':
          throw Exception('Ce compte a été désactivé');
        default:
          throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Connexion anonyme (pour les tests)
  /// 
  /// Lance une exception en cas d'erreur
  static Future<User?> signInAnonymously() async {
    try {
      print('🔄 Connexion anonyme');
      
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      
      if (user != null) {
        print('✅ Connexion anonyme réussie: ${user.uid}');
      }
      
      return user;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur de connexion anonyme: ${e.code} - ${e.message}');
      throw Exception('Erreur de connexion anonyme: ${e.message}');
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Déconnexion de l'utilisateur
  /// 
  /// Lance une exception en cas d'erreur
  static Future<void> signOut() async {
    try {
      print("🔄 Déconnexion de l'utilisateur");
      await _auth.signOut();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur de déconnexion: $e');
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  /// Stream de l'état d'authentification
  /// 
  /// Retourne un Stream qui émet l'utilisateur actuel ou null
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Utilisateur actuellement connecté
  /// 
  /// Retourne l'utilisateur connecté ou null
  static User? get currentUser => _auth.currentUser;

  /// Vérifie si un utilisateur est connecté
  /// 
  /// Retourne true si un utilisateur est connecté, false sinon
  static bool get isSignedIn => _auth.currentUser != null;

  /// S'assure que le document Firestore de l'utilisateur connecté existe
  /// 
  /// Crée le document s'il n'existe pas
  static Future<void> ensureUserDocumentExists() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      final userEmail = currentUser.email;
      if (userEmail == null) {
        print('⚠️ Email utilisateur non disponible, impossible de créer le document');
        return;
      }
      
      // Vérifier si le document existe avec l'email comme ID
      final docRefByEmail = _firestore.collection(_usersCollection).doc(userEmail);
      final docSnapshotByEmail = await docRefByEmail.get();
      
      if (docSnapshotByEmail.exists) {
        print("✅ Document utilisateur trouvé avec l'email comme ID");
        return;
      }
      
      // Vérifier si le document existe avec l'UID comme ID (ancienne structure)
      final docRefByUid = _firestore.collection(_usersCollection).doc(currentUser.uid);
      final docSnapshotByUid = await docRefByUid.get();
      
      if (docSnapshotByUid.exists) {
        print("🔄 Migration du document utilisateur de l'UID vers l'email...");
        
        // Récupérer les données existantes
        final existingData = docSnapshotByUid.data()!;
        
        // Créer le nouveau document avec l'email comme ID
        final migratedData = {
          ...existingData,
          'email': userEmail, // S'assurer que l'email est correct
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        await docRefByEmail.set(migratedData);
        
        // Supprimer l'ancien document
        await docRefByUid.delete();
        
        print('✅ Document utilisateur migré avec succès');
        return;
      }
      
      // Aucun document trouvé, créer un nouveau
      print('🔄 Création du document utilisateur manquant...');
      
      final userData = {
        'uid': currentUser.uid,
        'email': userEmail,
        'firstName': 'Utilisateur',
        'lastName': 'Anonyme',
        'name': 'Utilisateur Anonyme',
        'role': 'candidate',
        'isRecruiter': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await docRefByEmail.set(userData);
      print('✅ Document utilisateur créé automatiquement');
      
    } catch (e) {
      print('❌ Erreur lors de la vérification du document utilisateur: $e');
    }
  }

  /// Connexion avec Google
  /// 
  /// Lance une exception en cas d'erreur
  static Future<User?> signInWithGoogle() async {
    try {
      print('🔄 Connexion avec Google');
      
      // Déclencher le flux de connexion Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("⚠️ Connexion Google annulée par l'utilisateur");
        return null;
      }
      
      // Obtenir les détails d'authentification
      final googleAuth = await googleUser.authentication;
      
      // Créer un nouveau credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Se connecter avec Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        print('✅ Connexion Google réussie: ${user.uid}');
        
        // Vérifier si l'utilisateur existe déjà dans Firestore (utiliser l'email comme ID)
        final userEmail = user.email;
        if (userEmail == null) {
          throw Exception('Email Google non disponible');
        }
        
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userEmail)
            .get();
        
        // Si l'utilisateur n'existe pas, créer le document avec les informations Google
        if (!userDoc.exists) {
          // Extraire le prénom et nom depuis displayName
          final displayName = user.displayName ?? googleUser.displayName ?? 'Utilisateur Google';
          final nameParts = displayName.trim().split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : 'Utilisateur';
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Google';
          
          // Récupérer la photo de profil si disponible
          final photoUrl = user.photoURL ?? googleUser.photoUrl;
          
          // Créer le document utilisateur avec toutes les informations disponibles
          final userData = {
            'uid': user.uid,
            'email': userEmail,
            'firstName': firstName,
            'lastName': lastName,
            'name': displayName,
            'photoUrl': photoUrl, // Photo de profil Google
            'role': 'candidate', // Rôle par défaut
            'isRecruiter': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          
          await _firestore
              .collection(_usersCollection)
              .doc(userEmail)
              .set(userData);
          
          print("✅ Document Firestore créé pour l'utilisateur Google: ${user.uid}");
          print("   - Nom: $displayName");
          print("   - Email: $userEmail");
          if (photoUrl != null) {
            print("   - Photo: $photoUrl");
          }
        } else {
          print("ℹ️ Utilisateur existe déjà dans Firestore: ${user.uid}");
        }
      }
      
      return user;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Firebase Auth Google: ${e.code} - ${e.message}');
      throw Exception('Erreur de connexion Google: ${e.message}');
    } catch (e) {
      print('❌ Erreur de connexion Google: $e');
      throw Exception('Erreur de connexion Google: $e');
    }
  }

  /// Connexion avec LinkedIn
  /// 
  /// Lance une exception en cas d'erreur
  /// Note: Utilise le package linkedin_login
  /// Nécessite la configuration des credentials LinkedIn dans Firebase Console
  static Future<User?> signInWithLinkedIn() async {
    try {
      print('🔄 Connexion avec LinkedIn');
      
      if (kIsWeb) {
        // Pour web, LinkedIn n'est pas encore supporté par linkedin_login
        // Utilisez un provider OAuth personnalisé dans Firebase Console
        throw UnimplementedError(
          'Connexion LinkedIn sur web: LinkedIn n\'est pas encore supporté sur web.\n'
          'Configurez LinkedIn comme provider OAuth dans Firebase Console.'
        );
      }
      
      // Pour mobile, utiliser linkedin_login
      // Note: Cette implémentation nécessite un widget LinkedInLoginButton
      // qui doit être utilisé dans l'UI. Cette méthode retourne null
      // et la connexion doit être gérée via le callback du widget.
      
      throw UnimplementedError(
        'Connexion LinkedIn: Utilisez le widget LinkedInLoginButton dans votre UI.\n'
        'Exemple:\n'
        'LinkedInLoginButton(\n'
        '  redirectUrl: "YOUR_REDIRECT_URL",\n'
        '  clientId: "YOUR_CLIENT_ID",\n'
        '  projection: ["email", "profile"],\n'
        '  onGetUserProfile: (UserSucceededState state) async {\n'
        '    // Traiter la connexion réussie\n'
        '  },\n'
        ')'
      );
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Firebase Auth LinkedIn: ${e.code} - ${e.message}');
      throw Exception('Erreur de connexion LinkedIn: ${e.message}');
    } catch (e) {
      print('❌ Erreur de connexion LinkedIn: $e');
      throw Exception('Erreur de connexion LinkedIn: $e');
    }
  }
  
  /// Connexion avec LinkedIn en utilisant un token d'accès
  /// À utiliser après avoir obtenu le token via LinkedInLoginButton
  static Future<User?> signInWithLinkedInToken(String accessToken) async {
    try {
      print('🔄 Connexion LinkedIn avec token');
      
      // Créer un credential OAuth avec le token LinkedIn
      final credential = OAuthProvider('linkedin.com').credential(
        accessToken: accessToken,
      );
      
      // Se connecter avec Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        print('✅ Connexion LinkedIn réussie: ${user.uid}');
        await _createOrUpdateUserDocument(user);
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Firebase Auth LinkedIn: ${e.code} - ${e.message}');
      throw Exception('Erreur de connexion LinkedIn: ${e.message}');
    } catch (e) {
      print('❌ Erreur lors du traitement LinkedIn: $e');
      throw Exception('Erreur lors du traitement LinkedIn: $e');
    }
  }

  /// Connexion avec GitHub
  /// 
  /// Lance une exception en cas d'erreur
  /// Note: GitHub doit être configuré dans Firebase Console comme provider OAuth
  static Future<User?> signInWithGitHub() async {
    try {
      print('🔄 Connexion avec GitHub');
      
      // Créer le provider GitHub
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      
      // Ajouter des scopes si nécessaire (ex: 'read:user', 'user:email')
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');
      
      UserCredential userCredential;
      
      if (kIsWeb) {
        // Sur le web, on préfère souvent signInWithPopup pour ne pas recharger la page
        userCredential = await _auth.signInWithPopup(githubProvider);
      } else {
        // Sur mobile, signInWithProvider gère le flux (souvent via navigateur in-app)
        userCredential = await _auth.signInWithProvider(githubProvider);
      }

      final user = userCredential.user;
      
      if (user != null) {
        print('✅ Connexion GitHub réussie: ${user.uid}');
        
        // Mettre à jour ou créer le document utilisateur
        await _createOrUpdateUserDocument(user);
      }
      
      return user;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Firebase Auth GitHub: ${e.code} - ${e.message}');
      
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Un compte existe déjà avec cet email. Veuillez vous connecter avec la méthode utilisée précédemment.');
      } else if (e.code == 'web-context-cancelled') {
        throw Exception('La connexion a été annulée.');
      }
      
      throw Exception('Erreur de connexion GitHub: ${e.message}');
    } catch (e) {
      print('❌ Erreur de connexion GitHub: $e');
      throw Exception('Erreur de connexion GitHub: $e');
    }
  }
  
  /// Connexion avec GitHub en utilisant un token OAuth
  /// À utiliser après avoir obtenu le token OAuth GitHub via le flux OAuth
  static Future<User?> signInWithGitHubToken(String accessToken) async {
    try {
      print('🔄 Connexion GitHub avec token');
      
      final credential = GithubAuthProvider.credential(accessToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        print('✅ Connexion GitHub réussie: ${user.uid}');
        await _createOrUpdateUserDocument(user);
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Firebase Auth GitHub: ${e.code} - ${e.message}');
      throw Exception('Erreur de connexion GitHub: ${e.message}');
    } catch (e) {
      print('❌ Erreur de connexion GitHub: $e');
      throw Exception('Erreur de connexion GitHub: $e');
    }
  }

  /// Helper method pour créer ou mettre à jour le document utilisateur
  static Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userEmail = user.email;
      if (userEmail == null) {
        print('⚠️ Email utilisateur non disponible');
        return;
      }
      
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userEmail)
          .get();
      
      if (!userDoc.exists) {
        final displayName = user.displayName ?? 'Utilisateur';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : 'Utilisateur';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final userData = {
          'uid': user.uid,
          'email': userEmail,
          'firstName': firstName,
          'lastName': lastName,
          'name': displayName,
          'role': 'candidate',
          'isRecruiter': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore
            .collection(_usersCollection)
            .doc(userEmail)
            .set(userData);
        
        print("✅ Document Firestore créé pour l'utilisateur: ${user.uid}");
      }
    } catch (e) {
      print('❌ Erreur lors de la création du document utilisateur: $e');
    }
  }
}