import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hire_me/models/message_model.dart';

class MatchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'matches';

  // Créer un nouveau match
  static Future<String> createMatch({
    required String candidateUid,
    required String recruiterUid,
  }) async {
    try {
      final matchId = _firestore.collection(_collection).doc().id;
      final match = MatchModel(
        id: matchId,
        candidateUid: candidateUid,
        recruiterUid: recruiterUid,
        matchedAt: DateTime.now(),
        readBy: {
          candidateUid: true,
          recruiterUid: true,
        },
      );

      await _firestore.collection(_collection).doc(matchId).set(match.toFirestore());
      return matchId;
    } catch (e) {
      throw Exception('Erreur lors de la création du match: $e');
    }
  }

  // Récupérer les matches d'un utilisateur
  static Future<List<MatchModel>> getUserMatches(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('candidateUid', isEqualTo: uid)
          .orderBy('lastMessageAt', descending: true)
          .get();

      final recruiterMatches = await _firestore
          .collection(_collection)
          .where('recruiterUid', isEqualTo: uid)
          .orderBy('lastMessageAt', descending: true)
          .get();

      final allMatches = <MatchModel>[];
      allMatches.addAll(querySnapshot.docs.map(MatchModel.fromFirestore));
      allMatches.addAll(recruiterMatches.docs.map(MatchModel.fromFirestore));

      // Trier par date du dernier message
      allMatches.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.matchedAt;
        final bTime = b.lastMessageAt ?? b.matchedAt;
        return bTime.compareTo(aTime);
      });

      return allMatches;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des matches: $e');
    }
  }

  // Stream des matches d'un utilisateur
  static Stream<List<MatchModel>> getUserMatchesStream(String uid) {
    final candidateMatches = _firestore
        .collection(_collection)
        .where('candidateUid', isEqualTo: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();

    final recruiterMatches = _firestore
        .collection(_collection)
        .where('recruiterUid', isEqualTo: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();

    return candidateMatches.asyncExpand((candidateSnapshot) {
      return recruiterMatches.map((recruiterSnapshot) {
        final allMatches = <MatchModel>[];
        allMatches.addAll(candidateSnapshot.docs.map(MatchModel.fromFirestore));
        allMatches.addAll(recruiterSnapshot.docs.map(MatchModel.fromFirestore));

        // Trier par date du dernier message
        allMatches.sort((a, b) {
          final aTime = a.lastMessageAt ?? a.matchedAt;
          final bTime = b.lastMessageAt ?? b.matchedAt;
          return bTime.compareTo(aTime);
        });

        return allMatches;
      });
    });
  }

  // Récupérer un match spécifique
  static Future<MatchModel?> getMatch(String matchId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(matchId).get();
      if (doc.exists) {
        return MatchModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du match: $e');
    }
  }

  // Récupérer les matches de l'utilisateur connecté
  static Future<List<MatchModel>> getCurrentUserMatches() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Utilisateur non connecté');
    return getUserMatches(currentUser.uid);
  }

  // Stream des matches de l'utilisateur connecté
  static Stream<List<MatchModel>> getCurrentUserMatchesStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);
    return getUserMatchesStream(currentUser.uid);
  }

  // Supprimer un match
  static Future<void> deleteMatch(String matchId) async {
    try {
      await _firestore.collection(_collection).doc(matchId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du match: $e');
    }
  }

  // Désactiver un match
  static Future<void> deactivateMatch(String matchId) async {
    try {
      await _firestore.collection(_collection).doc(matchId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Erreur lors de la désactivation du match: $e');
    }
  }

  // Récupérer l'autre utilisateur d'un match
  static Future<String?> getOtherUserUid(String matchId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final match = await getMatch(matchId);
      if (match == null) return null;

      if (match.candidateUid == currentUser.uid) {
        return match.recruiterUid;
      } else {
        return match.candidateUid;
      }
    } catch (e) {
      throw Exception("Erreur lors de la récupération de l'autre utilisateur: $e");
    }
  }

  // Vérifier si un match existe entre deux utilisateurs
  static Future<String?> getExistingMatch(String uid1, String uid2) async {
    try {
      final query1 = await _firestore
          .collection(_collection)
          .where('candidateUid', isEqualTo: uid1)
          .where('recruiterUid', isEqualTo: uid2)
          .where('isActive', isEqualTo: true)
          .get();

      if (query1.docs.isNotEmpty) {
        return query1.docs.first.id;
      }

      final query2 = await _firestore
          .collection(_collection)
          .where('candidateUid', isEqualTo: uid2)
          .where('recruiterUid', isEqualTo: uid1)
          .where('isActive', isEqualTo: true)
          .get();

      if (query2.docs.isNotEmpty) {
        return query2.docs.first.id;
      }

      return null;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du match existant: $e');
    }
  }
}
