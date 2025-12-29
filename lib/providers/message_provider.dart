import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/models/message_model.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/services/firebase_match_service.dart';
import 'package:hire_me/services/firebase_message_service.dart';
import 'package:riverpod/src/providers/stream_provider.dart';

// Provider pour les matches de l'utilisateur connecté
final userMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId != null) {
    return FirebaseMatchService.getUserMatchesStream(currentUserId);
  }
  return Stream.value([]);
});

// Provider pour les messages d'un match spécifique
final StreamProviderFamily<List<MessageModel>, String> matchMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, matchId) {
  return FirebaseMessageService.getMessagesStream(matchId);
});

// Provider pour le nombre de messages non lus
final unreadMessageCountProvider = StreamProvider<int>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId != null) {
    return FirebaseMessageService.getUnreadCountStream(currentUserId);
  }
  return Stream.value(0);
});
