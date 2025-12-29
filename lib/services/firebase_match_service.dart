import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hire_me/models/message_model.dart';

class FirebaseMatchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'matches';

  // Créer un match
  static Future<String> createMatch({
    required String candidateUid,
    required String recruiterUid,
    String? jobOfferId,
  }) async {
    try {
      // Vérifier si un match existe déjà
      final existingMatch = await _firestore
          .collection(_collection)
          .where('candidateUid', isEqualTo: candidateUid)
          .where('recruiterUid', isEqualTo: recruiterUid)
          .get();

      if (existingMatch.docs.isNotEmpty) {
        final matchId = existingMatch.docs.first.id;
        // Mettre à jour le jobOfferId si fourni et non présent
        if (jobOfferId != null) {
          final matchData = existingMatch.docs.first.data();
          if (matchData['jobOfferId'] == null) {
            await _firestore.collection(_collection).doc(matchId).update({
              'jobOfferId': jobOfferId,
            });
          }
        }
        return matchId;
      }

      final matchData = <String, dynamic>{
        'candidateUid': candidateUid,
        'recruiterUid': recruiterUid,
        'matchedAt': FieldValue.serverTimestamp(),
        'lastMessageAt': null,
        'lastMessageContent': null,
        'lastMessageSenderUid': null,
        'readBy': {
          candidateUid: true,
          recruiterUid: true,
        },
      };
      
      if (jobOfferId != null) {
        matchData['jobOfferId'] = jobOfferId;
      }

      final docRef = await _firestore.collection(_collection).add(matchData);
      return docRef.id;
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

      final querySnapshot2 = await _firestore
          .collection(_collection)
          .where('recruiterUid', isEqualTo: uid)
          .orderBy('lastMessageAt', descending: true)
          .get();

      final matches = <MatchModel>[];
      
      for (final doc in querySnapshot.docs) {
        matches.add(MatchModel.fromFirestore(doc));
      }
      
      for (final doc in querySnapshot2.docs) {
        matches.add(MatchModel.fromFirestore(doc));
      }

      // Trier par lastMessageAt
      matches.sort((a, b) {
        if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });

      return matches;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des matches: $e');
    }
  }

  // Stream des matches d'un utilisateur
  static Stream<List<MatchModel>> getUserMatchesStream(String uid) {
    // Utiliser combineLatest pour combiner les deux streams (candidat et recruteur)
    final candidateMatchesStream = _firestore
        .collection(_collection)
        .where('candidateUid', isEqualTo: uid)
        .snapshots();
    
    final recruiterMatchesStream = _firestore
        .collection(_collection)
        .where('recruiterUid', isEqualTo: uid)
        .snapshots();

    // Combiner les deux streams
    return candidateMatchesStream.asyncExpand((candidateSnapshot) {
      return recruiterMatchesStream.map((recruiterSnapshot) {
        final matches = <MatchModel>[];
        
        // Ajouter les matches où l'utilisateur est candidat
        for (final doc in candidateSnapshot.docs) {
          matches.add(MatchModel.fromFirestore(doc));
        }
        
        // Ajouter les matches où l'utilisateur est recruteur
        for (final doc in recruiterSnapshot.docs) {
          matches.add(MatchModel.fromFirestore(doc));
        }

        // Trier par lastMessageAt (les nulls en dernier), puis par matchedAt
        matches.sort((a, b) {
          // Si les deux ont lastMessageAt, trier par celui-ci
          if (a.lastMessageAt != null && b.lastMessageAt != null) {
            return b.lastMessageAt!.compareTo(a.lastMessageAt!);
          }
          // Si un seul a lastMessageAt, celui avec lastMessageAt vient en premier
          if (a.lastMessageAt != null) return -1;
          if (b.lastMessageAt != null) return 1;
          // Si aucun n'a lastMessageAt, trier par matchedAt
          return b.matchedAt.compareTo(a.matchedAt);
        });

        return matches;
      });
    });
  }

  // Mettre à jour les informations du dernier message
  static Future<void> updateLastMessage({
    required String matchId,
    required String content,
    required String senderUid,
  }) async {
    try {
      final matchDoc = await _firestore.collection(_collection).doc(matchId).get();
      if (!matchDoc.exists) {
        throw Exception('Match $matchId n\'existe pas');
      }

      final matchData = matchDoc.data();
      if (matchData == null) {
        throw Exception('Données du match $matchId invalides');
      }

      // Récupérer les UIDs du match
      final candidateUid = matchData['candidateUid'] as String?;
      final recruiterUid = matchData['recruiterUid'] as String?;
      
      if (candidateUid == null || recruiterUid == null) {
        throw Exception('Match $matchId invalide: UIDs manquants');
      }

      // Mettre à jour le match avec le dernier message et le statut de lecture
      final updateData = <String, dynamic>{
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageContent': content,
        'lastMessageSenderUid': senderUid,
      };

      // Mettre à jour readBy si nécessaire
      final readBy = Map<String, dynamic>.from(matchData['readBy'] as Map<dynamic, dynamic>? ?? {});
      readBy[senderUid] = true;
      readBy[candidateUid == senderUid ? recruiterUid : candidateUid] = false;
      updateData['readBy'] = readBy;

      await _firestore.collection(_collection).doc(matchId).update(updateData);
    } catch (e) {
      print('❌ Erreur updateLastMessage: $e');
      throw Exception('Erreur lors de la mise à jour du dernier message: $e');
    }
  }

  // Marquer un match comme lu
  static Future<void> markAsRead(String matchId, String uid) async {
    try {
      await _firestore.collection(_collection).doc(matchId).update({
        'readBy.$uid': true,
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage comme lu: $e');
    }
  }

  // Supprimer un match
  static Future<void> deleteMatch(String matchId) async {
    try {
      await _firestore.collection(_collection).doc(matchId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du match: $e');
    }
  }
}
