import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSubscriptionService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Vérifier si l'utilisateur a un abonnement premium actif
  static Future<bool> isPremium(String uid) async {
    try {
      final doc = await _db.collection('subscriptions').doc(uid).get();
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final isActive = data['isActive'] as bool? ?? false;
      final expiresAt = data['expiresAt'] as Timestamp?;
      
      if (!isActive) return false;
      if (expiresAt == null) return true; // Abonnement permanent
      
      return expiresAt.toDate().isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Stream pour écouter les changements d'abonnement
  static Stream<bool> isPremiumStream(String uid) {
    return _db.collection('subscriptions').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final isActive = data['isActive'] as bool? ?? false;
      final expiresAt = data['expiresAt'] as Timestamp?;
      
      if (!isActive) return false;
      if (expiresAt == null) return true;
      
      return expiresAt.toDate().isAfter(DateTime.now());
    });
  }
}
