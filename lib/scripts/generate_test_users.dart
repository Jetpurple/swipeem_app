import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hire_me/firebase_options.dart';
import 'package:hire_me/services/seed_data_service.dart';

/// Script simple pour générer 100 candidats + 10 recruteurs
/// 
/// Exécutez ce script avec:
/// dart run lib/scripts/generate_test_users.dart
void main() async {
  print('🚀 Démarrage de la génération des utilisateurs de test...\n');
  
  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé\n');
    
    // Vérifier si des données de base existent déjà
    print('📊 Vérification des données existantes...');
    final hasData = await SeedDataService.hasData();
    
    if (!hasData) {
      print('⚠️  Aucune donnée de base trouvée');
      print('📝 Création des données de base...');
      await SeedDataService.seedAllData();
      print('✅ Données de base créées\n');
    } else {
      print('✅ Données de base existantes\n');
    }
    
    // Générer le large dataset
    print('👥 Génération de 100 candidats + 10 recruteurs...');
    print('⏱️  Cela peut prendre quelques secondes...\n');
    
    await SeedDataService.seedLargeDataSet();
    
    print('\n✅ SUCCÈS ! Les utilisateurs de test ont été créés :');
    print('   - 100 candidats');
    print('   - 10 recruteurs');
    print('\n💡 Note: Ces utilisateurs sont uniquement dans Firestore.');
    print('   Vous ne pouvez pas vous connecter avec ces comptes.');
    print('   Utilisez-les pour tester le swipe et les matchs.\n');
    
  } catch (e, stackTrace) {
    print('\n❌ ERREUR lors de la génération:');
    print('   $e');
    print('\n📋 Stack trace:');
    print(stackTrace);
  }
}
