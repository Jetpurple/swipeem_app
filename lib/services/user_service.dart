import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hire_me/models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'users';

  // Créer un nouvel utilisateur
  static Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw Exception("Erreur lors de la création de l'utilisateur: $e");
    }
  }

  // Récupérer un utilisateur par son UID
  static Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception("Erreur lors de la récupération de l'utilisateur: $e");
    }
  }

  // Mettre à jour un utilisateur
  static Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore.collection(_collection).doc(user.uid).update(updatedUser.toFirestore());
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de l'utilisateur: $e");
    }
  }

  // Supprimer un utilisateur
  static Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception("Erreur lors de la suppression de l'utilisateur: $e");
    }
  }

  // Récupérer l'utilisateur actuellement connecté
  static Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return getUser(user.uid);
    }
    return null;
  }

  // Mettre à jour le statut en ligne
  static Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Rechercher des utilisateurs par nom
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThan: '${query}z')
          .limit(10)
          .get();

      return querySnapshot.docs
          .map(UserModel.fromFirestore)
          .toList();
    } catch (e) {
      throw Exception("Erreur lors de la recherche d'utilisateurs: $e");
    }
  }

  // Récupérer tous les utilisateurs (pour les admins)
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

  // Stream pour écouter les changements d'un utilisateur
  static Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Stream pour écouter les changements de l'utilisateur connecté
  static Stream<UserModel?> getCurrentUserStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return getUserStream(user.uid);
    }
    return Stream.value(null);
  }
}
