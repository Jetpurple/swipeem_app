import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hire_me/models/user_model.dart';
import 'package:hire_me/services/test_data_service.dart';

/// Script pour créer des données de test avec un utilisateur admin
/// 
/// Utilisation:
/// dart run lib/scripts/create_admin_test_data.dart
/// 
/// Ou depuis le terminal:
/// flutter run lib/scripts/create_admin_test_data.dart
void main() async {
  print('🚀 Démarrage de la création des données de test avec admin...');
  
  try {
    // Créer l'utilisateur admin
    await _createAdminUser();
    
    // Créer des utilisateurs de test supplémentaires
    await _createTestUsers();
    
    // Créer toutes les données de test
    await TestDataService.createAllTestData();
    
    // Créer des données de test supplémentaires pour l'admin
    await _createAdminTestData();
    
    print('✅ Toutes les données de test ont été créées avec succès !');
    print('');
    print('📊 Résumé des données créées:');
    print('• Utilisateur admin: admin@hireme.com (isAdmin: true)');
    print('• Utilisateurs de test: 5 candidats + 3 recruteurs');
    print('• Messages: 20+ messages variés entre utilisateurs');
    print("• Annonces d'emploi: 10 offres réalistes");
    print('• Posts: 5+ annonces/posts');
    print('• Matches: 5+ conversations actives');
    print('');
    print('🔑 Connexion admin:');
    print('Email: admin@hireme.com');
    print('Mot de passe: admin123');
    print('');
    print('💡 Vous pouvez maintenant tester votre application avec ces données !');
    
  } catch (e) {
    print('❌ Erreur lors de la création des données: $e');
    print('');
    print('🔧 Vérifiez que:');
    print('• Firebase est correctement configuré');
    print("• Les règles Firestore autorisent l'écriture");
  }
}

/// Créer l'utilisateur admin
Future<void> _createAdminUser() async {
  print('👑 Création de l\'utilisateur admin...');
  
  final firestore = FirebaseFirestore.instance;
  const adminUid = 'admin_user';
  
  // Vérifier si l'admin existe déjà
  final adminDoc = await firestore.collection('users').doc(adminUid).get();
  if (adminDoc.exists) {
    print('ℹ️ L\'utilisateur admin existe déjà');
    return;
  }
  
  final adminUser = UserModel(
    uid: adminUid,
    email: 'admin@hireme.com',
    firstName: 'Admin',
    lastName: 'HireMe',
    companyName: 'HireMe Platform',
    jobTitle: 'Administrateur',
    isRecruiter: true,
    isAdmin: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isOnline: true,
    skills: ['Administration', 'Gestion', 'Recrutement', 'Flutter', 'Firebase'],
  );
  
  await firestore.collection('users').doc(adminUid).set(adminUser.toFirestore());
  print('✅ Utilisateur admin créé avec succès');
}

