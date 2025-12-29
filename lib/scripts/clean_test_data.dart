import 'package:hire_me/services/test_data_service.dart';

/// Script pour nettoyer les données de test
/// 
/// Utilisation:
/// dart run lib/scripts/clean_test_data.dart
/// 
/// Ou depuis le terminal:
/// flutter run lib/scripts/clean_test_data.dart
void main() async {
  print('🧹 Démarrage du nettoyage des données de test...');
  
  try {
    // Nettoyer toutes les données de test
    await TestDataService.cleanTestData();
    
    print('✅ Toutes les données de test ont été supprimées !');
    print('');
    print('🗑️ Données supprimées:');
    print('• Messages de test');
    print('• Matches de test');
    print("• Annonces d'emploi de test");
    print('• Posts de test');
    print('');
    print('💡 Votre base de données est maintenant propre !');
    
  } catch (e) {
    print('❌ Erreur lors du nettoyage: $e');
    print('');
    print('🔧 Vérifiez que:');
    print('• Firebase est correctement configuré');
    print('• Les règles Firestore autorisent la suppression');
  }
}
