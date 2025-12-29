import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/core/app_router.dart';
import 'package:hire_me/core/app_theme.dart';
import 'package:hire_me/firebase_options.dart';
import 'package:hire_me/providers/theme_provider.dart';
import 'package:hire_me/services/auth_service.dart';
import 'package:hire_me/services/notification_service.dart';
import 'package:hire_me/services/seed_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialisé avec succès');
    } else {
      // Réutiliser l'app existante (hot restart/web)
      Firebase.app();
      print("Firebase déjà initialisé, réutilisation de l'app");
    }

    // Web: désactiver la persistance pour réduire les soucis de WebChannel
    if (kIsWeb) {
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: false,
        );
        print('Firestore (web): persistance désactivée');
      } catch (e) {
        print('Impossible de configurer Firestore (web): $e');
      }
    }
    
    // Control emulator usage via build flag: --dart-define=USE_FIREBASE_EMULATOR=true
    const useEmulatorEnv = String.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: 'false');
    final isUsingEmulator = useEmulatorEnv.toLowerCase() == 'true';
    if (isUsingEmulator) {
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
        print('Connecté aux émulateurs Firebase (Firestore/Auth/Storage)');
      } catch (e) {
        print('Impossible de connecter les émulateurs Firebase: $e');
      }
    }
    
    // Initialiser les notifications
    await NotificationService.initialize();
    print('Notifications initialisées avec succès');
    
    // Sign-in before any Firestore access when using emulator
    if (isUsingEmulator) {
      try {
        // Anonymous sign-in is enough for emulator and local rules
        await FirebaseAuth.instance.signInAnonymously();
        print('Authentification anonyme réussie (debug)');
      } catch (e) {
        print("Échec de l'authentification anonyme: $e");
      }
    }

    // S'assurer que le document utilisateur existe
    await AuthService.ensureUserDocumentExists();

    // Seeding des données de test (uniquement en mode émulateur)
    if (isUsingEmulator) {
      final hasData = await SeedDataService.hasData();
      if (!hasData) {
        print('🌱 Création des données de test...');
        await SeedDataService.seedAllData();
      } else {
        print('✅ Données de test déjà présentes');
      }
    } else {
      print('⚠️ Mode production: seeding désactivé');
    }
  } catch (e) {
    print("Erreur d'initialisation Firebase: $e");
    print("L'app fonctionnera en mode démo sans Firebase");
  }
  
  runApp(const ProviderScope(child: HireMeApp()));
}

class HireMeApp extends ConsumerWidget {
  const HireMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = buildLightTheme();
    final darkTheme = buildDarkTheme();
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Swipe Em',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode, // Utiliser le provider de thème
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