/// Créer des utilisateurs de test supplémentaires
Future<void> _createTestUsers() async {
  print('👥 Création des utilisateurs de test...');
  
  final firestore = FirebaseFirestore.instance;
  
  // Candidats de test
  final candidates = [
    {
      'uid': 'candidate_1',
      'email': 'marie.dupont@email.com',
      'firstName': 'Marie',
      'lastName': 'Dupont',
      'jobTitle': 'Développeuse Flutter',
      'skills': ['Flutter', 'Dart', 'Firebase', 'Git', 'Mobile'],
      'isRecruiter': false,
    },
    {
      'uid': 'candidate_2',
      'email': 'pierre.martin@email.com',
      'firstName': 'Pierre',
      'lastName': 'Martin',
      'jobTitle': 'Développeur Full-Stack',
      'skills': ['React', 'Node.js', 'PostgreSQL', 'AWS', 'Docker'],
      'isRecruiter': false,
    },
    {
      'uid': 'candidate_3',
      'email': 'sophie.bernard@email.com',
      'firstName': 'Sophie',
      'lastName': 'Bernard',
      'jobTitle': 'UX/UI Designer',
      'skills': ['Figma', 'Adobe XD', 'Prototypage', 'User Research', 'Design System'],
      'isRecruiter': false,
    },
    {
      'uid': 'candidate_4',
      'email': 'thomas.leroy@email.com',
      'firstName': 'Thomas',
      'lastName': 'Leroy',
      'jobTitle': 'DevOps Engineer',
      'skills': ['AWS', 'Docker', 'Kubernetes', 'Terraform', 'CI/CD'],
      'isRecruiter': false,
    },
    {
      'uid': 'candidate_5',
      'email': 'laura.simon@email.com',
      'firstName': 'Laura',
      'lastName': 'Simon',
      'jobTitle': 'Product Manager',
      'skills': ['Product Management', 'Agile', 'Analytics', 'Strategy', 'Communication'],
      'isRecruiter': false,
    },
  ];
  
  // Recruteurs de test
  final recruiters = [
    {
      'uid': 'recruiter_2',
      'email': 'jean.recruteur@techcorp.com',
      'firstName': 'Jean',
      'lastName': 'Recruteur',
      'companyName': 'TechCorp France',
      'jobTitle': 'Responsable RH',
      'skills': ['Recrutement', 'RH', 'Management', 'Communication'],
      'isRecruiter': true,
    },
    {
      'uid': 'recruiter_3',
      'email': 'sarah.hr@startup.io',
      'firstName': 'Sarah',
      'lastName': 'Johnson',
      'companyName': 'StartupIO',
      'jobTitle': 'Talent Acquisition',
      'skills': ['Recrutement', 'Startup', 'Tech', 'Networking'],
      'isRecruiter': true,
    },
  ];
  
  // Créer les candidats
  for (final candidate in candidates) {
    final user = UserModel(
      uid: candidate['uid'] as String,
      email: candidate['email'] as String,
      firstName: candidate['firstName'] as String,
      lastName: candidate['lastName'] as String,
      jobTitle: candidate['jobTitle'] as String,
      skills: List<String>.from(candidate['skills'] as List),
      isRecruiter: candidate['isRecruiter'] as bool,
      isAdmin: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOnline: true,
    );
    
    await firestore.collection('users').doc(candidate['uid'] as String).set(user.toFirestore());
  }
  
  // Créer les recruteurs
  for (final recruiter in recruiters) {
    final user = UserModel(
      uid: recruiter['uid'] as String,
      email: recruiter['email'] as String,
      firstName: recruiter['firstName'] as String,
      lastName: recruiter['lastName'] as String,
      companyName: recruiter['companyName'] as String,
      jobTitle: recruiter['jobTitle'] as String,
      skills: List<String>.from(recruiter['skills'] as List),
      isRecruiter: recruiter['isRecruiter'] as bool,
      isAdmin: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOnline: true,
    );
    
    await firestore.collection('users').doc(recruiter['uid'] as String).set(user.toFirestore());
  }
  
  print('✅ Utilisateurs de test créés avec succès');
}

