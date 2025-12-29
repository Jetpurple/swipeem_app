import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hire_me/models/user_model.dart';

class AdminTestDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Mot de passe par défaut pour tous les comptes de test
  static const String _defaultPassword = 'password123';

  /// Créer l'utilisateur admin
  static Future<void> createAdminUser() async {
    print('👑 Création de l\'utilisateur admin...');
    
    const adminEmail = 'admin@hireme.com';
    const adminUid = 'admin_user';
    
    try {
      // Créer le compte Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: _defaultPassword,
      );
      
      // Mettre à jour l'UID pour correspondre à notre convention
      await userCredential.user?.updateDisplayName('Admin HireMe');
      
      print('🔐 Compte Auth créé pour admin@hireme.com');
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('ℹ️ Le compte Auth admin existe déjà');
      } else {
        print('❌ Erreur lors de la création du compte Auth: $e');
      }
    }
    
    // Vérifier si l'admin existe déjà dans Firestore
    final adminDoc = await _firestore.collection('users').doc(adminUid).get();
    if (adminDoc.exists) {
      print('ℹ️ L\'utilisateur admin existe déjà dans Firestore');
      return;
    }
    
    final adminUser = UserModel(
      uid: adminUid,
      email: adminEmail,
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
    
    await _firestore.collection('users').doc(adminUid).set(adminUser.toFirestore());
    print('✅ Utilisateur admin créé avec succès');
    print('📧 Email: admin@hireme.com');
    print('🔑 Mot de passe: $_defaultPassword');
  }

  /// Créer des utilisateurs de test supplémentaires
  static Future<void> createTestUsers() async {
    print('👥 Création des utilisateurs de test...');
    
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
      await _createUserWithAuth(
        uid: candidate['uid'] as String,
        email: candidate['email'] as String,
        firstName: candidate['firstName'] as String,
        lastName: candidate['lastName'] as String,
        jobTitle: candidate['jobTitle'] as String,
        skills: List<String>.from(candidate['skills'] as List),
        isRecruiter: candidate['isRecruiter'] as bool,
        companyName: null,
      );
    }
    
    // Créer les recruteurs
    for (final recruiter in recruiters) {
      await _createUserWithAuth(
        uid: recruiter['uid'] as String,
        email: recruiter['email'] as String,
        firstName: recruiter['firstName'] as String,
        lastName: recruiter['lastName'] as String,
        jobTitle: recruiter['jobTitle'] as String,
        skills: List<String>.from(recruiter['skills'] as List),
        isRecruiter: recruiter['isRecruiter'] as bool,
        companyName: recruiter['companyName'] as String,
      );
    }
    
    print('✅ Utilisateurs de test créés avec succès');
    print('🔑 Mot de passe pour tous les comptes: $_defaultPassword');
  }

  /// Méthode helper pour créer un utilisateur avec Auth et Firestore
  static Future<void> _createUserWithAuth({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String jobTitle,
    required List<String> skills,
    required bool isRecruiter,
    String? companyName,
  }) async {
    try {
      // Créer le compte Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _defaultPassword,
      );
      
      // Mettre à jour le nom d'affichage
      await userCredential.user?.updateDisplayName('$firstName $lastName');
      
      print('🔐 Compte Auth créé pour $email');
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('ℹ️ Le compte Auth $email existe déjà');
      } else {
        print('❌ Erreur lors de la création du compte Auth pour $email: $e');
      }
    }
    
    // Vérifier si l'utilisateur existe déjà dans Firestore
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      print('ℹ️ L\'utilisateur $uid existe déjà dans Firestore');
      return;
    }
    
    // Créer l'utilisateur dans Firestore
    final user = UserModel(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      jobTitle: jobTitle,
      skills: skills,
      isRecruiter: isRecruiter,
      isAdmin: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOnline: true,
      companyName: companyName,
    );
    
    await _firestore.collection('users').doc(uid).set(user.toFirestore());
    print('✅ Utilisateur $firstName $lastName créé dans Firestore');
  }

  /// Créer des posts supplémentaires pour l'admin
  static Future<void> createAdminPosts() async {
    print('📝 Création des posts de l\'admin...');
    
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
      await _firestore.collection('posts').add({
        ...post,
        'authorUid': adminUid,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    }
    
    print('✅ Posts de l\'admin créés avec succès');
  }

  /// Créer des messages de test entre différents utilisateurs
  static Future<void> createTestMessages() async {
    print('💬 Création des messages de test supplémentaires...');
    
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
      final matchDoc = await _firestore.collection('matches').add({
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
        
        await _firestore.collection('messages').add({
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
      await _firestore.collection('matches').doc(matchId).update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageContent': testMessages[messageCount - 1],
        'lastMessageSenderUid': messageCount % 2 == 0 ? recruiterUid : candidateUid,
      });
    }
    
    print('✅ Messages de test supplémentaires créés avec succès');
  }

  /// Créer toutes les données de test avec admin
  static Future<void> createAllAdminTestData() async {
    print('🚀 Création de toutes les données de test avec admin...');
    
    await createAdminUser();
    await createTestUsers();
    await createAdminPosts();
    await createTestMessages();
    
    print('✅ Toutes les données de test avec admin ont été créées !');
    _printLoginCredentials();
  }

  /// Afficher tous les identifiants de connexion
  static void _printLoginCredentials() {
    print('\n🔐 ===== IDENTIFIANTS DE CONNEXION =====');
    print('Mot de passe pour tous les comptes: $_defaultPassword');
    print('');
    
    print('👑 ADMIN:');
    print('  Email: admin@hireme.com');
    print('  Mot de passe: $_defaultPassword');
    print('');
    
    print('👥 CANDIDATS:');
    print('  Email: marie.dupont@email.com');
    print('  Email: pierre.martin@email.com');
    print('  Email: sophie.bernard@email.com');
    print('  Email: thomas.leroy@email.com');
    print('  Email: laura.simon@email.com');
    print('');
    
    print('🏢 RECRUTEURS:');
    print('  Email: jean.recruteur@techcorp.com');
    print('  Email: sarah.hr@startup.io');
    print('');
    
    print('🔑 Mot de passe pour tous: $_defaultPassword');
    print('==========================================\n');
  }

  /// Méthode publique pour afficher les identifiants
  static void printLoginCredentials() {
    _printLoginCredentials();
  }
}
