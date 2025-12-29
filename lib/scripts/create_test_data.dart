import 'package:hire_me/services/test_data_service.dart';

/// Script pour créer des données de test
/// 
/// Utilisation:
/// dart run lib/scripts/create_test_data.dart
/// 
/// Ou depuis le terminal:
/// flutter run lib/scripts/create_test_data.dart
void main() async {
  print('🚀 Démarrage de la création des données de test...');
  
  try {
    // Créer toutes les données de test
    await TestDataService.createAllTestData();
    
    print('✅ Toutes les données de test ont été créées avec succès !');
    print('');
    print('📊 Résumé des données créées:');
    print('• Messages: 20 messages variés entre utilisateurs');
    print("• Annonces d'emploi: 10 offres réalistes");
    print('• Posts: 5 annonces/posts');
    print('• Matches: 5 conversations actives');
    print('');
    print('💡 Vous pouvez maintenant tester votre application avec ces données !');
    
  } catch (e) {
    print('❌ Erreur lors de la création des données: $e');
    print('');
    print('🔧 Vérifiez que:');
    print('• Firebase est correctement configuré');
    print('• Vous avez des utilisateurs dans votre base de données');
    print("• Les règles Firestore autorisent l'écriture");
  }
}