/// Créer des données de test supplémentaires pour l'admin
Future<void> _createAdminTestData() async {
  print('📝 Création des données de test supplémentaires pour l\'admin...');
  
  final firestore = FirebaseFirestore.instance;
  const adminUid = 'admin_user';
  
  // Posts supplémentaires créés par l'admin
  final adminPosts = [
    {
      'title': 'Recrutement urgent : Développeur Flutter Senior',
      'content': 'Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe mobile. Projet passionnant avec une équipe dynamique. Télétravail possible.',
      'tags': ['Flutter', 'Mobile', 'Télétravail', 'Urgent', 'Senior'],
    },
    {
      'title': 'Offre d\'emploi : Chef de projet digital',
      'content': 'Poste de chef de projet digital disponible dans notre agence. Gestion d\'équipe, projets clients internationaux. Excellente ambiance de travail.',
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
    {
      'title': 'Recrutement : Data Scientist',
      'content': 'Nous cherchons un data scientist pour nos projets d\'intelligence artificielle. Machine learning, Python, TensorFlow requis.',
      'tags': ['Data Science', 'AI', 'Machine Learning', 'Python'],
    },
    {
      'title': 'Offre : Product Manager',
      'content': 'Poste de product manager disponible. Définition de stratégie produit, interface business-technique. Expérience requise.',
      'tags': ['Product Management', 'Strategy', 'Business', 'Tech'],
    },
  ];
  
  // Créer les posts de l'admin
  for (final post in adminPosts) {
    await firestore.collection('posts').add({
      ...post,
      'authorUid': adminUid,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }
  
  // Créer des messages de test entre différents utilisateurs
  await _createTestMessages();
  
  print('✅ Données de test supplémentaires créées avec succès');
}

/// Créer des messages de test entre différents utilisateurs
Future<void> _createTestMessages() async {
  print('💬 Création des messages de test supplémentaires...');
  
  final firestore = FirebaseFirestore.instance;
  
  // Messages de test variés
  final testMessages = [
    "Salut ! J'ai vu votre profil et je suis très intéressé par votre expérience.",
    "Bonjour ! Votre profil correspond parfaitement à ce que nous recherchons.",
    "Merci pour votre candidature ! Nous aimerions en savoir plus sur vos projets.",
    "Parfait ! J'ai hâte de collaborer avec vous.",
    "Excellent profil ! Nous avons plusieurs postes qui pourraient vous intéresser.",
    "Bonjour ! J'ai remarqué votre expertise. Nous cherchons quelqu'un avec ce profil !",
    "Salut ! Votre expérience m'impressionne. Avez-vous déjà travaillé dans ce secteur ?",
    "Parfait ! Nous avons une équipe dynamique. Êtes-vous intéressé par le télétravail ?",
    "Bonjour ! Votre profil correspond exactement à nos besoins.",
    "Excellent ! Nous offrons de très bonnes conditions.",
  ];
  
  // Créer des matches et messages entre différents utilisateurs
  final userPairs = [
    ['recruiter_2', 'candidate_1'],
    ['recruiter_3', 'candidate_2'],
    ['admin_user', 'candidate_3'],
    ['recruiter_2', 'candidate_4'],
    ['recruiter_3', 'candidate_5'],
  ];
  
  for (int i = 0; i < userPairs.length; i++) {
    final recruiterUid = userPairs[i][0];
    final candidateUid = userPairs[i][1];
    
    // Créer un match
    final matchDoc = await firestore.collection('matches').add({
      'candidateUid': candidateUid,
      'recruiterUid': recruiterUid,
      'matchedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'readBy': {candidateUid: false, recruiterUid: false},
    });
    
    final matchId = matchDoc.id;
    
    // Créer 3-4 messages pour chaque match
    final messageCount = 3 + (i % 2);
    for (int j = 0; j < messageCount; j++) {
      final isFromRecruiter = j % 2 == 0;
      final senderUid = isFromRecruiter ? recruiterUid : candidateUid;
      final receiverUid = isFromRecruiter ? candidateUid : recruiterUid;
      
      await firestore.collection('messages').add({
        'matchId': matchId,
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'content': testMessages[j % testMessages.length],
        'type': 'text',
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': j < messageCount - 1,
        'readAt': j < messageCount - 1 ? FieldValue.serverTimestamp() : null,
      });
    }
    
    // Mettre à jour le match avec le dernier message
    await firestore.collection('matches').doc(matchId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageContent': testMessages[messageCount - 1],
      'lastMessageSenderUid': messageCount % 2 == 0 ? recruiterUid : candidateUid,
    });
  }
  
  print('✅ Messages de test supplémentaires créés avec succès');
}
