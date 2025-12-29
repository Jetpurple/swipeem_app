import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Demo mode removed
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/providers/user_provider.dart' as user_provider;
import 'package:hire_me/services/firebase_job_service.dart';
import 'package:hire_me/services/firebase_user_service.dart';

// Provider pour les swipes d'un utilisateur (candidate→job)
final candidateSwipesProvider = StreamProvider.family<Set<String>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('swipes')
      .where('fromUid', isEqualTo: userId)
      .where('type', isEqualTo: 'candidate→job')
      .snapshots()
      .map((snapshot) {
    final swipedPostedBy = <String>{};
    for (final doc in snapshot.docs) {
      final toEntityId = doc.data()['toEntityId'] as String?;
      if (toEntityId != null && toEntityId.isNotEmpty) {
        swipedPostedBy.add(toEntityId);
      }
    }
    return swipedPostedBy;
  });
});

// Provider pour les offres d'emploi (filtrées par swipes)
final jobOffersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final userId = ref.read(user_provider.currentUserIdProvider);
  
  if (userId == null) {
    return FirebaseJobService.getJobOffersStream();
  }
  
  // Utiliser listen pour éviter les rebuilds infinis
  final swipesStream = ref.watch(candidateSwipesProvider(userId));
  
  return FirebaseJobService.getJobOffersStream().map((jobOffers) {
    final swipedPostedBy = swipesStream.value ?? <String>{};
    
    // Filtrer les offres dont le postedBy a déjà été swipé
    return jobOffers.where((job) {
      final postedBy = job['postedBy'] as String? ?? '';
      return postedBy.isNotEmpty && !swipedPostedBy.contains(postedBy);
    }).toList();
  });
});

// Provider pour une offre d'emploi spécifique par ID
final jobOfferProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, jobOfferId) {
  return FirebaseFirestore.instance
      .collection('jobOffers')
      .doc(jobOfferId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    final result = Map<String, dynamic>.from(data);
    result['id'] = doc.id;
    return result;
  });
});

// Provider pour les swipes d'un recruteur (recruiter→candidate)
final recruiterSwipesProvider = StreamProvider.family<Set<String>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('swipes')
      .where('fromUid', isEqualTo: userId)
      .where('type', isEqualTo: 'recruiter→candidate')
      .snapshots()
      .map((snapshot) {
    final swipedCandidateIds = <String>{};
    for (final doc in snapshot.docs) {
      final toEntityId = doc.data()['toEntityId'] as String?;
      if (toEntityId != null && toEntityId.isNotEmpty) {
        swipedCandidateIds.add(toEntityId);
      }
    }
    return swipedCandidateIds;
  });
});

// Provider pour les matches d'un recruteur
final recruiterMatchesProvider = StreamProvider.family<Set<String>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('matches')
      .where('recruiterUid', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    final matchedCandidateIds = <String>{};
    for (final doc in snapshot.docs) {
      final candidateUid = doc.data()['candidateUid'] as String?;
      if (candidateUid != null && candidateUid.isNotEmpty) {
        matchedCandidateIds.add(candidateUid);
      }
    }
    return matchedCandidateIds;
  });
});

// Provider pour les candidats (filtrés par swipes et matches)
final candidatesProvider = StreamProvider<List<UserModel>>((ref) {
  final userId = ref.read(user_provider.currentUserIdProvider);
  
  if (userId == null) {
    return FirebaseUserService.getCandidatesStream();
  }
  
  // Utiliser listen pour éviter les rebuilds infinis
  final swipesStream = ref.watch(recruiterSwipesProvider(userId));
  final matchesStream = ref.watch(recruiterMatchesProvider(userId));
  
  return FirebaseUserService.getCandidatesStream().map((candidates) {
    final swipedCandidateIds = swipesStream.value ?? <String>{};
    final matchedCandidateIds = matchesStream.value ?? <String>{};
    
    // Filtrer les candidats déjà swipés ou en match
    return candidates.where((candidate) {
      final candidateUid = candidate.uid;
      return candidateUid.isNotEmpty &&
             !swipedCandidateIds.contains(candidateUid) && 
             !matchedCandidateIds.contains(candidateUid);
    }).toList();
  });
});
