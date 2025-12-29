import 'package:cloud_firestore/cloud_firestore.dart';

class TestDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Messages de test variés
  static final List<Map<String, dynamic>> _testMessages = [
    {
      'content': "Salut ! J'ai vu votre profil et je suis très intéressé par votre expérience en Flutter. Avez-vous un moment pour discuter ?",
      'type': 'text',
    },
    {
      'content': 'Bonjour ! Votre profil correspond parfaitement à ce que nous recherchons. Seriez-vous disponible pour un entretien cette semaine ?',
      'type': 'text',
    },
    {
      'content': 'Merci pour votre candidature ! Nous aimerions en savoir plus sur vos projets récents. Pouvez-vous partager votre portfolio ?',
      'type': 'text',
    },
    {
      'content': "Parfait ! J'ai hâte de collaborer avec vous. À quelle heure préférez-vous programmer notre prochaine réunion ?",
      'type': 'text',
    },
    {
      'content': 'Excellent profil ! Nous avons plusieurs postes qui pourraient vous intéresser. Voulez-vous que je vous envoie les détails ?',
      'type': 'text',
    },
    {
      'content': "Bonjour ! J'ai remarqué votre expertise en React Native. Nous cherchons quelqu'un avec exactement ce profil !",
      'type': 'text',
    },
    {
      'content': "Salut ! Votre expérience en gestion de projet m'impressionne. Avez-vous déjà travaillé dans le secteur de la fintech ?",
      'type': 'text',
    },
    {
      'content': 'Parfait ! Nous avons une équipe dynamique et des projets passionnants. Êtes-vous intéressé par le télétravail ?',
      'type': 'text',
    },
    {
      'content': 'Bonjour ! Votre profil correspond exactement à nos besoins. Quand seriez-vous disponible pour commencer ?',
      'type': 'text',
    },
    {
      'content': 'Excellent ! Nous offrons de très bonnes conditions. Voulez-vous que je vous envoie le package complet ?',
      'type': 'text',
    },
    {
      'content': "Salut ! J'ai vu vos projets sur GitHub, impressionnant ! Avez-vous déjà travaillé avec Firebase ?",
      'type': 'text',
    },
    {
      'content': 'Bonjour ! Nous cherchons un développeur full-stack. Votre profil semble parfait pour ce poste !',
      'type': 'text',
    },
    {
      'content': "Parfait ! Nous avons des projets innovants en cours. Êtes-vous intéressé par l'intelligence artificielle ?",
      'type': 'text',
    },
    {
      'content': "Salut ! Votre expérience en startup m'intéresse beaucoup. Avez-vous déjà levé des fonds ?",
      'type': 'text',
    },
    {
      'content': "Bonjour ! Nous cherchons quelqu'un pour diriger notre équipe technique. Votre profil semble idéal !",
      'type': 'text',
    },
    {
      'content': "Excellent ! Nous avons une culture d'entreprise très ouverte. Avez-vous des questions sur notre équipe ?",
      'type': 'text',
    },
    {
      'content': "Parfait ! Nous offrons de nombreuses opportunités d'évolution. Êtes-vous intéressé par le management ?",
      'type': 'text',
    },
    {
      'content': 'Salut ! Votre portfolio est très impressionnant. Avez-vous déjà travaillé sur des applications mobiles grand public ?',
      'type': 'text',
    },
    {
      'content': "Bonjour ! Nous cherchons quelqu'un de créatif et technique. Votre profil semble parfait !",
      'type': 'text',
    },
    {
      'content': 'Excellent ! Nous avons des défis techniques passionnants. Êtes-vous prêt à relever le défi ?',
      'type': 'text',
    },
  ];

  // Annonces d'emploi de test
  static final List<Map<String, dynamic>> _testJobOffers = [
    {
      'title': 'Développeur Flutter Senior',
      'company': 'TechCorp France',
      'location': 'Paris, France',
      'type': 'CDI',
      'salary': '50-65k€',
      'experience': '3-5 ans',
      'description': "Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe mobile en pleine expansion. Vous travaillerez sur des applications innovantes utilisées par des millions d'utilisateurs.",
      'requirements': ['Flutter', 'Dart', 'Firebase', 'Git', 'Agile', 'CI/CD'],
      'benefits': ['Télétravail hybride', 'Mutuelle premium', 'Tickets resto', 'Formation continue', 'Prime performance'],
      'isActive': true,
    },
    {
      'title': 'Développeuse React Native',
      'company': 'StartupIO',
      'location': 'Lyon, France',
      'type': 'CDI',
      'salary': '45-55k€',
      'experience': '2-4 ans',
      'description': 'Rejoignez notre startup en pleine croissance ! Nous développons des solutions mobiles innovantes pour le secteur de la santé. Équipe jeune et dynamique.',
      'requirements': ['React Native', 'JavaScript', 'Redux', 'API REST', 'TypeScript'],
      'benefits': ['Equity', 'Télétravail', 'Matériel fourni', 'Formation', 'Horaires flexibles'],
      'isActive': true,
    },
    {
      'title': 'Chef de projet digital',
      'company': 'Digital Agency Pro',
      'location': 'Marseille, France',
      'type': 'CDI',
      'salary': '55-70k€',
      'experience': '5+ ans',
      'description': "Pilotez nos projets digitaux innovants pour nos clients internationaux. Leadership d'équipe et gestion de projets complexes.",
      'requirements': ['Gestion de projet', 'Agile/Scrum', 'Digital', 'Leadership', 'Communication'],
      'benefits': ['Télétravail', 'Mutuelle', 'Prime', 'Formation', 'Véhicule de fonction'],
      'isActive': true,
    },
    {
      'title': 'Développeur Full-Stack',
      'company': 'FinTech Solutions',
      'location': 'Toulouse, France',
      'type': 'CDI',
      'salary': '48-62k€',
      'experience': '3-6 ans',
      'description': 'Développez des solutions financières innovantes. Stack moderne : Node.js, React, PostgreSQL, AWS.',
      'requirements': ['Node.js', 'React', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes'],
      'benefits': ['Télétravail', 'Mutuelle', 'Tickets resto', 'Formation', 'Prime'],
      'isActive': true,
    },
    {
      'title': 'UX/UI Designer',
      'company': 'Creative Studio',
      'location': 'Nantes, France',
      'type': 'CDI',
      'salary': '42-55k€',
      'experience': '2-4 ans',
      'description': 'Créez des expériences utilisateur exceptionnelles pour nos applications mobiles et web. Collaboration étroite avec les développeurs.',
      'requirements': ['Figma', 'Adobe Creative Suite', 'Prototypage', 'User Research', 'Design System'],
      'benefits': ['Télétravail', 'Mutuelle', 'Matériel', 'Formation', 'Horaires flexibles'],
      'isActive': true,
    },
    {
      'title': 'DevOps Engineer',
      'company': 'CloudTech',
      'location': 'Bordeaux, France',
      'type': 'CDI',
      'salary': '52-68k€',
      'experience': '4-7 ans',
      'description': 'Optimisez notre infrastructure cloud et automatisez nos processus de déploiement. Environnement technique stimulant.',
      'requirements': ['AWS/Azure', 'Docker', 'Kubernetes', 'Terraform', 'CI/CD', 'Monitoring'],
      'benefits': ['Télétravail', 'Mutuelle', 'Formation', 'Prime', 'Matériel'],
      'isActive': true,
    },
    {
      'title': 'Data Scientist',
      'company': 'AI Innovations',
      'location': 'Lille, France',
      'type': 'CDI',
      'salary': '50-65k€',
      'experience': '3-5 ans',
      'description': "Développez des modèles d'intelligence artificielle pour optimiser nos processus métier. Projets innovants et impact business.",
      'requirements': ['Python', 'Machine Learning', 'TensorFlow', 'SQL', 'Statistics', 'Big Data'],
      'benefits': ['Télétravail', 'Mutuelle', 'Formation', 'Prime', 'Recherche'],
      'isActive': true,
    },
    {
      'title': 'Product Manager',
      'company': 'SaaS Solutions',
      'location': 'Strasbourg, France',
      'type': 'CDI',
      'salary': '60-75k€',
      'experience': '4-6 ans',
      'description': 'Définissez la stratégie produit et pilotez le développement de nos solutions SaaS. Interface entre business et technique.',
      'requirements': ['Product Management', 'Agile', 'Analytics', 'Communication', 'Strategy'],
      'benefits': ['Télétravail', 'Mutuelle', 'Prime', 'Formation', 'Stock options'],
      'isActive': true,
    },
    {
      'title': 'Développeur Backend',
      'company': 'API Company',
      'location': 'Montpellier, France',
      'type': 'CDI',
      'salary': '46-60k€',
      'experience': '2-5 ans',
      'description': 'Développez des APIs robustes et performantes. Architecture microservices et technologies modernes.',
      'requirements': ['Java/Spring', 'Python/Django', 'PostgreSQL', 'Redis', 'Docker', 'API Design'],
      'benefits': ['Télétravail', 'Mutuelle', 'Formation', 'Prime', 'Horaires flexibles'],
      'isActive': true,
    },
    {
      'title': 'Mobile Developer iOS',
      'company': 'App Studio',
      'location': 'Nice, France',
      'type': 'CDI',
      'salary': '48-63k€',
      'experience': '3-5 ans',
      'description': 'Développez des applications iOS natives de qualité. Collaboration avec une équipe créative et technique.',
      'requirements': ['Swift', 'UIKit', 'SwiftUI', 'Core Data', 'Git', 'Agile'],
      'benefits': ['Télétravail', 'Mutuelle', 'Matériel', 'Formation', 'Prime'],
      'isActive': true,
    },
  ];

  // Posts/annonces de test
  static final List<Map<String, dynamic>> _testPosts = [
    {
      'title': 'Recrutement urgent : Développeur Flutter',
      'content': 'Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe. Projet passionnant avec une équipe dynamique. Télétravail possible.',
      'tags': ['Flutter', 'Mobile', 'Télétravail', 'Urgent'],
    },
    {
      'title': "Offre d'emploi : Chef de projet digital",
      'content': "Poste de chef de projet digital disponible dans notre agence. Gestion d'équipe, projets clients internationaux. Excellente ambiance de travail.",
      'tags': ['Management', 'Digital', 'Projet', 'International'],
    },
    {
      'title': 'Recherche développeur full-stack',
      'content': 'Nous cherchons un développeur full-stack pour nos projets web et mobile. Stack moderne, équipe jeune et motivée.',
      'tags': ['Full-stack', 'Web', 'Mobile', 'Startup'],
    },
    {
      'title': 'Opportunité : UX/UI Designer',
      'content': 'Rejoignez notre équipe créative ! Nous cherchons un designer talentueux pour nos applications. Portfolio requis.',
      'tags': ['Design', 'UX', 'UI', 'Créatif'],
    },
    {
      'title': 'Poste DevOps disponible',
      'content': 'Ingénieur DevOps recherché pour optimiser notre infrastructure cloud. Technologies modernes, environnement stimulant.',
      'tags': ['DevOps', 'Cloud', 'Infrastructure', 'Technique'],
    },
  ];

  // Garantir que recruiter_1 existe dans la base de données
  static Future<String?> _ensureRecruiter1Exists() async {
    const recruiterUid = 'recruiter_1';
    
    // Chercher par le champ uid au lieu de l'ID du document
    final recruiterQuery = await _firestore
        .collection('users')
        .where('uid', isEqualTo: recruiterUid)
        .limit(1)
        .get();
    
    if (recruiterQuery.docs.isNotEmpty) {
      return recruiterUid;
    }
    
    // Si l'utilisateur n'existe pas, chercher par ID du document
    final recruiterDoc = await _firestore.collection('users').doc(recruiterUid).get();
    if (recruiterDoc.exists) {
      return recruiterUid;
    }
    
    // Si toujours pas trouvé, créer l'utilisateur
    print('⚠️ Le recruteur recruiter_1 n\'existe pas. Création en cours...');
    try {
      await _firestore.collection('users').doc(recruiterUid).set({
        'uid': recruiterUid,
        'email': 'recruiter1@example.com',
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
      });
      print('✅ Utilisateur recruiter_1 créé avec succès');
      return recruiterUid;
    } catch (e) {
      print('❌ Erreur lors de la création de recruiter_1: $e');
      return null;
    }
  }

  // Créer des messages de test
  static Future<void> createTestMessages() async {
    print('💬 Création des messages de test...');
    
    try {
      // Garantir que recruiter_1 existe
      final recruiterUid = await _ensureRecruiter1Exists();
      if (recruiterUid == null) {
        print("❌ Impossible de créer ou trouver le recruteur recruiter_1");
        return;
      }
      
      // Récupérer d'autres utilisateurs (candidats)
      final usersSnapshot = await _firestore
          .collection('users')
          .where('isRecruiter', isEqualTo: false)
          .limit(5)
          .get();
      
      if (usersSnapshot.docs.isEmpty) {
        print('❌ Aucun candidat trouvé pour créer des messages');
        return;
      }

      final candidates = usersSnapshot.docs;
      final candidateIds = candidates.map((doc) => doc.id).toList();

      // Créer des matches de test entre recruiter_1 et les candidats
      final matchIds = <String>[];
      for (var i = 0; i < candidateIds.length; i++) {
        final candidateUid = candidateIds[i];
        
        final matchDoc = await _firestore.collection('matches').add({
          'candidateUid': candidateUid,
          'recruiterUid': recruiterUid,
          'matchedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'readBy': {candidateUid: false, recruiterUid: false},
        });
        matchIds.add(matchDoc.id);
      }

      // Créer des messages pour chaque match
      for (var i = 0; i < matchIds.length; i++) {
        final matchId = matchIds[i];
        final candidateUid = candidateIds[i];
        
        // Créer 3-5 messages par match
        final messageCount = 3 + (i % 3);
        for (var j = 0; j < messageCount; j++) {
          final isFromRecruiter = j % 2 == 0;
          final senderUid = isFromRecruiter ? recruiterUid : candidateUid;
          final receiverUid = isFromRecruiter ? candidateUid : recruiterUid;
          
          final message = _testMessages[j % _testMessages.length];
          
          await _firestore.collection('messages').add({
            'matchId': matchId,
            'senderUid': senderUid,
            'receiverUid': receiverUid,
            'content': message['content'],
            'type': message['type'],
            'sentAt': FieldValue.serverTimestamp(),
            'isRead': j < messageCount - 1, // Dernier message non lu
            'readAt': j < messageCount - 1 ? FieldValue.serverTimestamp() : null,
          });
        }
        
        // Mettre à jour le match avec le dernier message
        final lastMessage = _testMessages[messageCount - 1];
        await _firestore.collection('matches').doc(matchId).update({
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessageContent': lastMessage['content'],
          'lastMessageSenderUid': messageCount % 2 == 0 ? recruiterUid : candidateUid,
        });
      }
      
      print('✅ Messages de test créés avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création des messages: $e');
    }
  }

  // Créer des annonces d'emploi de test
  static Future<void> createTestJobOffers() async {
    print("💼 Création des annonces d'emploi de test...");
    
    try {
      // Garantir que recruiter_1 existe
      final recruiterUid = await _ensureRecruiter1Exists();
      if (recruiterUid == null) {
        print("❌ Impossible de créer ou trouver le recruteur recruiter_1");
        return;
      }
      
      for (var i = 0; i < _testJobOffers.length; i++) {
        final job = _testJobOffers[i];
        
        await _firestore.collection('jobOffers').add({
          ...job,
          'postedBy': recruiterUid,
          'postedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      print("✅ Annonces d'emploi de test créées avec succès pour recruiter_1");
    } catch (e) {
      print('❌ Erreur lors de la création des annonces: $e');
    }
  }

  // Créer des posts de test
  static Future<void> createTestPosts() async {
    print('📝 Création des posts de test...');
    
    try {
      // Garantir que recruiter_1 existe
      final authorUid = await _ensureRecruiter1Exists();
      if (authorUid == null) {
        print("❌ Impossible de créer ou trouver le recruteur recruiter_1");
        return;
      }
      
      for (var i = 0; i < _testPosts.length; i++) {
        final post = _testPosts[i];
        
        await _firestore.collection('posts').add({
          ...post,
          'authorUid': authorUid,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
      
      print('✅ Posts de test créés avec succès pour recruiter_1');
    } catch (e) {
      print('❌ Erreur lors de la création des posts: $e');
    }
  }

  // Créer toutes les données de test
  static Future<void> createAllTestData() async {
    print('🚀 Création de toutes les données de test...');
    
    await createTestMessages();
    await createTestJobOffers();
    await createTestPosts();
    
    print('✅ Toutes les données de test ont été créées !');
  }

  // Nettoyer toutes les données de test
  static Future<void> cleanTestData() async {
    print('🧹 Nettoyage des données de test...');
    
    try {
      // Supprimer les messages de test
      final messagesSnapshot = await _firestore.collection('messages').get();
      for (final doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Supprimer les matches de test
      final matchesSnapshot = await _firestore.collection('matches').get();
      for (final doc in matchesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Supprimer les annonces d'emploi de test
      final jobOffersSnapshot = await _firestore.collection('jobOffers').get();
      for (final doc in jobOffersSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Supprimer les posts de test
      final postsSnapshot = await _firestore.collection('posts').get();
      for (final doc in postsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('✅ Données de test nettoyées avec succès');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }
}
