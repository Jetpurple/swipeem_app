import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseJobService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'jobOffers';

  // Créer une offre d'emploi
  static Future<String> createJobOffer({
    required String title,
    required String company,
    required String location,
    required String salary,
    required String description,
    required List<String> requirements,
    required List<String> benefits,
    required String postedBy,
    String? type,
    String? experience,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'title': title,
        'company': company,
        'location': location,
        'salary': salary,
        'description': description,
        'requirements': requirements,
        'benefits': benefits,
        'postedBy': postedBy,
        'type': type,
        'experience': experience,
        'postedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      throw Exception("Erreur lors de la création de l'offre: $e");
    }
  }

  // Récupérer toutes les offres d'emploi
  static Future<List<Map<String, dynamic>>> getAllJobOffers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('postedAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des offres: $e');
    }
  }

  // Récupérer les offres d'une entreprise
  static Future<List<Map<String, dynamic>>> getJobOffersByCompany(String companyUid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('postedBy', isEqualTo: companyUid)
          .where('isActive', isEqualTo: true)
          .orderBy('postedAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des offres de l'entreprise: $e");
    }
  }

  // Mettre à jour une offre d'emploi
  static Future<void> updateJobOffer(String jobId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(jobId).update(updates);
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de l'offre: $e");
    }
  }

  // Supprimer une offre d'emploi
  static Future<void> deleteJobOffer(String jobId) async {
    try {
      await _firestore.collection(_collection).doc(jobId).update({'isActive': false});
    } catch (e) {
      throw Exception("Erreur lors de la suppression de l'offre: $e");
    }
  }

  // Stream des offres d'emploi
  static Stream<List<Map<String, dynamic>>> getJobOffersStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
