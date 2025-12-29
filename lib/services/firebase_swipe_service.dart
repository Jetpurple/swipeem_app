import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSwipeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Enregistrer un swipe (like / pass / superlike)
  static Future<void> recordSwipe({
    required String fromUid,
    required String toEntityId,
    required String type, // 'candidate→job' | 'recruiter→candidate'
    required String value, // 'like' | 'pass' | 'superlike'
  }) async {
    await _db.collection('swipes').add({
      'fromUid': fromUid,
      'toEntityId': toEntityId,
      'type': type,
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Enregistrer un favori
  static Future<void> addFavorite({
    required String uid,
    required String jobId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(jobId)
        .set({
      'jobId': jobId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Retirer un favori
  static Future<void> removeFavorite({
    required String uid,
    required String jobId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(jobId)
        .delete();
  }

  // Favoris côté recruteur (candidats)
  static Future<void> addCandidateFavorite({
    required String recruiterUid,
    required String candidateUid,
  }) async {
    await _db
        .collection('users')
        .doc(recruiterUid)
        .collection('candidateFavorites')
        .doc(candidateUid)
        .set({
      'candidateUid': candidateUid,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeCandidateFavorite({
    required String recruiterUid,
    required String candidateUid,
  }) async {
    await _db
        .collection('users')
        .doc(recruiterUid)
        .collection('candidateFavorites')
        .doc(candidateUid)
        .delete();
  }
}


