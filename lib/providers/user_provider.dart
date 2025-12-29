import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/services/auth_service.dart';
import 'package:hire_me/services/firebase_user_service.dart';
import 'package:riverpod/src/providers/stream_provider.dart';

// Provider pour l'utilisateur actuellement connecté
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user != null) {
        // Essayer d'abord par email (nouvelle structure)
        if (user.email != null) {
          return FirebaseUserService.getUserStream(user.email!);
        }
        // Fallback par UID (ancienne structure)
        return FirebaseUserService.getUserStreamByUid(user.uid);
      }
      return Stream.value(null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Provider pour un utilisateur spécifique (peut être un UID ou un email)
final StreamProviderFamily<UserModel?, String> userProvider = StreamProvider.family<UserModel?, String>((ref, identifier) {
  // Si l'identifiant contient un @, c'est probablement un email
  if (identifier.contains('@')) {
    return FirebaseUserService.getUserStream(identifier);
  }
  // Sinon, c'est probablement un UID, chercher par UID
  return FirebaseUserService.getUserStreamByUid(identifier);
});

// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider pour vérifier si l'utilisateur est connecté
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider pour l'UID de l'utilisateur connecté
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider pour AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
