import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hire_me/models/interview_model.dart';

/// Service for managing interviews in Firestore
class FirebaseInterviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'interviews';

  /// Propose a new interview
  static Future<String> proposeInterview({
    required String matchId,
    required String recruiterId,
    required String candidateId,
    required DateTime proposedDateTime,
    required String location,
    required String notes,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection(_collection).add({
        'matchId': matchId,
        'recruiterId': recruiterId,
        'candidateId': candidateId,
        'proposedDateTime': Timestamp.fromDate(proposedDateTime),
        'location': location,
        'notes': notes,
        'status': InterviewStatus.pending.toJson(),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      print('✅ Interview proposed successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error proposing interview: $e');
      rethrow;
    }
  }

  /// Get all interviews for a specific user (as recruiter or candidate)
  static Stream<List<InterviewModel>> getInterviewsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('recruiterId', isEqualTo: userId)
        .snapshots()
        .asyncMap((recruiterSnapshot) async {
      // Get interviews where user is recruiter
      final recruiterInterviews = recruiterSnapshot.docs
          .map((doc) => InterviewModel.fromFirestore(doc))
          .toList();

      // Get interviews where user is candidate
      final candidateSnapshot = await _firestore
          .collection(_collection)
          .where('candidateId', isEqualTo: userId)
          .get();

      final candidateInterviews = candidateSnapshot.docs
          .map((doc) => InterviewModel.fromFirestore(doc))
          .toList();

      // Combine both lists
      return [...recruiterInterviews, ...candidateInterviews];
    });
  }

  /// Get all interviews for a specific match
  static Stream<List<InterviewModel>> getInterviewsForMatch(String matchId) {
    return _firestore
        .collection(_collection)
        .where('matchId', isEqualTo: matchId)
        .orderBy('proposedDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InterviewModel.fromFirestore(doc))
            .toList());
  }

  /// Update interview status
  static Future<void> updateInterviewStatus({
    required String interviewId,
    required InterviewStatus status,
  }) async {
    try {
      await _firestore.collection(_collection).doc(interviewId).update({
        'status': status.toJson(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Interview status updated to: ${status.name}');
    } catch (e) {
      print('❌ Error updating interview status: $e');
      rethrow;
    }
  }

  /// Update interview details
  static Future<void> updateInterview({
    required String interviewId,
    DateTime? proposedDateTime,
    String? location,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (proposedDateTime != null) {
        updates['proposedDateTime'] = Timestamp.fromDate(proposedDateTime);
      }
      if (location != null) {
        updates['location'] = location;
      }
      if (notes != null) {
        updates['notes'] = notes;
      }

      await _firestore.collection(_collection).doc(interviewId).update(updates);

      print('✅ Interview updated successfully');
    } catch (e) {
      print('❌ Error updating interview: $e');
      rethrow;
    }
  }

  /// Delete/cancel an interview
  static Future<void> deleteInterview(String interviewId) async {
    try {
      await _firestore.collection(_collection).doc(interviewId).delete();
      print('✅ Interview deleted successfully');
    } catch (e) {
      print('❌ Error deleting interview: $e');
      rethrow;
    }
  }

  /// Get a single interview by ID
  static Future<InterviewModel?> getInterview(String interviewId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(interviewId).get();

      if (!doc.exists) {
        return null;
      }

      return InterviewModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting interview: $e');
      rethrow;
    }
  }
}
