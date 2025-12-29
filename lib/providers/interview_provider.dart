import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/models/interview_model.dart';
import 'package:hire_me/services/firebase_interview_service.dart';

/// Provider for fetching interviews for a specific user
final userInterviewsProvider =
    StreamProvider.family<List<InterviewModel>, String>((ref, userId) {
  return FirebaseInterviewService.getInterviewsForUser(userId);
});

/// Provider for fetching interviews for a specific match
final matchInterviewsProvider =
    StreamProvider.family<List<InterviewModel>, String>((ref, matchId) {
  return FirebaseInterviewService.getInterviewsForMatch(matchId);
});
