import 'package:cloud_firestore/cloud_firestore.dart';

class SeedDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crée toutes les données de test nécessaires
  static Future<void> seedAllData() async {
    try {
      print('🌱 Début du seeding des données de test...');
      
      // 1. Créer les utilisateurs de test
      await _seedUsers();
      
      // 2. Créer les offres d'emploi
      await _seedJobOffers();
      
      // 3. Créer les matches
      await _seedMatches();
      
      // 4. Créer les messages
      await _seedMessages();
      
      // 5. Créer les swipes
      await _seedSwipes();
      
      print('✅ Seeding terminé avec succès !');
    } catch (e) {
      print('❌ Erreur lors du seeding: $e');
      rethrow;
    }
  }

  /// Crée les utilisateurs de test
  static Future<void> _seedUsers() async {
    print('👥 Création des utilisateurs de test...');
    
    final users = [
      // Candidat 1
      {
        'uid': 'candidate_1',
        'email': 'candidat@example.com',
        'firstName': 'Élodie',
        'lastName': 'Durand',
        'name': 'Élodie Durand',
        'role': 'candidate',
        'isRecruiter': false,
        'jobTitle': 'Développeuse Flutter',
        'experience': '3 ans',
        'location': 'Paris',
        'skills': ['Flutter', 'Dart', 'Firebase', 'UI/UX'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      // Candidat 2
      {
        'uid': 'candidate_2',
        'email': 'marie@example.com',
        'firstName': 'Marie',
        'lastName': 'Martin',
        'name': 'Marie Martin',
        'role': 'candidate',
        'isRecruiter': false,
        'jobTitle': 'Développeuse React Native',
        'experience': '2 ans',
        'location': 'Lyon',
        'skills': ['React Native', 'JavaScript', 'Redux', 'API'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      // Recruteur 1
      {
        'uid': 'recruiter_1',
        'email': 'contact@techcorp.com',
        'firstName': 'Sophie',
        'lastName': 'Martin',
        'name': 'Sophie Martin',
        'role': 'recruiter',
        'isRecruiter': true,
        'companyName': 'TechCorp',
        'jobTitle': 'Responsable RH',
        'location': 'Paris',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      // Recruteur 2
      {
        'uid': 'recruiter_2',
        'email': 'hr@startup.io',
        'firstName': 'Thomas',
        'lastName': 'Dubois',
        'name': 'Thomas Dubois',
        'role': 'recruiter',
        'isRecruiter': true,
        'companyName': 'StartupIO',
        'jobTitle': 'CEO',
        'location': 'Lyon',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final user in users) {
      // Utiliser l'email comme ID du document
      final email = user['email']! as String;
      await _firestore.collection('users').doc(email).set(user);
      print('✅ Utilisateur créé: ${user['name']} (${user['role']}) - Email: $email');
    }
  }

  /// Crée les offres d'emploi
  static Future<void> _seedJobOffers() async {
    print("💼 Création des offres d'emploi...");
    
    final jobOffers = [
      {
        'id': 'job_1',
        'title': 'Développeur Flutter Senior',
        'company': 'TechCorp',
        'location': 'Paris',
        'type': 'CDI',
        'salary': '45-55k€',
        'experience': '3-5 ans',
        'description': 'Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe mobile.',
        'requirements': ['Flutter', 'Dart', 'Firebase', 'Git', 'Agile'],
        'benefits': ['Télétravail', 'Mutuelle', 'Tickets resto', 'Formation'],
        'postedBy': 'recruiter_1',
        'isActive': true,
        'postedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'job_2',
        'title': 'Développeuse React Native',
        'company': 'StartupIO',
        'location': 'Lyon',
        'type': 'CDI',
        'salary': '40-50k€',
        'experience': '2-4 ans',
        'description': 'Rejoignez notre startup en pleine croissance !',
        'requirements': ['React Native', 'JavaScript', 'Redux', 'API REST'],
        'benefits': ['Equity', 'Télétravail', 'Matériel fourni'],
        'postedBy': 'recruiter_2',
        'isActive': true,
        'postedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'job_3',
        'title': 'Chef de projet digital',
        'company': 'TechCorp',
        'location': 'Paris',
        'type': 'CDI',
        'salary': '50-60k€',
        'experience': '5+ ans',
        'description': 'Pilotez nos projets digitaux innovants.',
        'requirements': ['Gestion de projet', 'Agile', 'Digital', 'Leadership'],
        'benefits': ['Télétravail', 'Mutuelle', 'Prime', 'Formation'],
        'postedBy': 'recruiter_1',
        'isActive': true,
        'postedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final job in jobOffers) {
      await _firestore.collection('jobOffers').doc(job['id']! as String).set(job);
      print('✅ Offre créée: ${job['title']} chez ${job['company']}');
    }
  }

  /// Crée les matches
  static Future<void> _seedMatches() async {
    print('💕 Création des matches...');
    
    final matches = [
      {
        'id': 'match_1',
        'candidateUid': 'candidate_1',
        'recruiterUid': 'recruiter_1',
        'jobId': 'job_1',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'match_2',
        'candidateUid': 'candidate_2',
        'recruiterUid': 'recruiter_2',
        'jobId': 'job_2',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final match in matches) {
      await _firestore.collection('matches').doc(match['id']! as String).set(match);
      print('✅ Match créé: ${match['candidateUid']} ↔ ${match['recruiterUid']}');
    }
  }

  /// Crée les messages
  static Future<void> _seedMessages() async {
    print('💬 Création des messages...');
    
    final messages = [
      // Messages pour match_1
      {
        'id': 'msg_1',
        'matchId': 'match_1',
        'senderUid': 'recruiter_1',
        'receiverUid': 'candidate_1',
        'content': "Bonjour Élodie ! Votre profil m'intéresse beaucoup pour notre poste de développeur Flutter.",
        'sentAt': FieldValue.serverTimestamp(),
        'read': false,
      },
      {
        'id': 'msg_2',
        'matchId': 'match_1',
        'senderUid': 'candidate_1',
        'receiverUid': 'recruiter_1',
        'content': "Bonjour Sophie ! Merci pour votre message. Le poste m'intéresse également.",
        'sentAt': FieldValue.serverTimestamp(),
        'read': true,
      },
      {
        'id': 'msg_3',
        'matchId': 'match_1',
        'senderUid': 'recruiter_1',
        'receiverUid': 'candidate_1',
        'content': 'Parfait ! Quand seriez-vous disponible pour un entretien ?',
        'sentAt': FieldValue.serverTimestamp(),
        'read': false,
      },
      // Messages pour match_2
      {
        'id': 'msg_4',
        'matchId': 'match_2',
        'senderUid': 'candidate_2',
        'receiverUid': 'recruiter_2',
        'content': "Bonjour Thomas ! J'ai vu votre offre React Native, elle correspond parfaitement à mon profil.",
        'sentAt': FieldValue.serverTimestamp(),
        'read': true,
      },
      {
        'id': 'msg_5',
        'matchId': 'match_2',
        'senderUid': 'recruiter_2',
        'receiverUid': 'candidate_2',
        'content': 'Excellent Marie ! Nous adorons votre expérience. Pouvez-vous nous envoyer votre CV ?',
        'sentAt': FieldValue.serverTimestamp(),
        'read': false,
      },
    ];

    for (final message in messages) {
      await _firestore.collection('messages').doc(message['id']! as String).set(message);
      print('✅ Message créé: ${message['content'].toString().substring(0, 30)}...');
    }
  }

  /// Crée des swipes de test
  static Future<void> _seedSwipes() async {
    print('👆 Création des swipes de test...');
    
    final swipes = [
      {
        'id': 'swipe_1',
        'fromUid': 'candidate_1',
        'toEntityId': 'job_1',
        'type': 'candidate→job',
        'value': 'like',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'swipe_2',
        'fromUid': 'candidate_2',
        'toEntityId': 'job_2',
        'type': 'candidate→job',
        'value': 'like',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'swipe_3',
        'fromUid': 'recruiter_1',
        'toEntityId': 'candidate_1',
        'type': 'recruiter→candidate',
        'value': 'like',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final swipe in swipes) {
      await _firestore.collection('swipes').doc(swipe['id']! as String).set(swipe);
      print('✅ Swipe créé: ${swipe['fromUid']} → ${swipe['toEntityId']} (${swipe['value']})');
    }
  }

  /// Vérifie si des données existent déjà
  static Future<bool> hasData() async {
    try {
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      final jobsSnapshot = await _firestore.collection('jobOffers').limit(1).get();
      
      return usersSnapshot.docs.isNotEmpty && jobsSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Erreur lors de la vérification des données: $e');
      return false;
    }
  }

  /// Supprime toutes les données de test
  static Future<void> clearAllData() async {
    try {
      print('🗑️ Suppression de toutes les données de test...');
      
      final collections = ['users', 'jobOffers', 'matches', 'messages', 'swipes'];
      
      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        final batch = _firestore.batch();
        
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
        print('✅ Collection $collection vidée');
      }
      
      print('✅ Toutes les données supprimées');
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
      rethrow;
    }
  }
  /// Génère un grand jeu de données de test (100 candidats, 10 recruteurs)
  static Future<void> seedLargeDataSet() async {
    try {
      print('🚀 Début de la génération massive de données...');
      
      // 1. Générer les candidats (95 en plus des 5 de base)
      await _seedRandomCandidates(95);
      
      // 2. Générer les recruteurs (8 en plus des 2 de base)
      await _seedRandomRecruiters(8);
      
      print('✅ Génération massive terminée !');
    } catch (e) {
      print('❌ Erreur lors de la génération massive: $e');
      rethrow;
    }
  }

  static Future<void> _seedRandomCandidates(int count) async {
    print('👥 Génération de $count candidats aléatoires...');
    final batchSize = 50;
    
    for (var i = 0; i < count; i += batchSize) {
      final batch = _firestore.batch();
      final end = (i + batchSize < count) ? i + batchSize : count;
      
      for (var j = i; j < end; j++) {
        final gender = j % 2 == 0 ? 'female' : 'male';
        final firstName = _getRandomElement(gender == 'female' ? _femaleFirstNames : _maleFirstNames);
        final lastName = _getRandomElement(_lastNames);
        final job = _getRandomElement(_jobTitles);
        final uid = 'candidate_auto_$j';
        
        final user = {
          'uid': uid,
          'email': '${firstName.toLowerCase()}.${lastName.toLowerCase()}$j@example.com',
          'firstName': firstName,
          'lastName': lastName,
          'name': '$firstName $lastName',
          'role': 'candidate',
          'isRecruiter': false,
          'jobTitle': job,
          'experience': '${_getRandomInt(1, 10)} ans',
          'location': _getRandomElement(_locations),
          'skills': _getRandomSublist(_skills, 3, 6),
          'about': "Passionné(e) par $job, je cherche de nouvelles opportunités.",
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isOnline': _getRandomBool(),
        };
        
        batch.set(_firestore.collection('users').doc(uid), user);
      }
      
      await batch.commit();
      print('  - Lot de ${end - i} candidats créé');
    }
  }

  static Future<void> _seedRandomRecruiters(int count) async {
    print('🏢 Génération de $count recruteurs aléatoires...');
    final batch = _firestore.batch();
    
    for (var i = 0; i < count; i++) {
      final gender = i % 2 == 0 ? 'female' : 'male';
      final firstName = _getRandomElement(gender == 'female' ? _femaleFirstNames : _maleFirstNames);
      final lastName = _getRandomElement(_lastNames);
      final company = _getRandomElement(_companies);
      final uid = 'recruiter_auto_$i';
      
      final user = {
        'uid': uid,
        'email': 'rh_$i@${company.toLowerCase().replaceAll(' ', '')}.com',
        'firstName': firstName,
        'lastName': lastName,
        'name': '$firstName $lastName',
        'role': 'recruiter',
        'isRecruiter': true,
        'companyName': company,
        'jobTitle': 'Talent Acquisition Manager',
        'location': _getRandomElement(_locations),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isOnline': _getRandomBool(),
      };
      
      batch.set(_firestore.collection('users').doc(uid), user);
      
      // Créer 2-3 offres pour ce recruteur
      final offersCount = _getRandomInt(2, 4);
      for (var k = 0; k < offersCount; k++) {
        final jobTitle = _getRandomElement(_jobTitles);
        final offerId = 'job_auto_${i}_$k';
        
        final offer = {
          'id': offerId,
          'title': jobTitle,
          'company': company,
          'location': _getRandomElement(_locations),
          'type': _getRandomElement(['CDI', 'CDD', 'Freelance']),
          'salary': '${_getRandomInt(35, 80)}k€',
          'experience': '${_getRandomInt(2, 8)} ans',
          'description': 'Nous recherchons un $jobTitle passionné pour rejoindre notre équipe chez $company.',
          'requirements': _getRandomSublist(_skills, 4, 8),
          'benefits': _getRandomSublist(['Télétravail', 'Mutuelle', 'Tickets resto', 'Transport', 'Salle de sport', 'Crèche'], 2, 4),
          'postedBy': uid,
          'isActive': true,
          'postedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        batch.set(_firestore.collection('jobOffers').doc(offerId), offer);
      }
    }
    
    await batch.commit();
  }

  // Helpers pour la génération aléatoire
  static T _getRandomElement<T>(List<T> list) {
    return list[DateTime.now().microsecondsSinceEpoch % list.length];
  }
  
  static int _getRandomInt(int min, int max) {
    return min + (DateTime.now().microsecondsSinceEpoch % (max - min + 1));
  }
  
  static bool _getRandomBool() {
    return DateTime.now().microsecondsSinceEpoch % 2 == 0;
  }
  
  static List<T> _getRandomSublist<T>(List<T> list, int min, int max) {
    final count = _getRandomInt(min, max);
    final shuffled = List<T>.from(list)..shuffle();
    return shuffled.take(count).toList();
  }

  // Données statiques pour la génération
  static const _maleFirstNames = ['Thomas', 'Nicolas', 'Julien', 'Pierre', 'Alexandre', 'Maxime', 'Lucas', 'Antoine', 'Kevin', 'David', 'Paul', 'Louis', 'Romain', 'Florian', 'Guillaume'];
  static const _femaleFirstNames = ['Marie', 'Sophie', 'Julie', 'Camille', 'Laura', 'Sarah', 'Emma', 'Léa', 'Chloé', 'Manon', 'Elodie', 'Céline', 'Audrey', 'Claire', 'Mathilde'];
  static const _lastNames = ['Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Richard', 'Petit', 'Durand', 'Leroy', 'Moreau', 'Simon', 'Laurent', 'Lefebvre', 'Michel', 'Garcia'];
  static const _jobTitles = ['Développeur Flutter', 'Développeur React', 'Développeur Backend', 'Data Scientist', 'Product Manager', 'UX Designer', 'UI Designer', 'DevOps Engineer', 'Chef de Projet', 'Développeur Fullstack', 'Architecte Cloud', 'Développeur iOS', 'Développeur Android'];
  static const _locations = ['Paris', 'Lyon', 'Marseille', 'Bordeaux', 'Lille', 'Toulouse', 'Nantes', 'Strasbourg', 'Montpellier', 'Rennes', 'Nice', 'Remote'];
  static const _companies = ['TechCorp', 'StartupIO', 'BigData Systems', 'CloudNine', 'WebAgency', 'MobileFirst', 'InnovateTech', 'FutureSoft', 'DataViz', 'SmartApps'];
  static const _skills = ['Flutter', 'Dart', 'React', 'JavaScript', 'TypeScript', 'Node.js', 'Python', 'Java', 'Kotlin', 'Swift', 'AWS', 'Docker', 'Kubernetes', 'Firebase', 'MongoDB', 'PostgreSQL', 'Git', 'Agile', 'Scrum', 'Figma', 'Adobe XD'];
}
