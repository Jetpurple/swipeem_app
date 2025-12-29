import 'package:hire_me/services/seed_data_service.dart';

/// Utilitaire pour gérer le seeding des données de test
class SeedHelper {
  
  /// Lance le seeding complet des données de test
  static Future<void> seedData() async {
    try {
      print('🚀 Démarrage du seeding des données...');
      await SeedDataService.seedAllData();
      print('✅ Seeding terminé avec succès !');
    } catch (e) {
      print('❌ Erreur lors du seeding: $e');
      rethrow;
    }
  }

  /// Vérifie si des données existent déjà
  static Future<bool> checkData() async {
    try {
      final hasData = await SeedDataService.hasData();
      print(hasData ? '✅ Des données existent déjà' : '⚠️ Aucune donnée trouvée');
      return hasData;
    } catch (e) {
      print('❌ Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Supprime toutes les données de test
  static Future<void> clearData() async {
    try {
      print('🗑️ Suppression des données...');
      await SeedDataService.clearAllData();
      print('✅ Données supprimées avec succès !');
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
      rethrow;
    }
  }

  /// Réinitialise complètement les données (supprime + recrée)
  static Future<void> resetData() async {
    try {
      print('🔄 Réinitialisation des données...');
      await clearData();
      await seedData();
      print('✅ Réinitialisation terminée !');
    } catch (e) {
      print('❌ Erreur lors de la réinitialisation: $e');
      rethrow;
    }
  }
}
