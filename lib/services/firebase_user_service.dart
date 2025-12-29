import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hire_me/models/user_model.dart';

class FirebaseUserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  /// Helper pour obtenir la référence du document utilisateur de manière robuste.
  /// Vérifie d'abord si un document existe avec l'ID = uid.
  /// Sinon, cherche un document où le champ 'uid' = uid.
  /// Si aucun n'est trouvé, retourne la référence avec l'ID = uid (pour création ou fallback).
  static Future<DocumentReference> _getUserDocRef(String uid) async {
    // 1. Essayer l'ID direct (cas des utilisateurs créés via AdminTestDataService ou ancienne méthode)
    final docRefById = _firestore.collection(_collection).doc(uid);
    final docSnapshot = await docRefById.get();
    if (docSnapshot.exists) {
      return docRefById;
    }

    // 2. Essayer de chercher par le champ 'uid' (cas des utilisateurs créés via AuthService avec email comme ID)
    final query = await _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.reference;
    }

    // 3. Fallback: retourner la référence par ID (sera utilisée pour créer le doc si nécessaire)
    return docRefById;
  }

  // Créer un utilisateur
  static Future<void> createUser(UserModel user) async {
    try {
      // Note: Idéalement, on devrait utiliser la même logique que AuthService (email comme ID)
      // Mais pour rester compatible avec l'existant, on garde l'UID comme ID ici
      // tout en s'assurant que le champ 'uid' est bien présent dans les données (via toFirestore)
      await _firestore.collection(_collection).doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw Exception("Erreur lors de la création de l'utilisateur: $e");
    }
  }

  // Récupérer un utilisateur par UID
  static Future<UserModel?> getUser(String uid) async {
    try {
      final docRef = await _getUserDocRef(uid);
      final doc = await docRef.get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      print('⚠️ Erreur lors de la récupération de l\'utilisateur $uid: $e');
      throw Exception("Erreur lors de la récupération de l'utilisateur: $e");
    }
  }

  // Mettre à jour un utilisateur
  static Future<void> updateUser(UserModel user) async {
    try {
      final docRef = await _getUserDocRef(user.uid);
      await docRef.update(user.toFirestore());
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de l'utilisateur: $e");
    }
  }

  // Supprimer un utilisateur
  static Future<void> deleteUser(String uid) async {
    try {
      final docRef = await _getUserDocRef(uid);
      await docRef.delete();
    } catch (e) {
      throw Exception("Erreur lors de la suppression de l'utilisateur: $e");
    }
  }

  // Stream d'un utilisateur spécifique (par email)
  static Stream<UserModel?> getUserStream(String email) {
    return _firestore.collection(_collection).doc(email).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }
  
  // Stream d'un utilisateur par UID (pour compatibilité)
  static Stream<UserModel?> getUserStreamByUid(String uid) {
    return _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      }
      // Fallback: essayer de lire directement le doc avec l'ID (si le stream query ne donne rien)
      // Note: On ne peut pas facilement faire de fallback "propre" dans un stream simple sans combiner des streams.
      // Pour l'instant, on suppose que si on cherche par UID, le champ 'uid' est indexé et présent.
      return null;
    });
  }

  // Récupérer tous les utilisateurs
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map(UserModel.fromFirestore)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  // Récupérer les candidats (utilisateurs non recruteurs)
  static Future<List<UserModel>> getCandidates() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isRecruiter', isEqualTo: false)
          .get();
      return querySnapshot.docs
          .map(UserModel.fromFirestore)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des candidats: $e');
    }
  }

  // Stream des candidats (utilisateurs non recruteurs)
  static Stream<List<UserModel>> getCandidatesStream() {
    return _firestore
        .collection(_collection)
        .where('isRecruiter', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Récupérer les recruteurs
  static Future<List<UserModel>> getRecruiters() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isRecruiter', isEqualTo: true)
          .get();
      return querySnapshot.docs
          .map(UserModel.fromFirestore)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des recruteurs: $e');
    }
  }

  // Mettre à jour le statut en ligne
  static Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      final docRef = await _getUserDocRef(uid);
      await docRef.update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Mettre à jour les soft skills d'un utilisateur
  static Future<void> updateSoftSkills(
    String uid,
    List<Map<String, dynamic>> softSkills,
  ) async {
    try {
      final docRef = await _getUserDocRef(uid);
      await docRef.set({
        'softSkills': softSkills,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des soft skills: $e');
    }
  }

  // Mettre à jour les hard skills d'un utilisateur
  static Future<void> updateHardSkills(
    String uid,
    List<Map<String, dynamic>> hardSkills,
  ) async {
    try {
      final docRef = await _getUserDocRef(uid);
      await docRef.set({
        'hardSkills': hardSkills,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des hard skills: $e');
    }
  }

  // Mettre à jour l'URL de la photo de profil
  static Future<void> updateProfileImageUrl(String uid, String url) async {
    try {
      debugPrint('💾 Mise à jour Firestore - uid: $uid');
      debugPrint('💾 URL: ${url.substring(0, url.length > 100 ? 100 : url.length)}...');
      
      final docRef = await _getUserDocRef(uid);
      debugPrint('📝 Document trouvé: ${docRef.id}');
      
      await docRef.set({
        'profileImageUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
        // On s'assure aussi que l'UID est présent pour les futures recherches
        'uid': uid, 
      }, SetOptions(merge: true));
      
      debugPrint('✅ Photo de profil mise à jour dans Firestore');
    } catch (e) {
      debugPrint('❌ Erreur Firestore: $e');
      throw Exception("Erreur lors de la mise à jour de la photo de profil: $e");
    }
  }

  // Supprimer l'URL de la photo de profil (retour à défaut)
  static Future<void> clearProfileImageUrl(String uid) async {
    try {
      final docRef = await _getUserDocRef(uid);
      
      await docRef.set({
        'profileImageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Erreur lors de la suppression de la photo de profil: $e");
    }
  }

  // Initialiser les compétences par défaut pour un utilisateur
  static Future<void> initializeDefaultSkills(String uid) async {
    try {
      // Compétences par défaut
      final defaultSoftSkills = [
        {
          'label': 'Communication',
          'score': 3,
          'category': 'Interpersonnel',
          'suffix': null,
        },
        {
          'label': 'Travail en équipe',
          'score': 3,
          'category': 'Interpersonnel',
          'suffix': null,
        },
        {
          'label': 'Leadership',
          'score': 2,
          'category': 'Management',
          'suffix': null,
        },
      ];

      final defaultHardSkills = [
        {
          'label': 'Programmation',
          'score': 3,
          'category': 'Technique',
          'suffix': null,
        },
        {
          'label': 'Gestion de projet',
          'score': 2,
          'category': 'Technique',
          'suffix': null,
        },
        {
          'label': 'Analyse de données',
          'score': 2,
          'category': 'Technique',
          'suffix': null,
        },
      ];

      final docRef = await _getUserDocRef(uid);
      await docRef.set({
        'softSkills': defaultSoftSkills,
        'hardSkills': defaultHardSkills,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Erreur lors de l'initialisation des compétences: $e");
    }
  }
}
