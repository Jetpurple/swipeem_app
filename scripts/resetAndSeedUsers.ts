/**
 * Script de réinitialisation et seeding des utilisateurs
 * 
 * Ce script :
 * 1. Supprime TOUS les utilisateurs de Firebase Authentication
 * 2. Supprime TOUS les documents de la collection users dans Firestore
 * 3. Supprime TOUS les matches, messages, posts, swipes et offres d'emploi (pour éviter les références orphelines)
 * 4. Recrée des utilisateurs de test (candidats et recruteurs) avec des données complètes
 * 5. Crée des matches de test entre les utilisateurs
 * 6. Crée des posts de test (recruteurs et candidats)
 * 7. Crée des offres d'emploi de test
 * 8. Crée des messages de test pour les matches
 * 9. Crée des swipes de test
 * 
 * USAGE:
 * ------
 * 
 * Mode DRY-RUN (simulation):
 *   DRY_RUN=true npm run reset:users
 * 
 * Mode PRODUCTION (modifications réelles):
 *   npm run reset:users
 * 
 * ⚠️ ATTENTION: Ce script supprime TOUTES les données utilisateurs, matches, messages, posts, swipes et offres d'emploi !
 */

import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

const DRY_RUN = process.env.DRY_RUN === 'true' || process.env.DRY_RUN === '1';
const FIRESTORE_COLLECTION = 'users';
const DEFAULT_PASSWORD = 'password123'; // Mot de passe par défaut pour tous les comptes de test

// ============================================================================
// INITIALISATION
// ============================================================================

function initializeFirebaseAdmin(): void {
  try {
    if (admin.apps.length === 0) {
      const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
      
      if (credentialsPath) {
        const fs = require('fs');
        if (!fs.existsSync(credentialsPath)) {
          console.error('\n❌ ERREUR: Le fichier de credentials n\'existe pas !');
          console.error(`   Chemin spécifié: ${credentialsPath}`);
          throw new Error(`Fichier de credentials introuvable: ${credentialsPath}`);
        }
        console.log(`📁 Utilisation des credentials: ${credentialsPath}`);
      }
      
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
      console.log('✅ Firebase Admin initialisé');
    }
  } catch (error: any) {
    console.error('❌ Erreur lors de l\'initialisation de Firebase Admin:', error);
    throw error;
  }
}

// ============================================================================
// DONNÉES DE TEST
// ============================================================================

interface TestUser {
  uid: string;
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  displayName: string;
  isRecruiter: boolean;
  isAdmin?: boolean;
  companyName?: string;
  jobTitle: string;
  bio?: string;
  skills: string[];
  hardSkills?: Array<{ name: string; level?: string }>;
  softSkills?: Array<{ name: string; level?: string }>;
  location?: string;
}

const TEST_USERS: TestUser[] = [
  // Admin
  {
    uid: 'admin_user',
    email: 'admin@hireme.com',
    password: DEFAULT_PASSWORD,
    firstName: 'Admin',
    lastName: 'HireMe',
    displayName: 'Admin HireMe',
    isRecruiter: true,
    isAdmin: true,
    companyName: 'HireMe Platform',
    jobTitle: 'Administrateur',
    skills: ['Administration', 'Gestion', 'Recrutement'],
    location: 'Paris, France',
  },
  // Candidats
  {
    uid: 'candidate_1',
    email: 'marie.dupont@email.com',
    password: DEFAULT_PASSWORD,
    firstName: 'Marie',
    lastName: 'Dupont',
    displayName: 'Marie Dupont',
    isRecruiter: false,
    jobTitle: 'Développeuse Flutter',
    bio: 'Développeuse Flutter passionnée avec 3 ans d\'expérience dans le développement mobile. Spécialisée dans la création d\'applications cross-platform performantes.',
    skills: ['Flutter', 'Dart', 'Firebase', 'Git', 'Mobile'],
    hardSkills: [
      { name: 'Flutter', level: 'Expert' },
      { name: 'Dart', level: 'Avancé' },
      { name: 'Firebase', level: 'Avancé' },
      { name: 'Git', level: 'Intermédiaire' },
    ],
    softSkills: [
      { name: 'Autonomie', level: 'Expert' },
      { name: 'Travail en équipe', level: 'Avancé' },
      { name: 'Communication', level: 'Avancé' },
    ],
    location: 'Paris, France',
  },
  {
    uid: 'candidate_2',
    email: 'pierre.martin@email.com',
    password: DEFAULT_PASSWORD,
    firstName: 'Pierre',
    lastName: 'Martin',
    displayName: 'Pierre Martin',
    isRecruiter: false,
    jobTitle: 'Développeur Full-Stack',
    bio: 'Développeur Full-Stack avec une solide expérience en React, Node.js et bases de données. Passionné par les architectures scalables et les bonnes pratiques.',
    skills: ['React', 'Node.js', 'PostgreSQL', 'AWS', 'Docker'],
    hardSkills: [
      { name: 'React', level: 'Expert' },
      { name: 'Node.js', level: 'Avancé' },
      { name: 'PostgreSQL', level: 'Avancé' },
      { name: 'AWS', level: 'Intermédiaire' },
    ],
    softSkills: [
      { name: 'Leadership', level: 'Avancé' },
      { name: 'Résolution de problèmes', level: 'Expert' },
    ],
    location: 'Lyon, France',
  },
  {
    uid: 'candidate_3',
    email: 'sophie.bernard@email.com',
    password: DEFAULT_PASSWORD,
    firstName: 'Sophie',
    lastName: 'Bernard',
    displayName: 'Sophie Bernard',
    isRecruiter: false,
    jobTitle: 'UX/UI Designer',
    bio: 'Designer UX/UI créative avec une approche centrée utilisateur. Expérience dans la conception d\'interfaces intuitives et esthétiques.',
    skills: ['Figma', 'Adobe XD', 'Prototypage', 'User Research', 'Design System'],
    hardSkills: [
      { name: 'Figma', level: 'Expert' },
      { name: 'Adobe XD', level: 'Avancé' },
      { name: 'Prototypage', level: 'Expert' },
    ],
    softSkills: [
      { name: 'Créativité', level: 'Expert' },
      { name: 'Empathie', level: 'Avancé' },
    ],
    location: 'Paris, France',
  },
  {
    uid: 'candidate_4',
    email: 'thomas.leroy@email.com',
    password: DEFAULT_PASSWORD,
    firstName: 'Thomas',
    lastName: 'Leroy',
    displayName: 'Thomas Leroy',
    isRecruiter: false,
    jobTitle: 'DevOps Engineer',
    bio: 'Ingénieur DevOps spécialisé dans l\'automatisation et l\'infrastructure cloud. Expérience avec Kubernetes, Terraform et CI/CD.',
    skills: ['AWS', 'Docker', 'Kubernetes', 'Terraform', 'CI/CD'],
    hardSkills: [
      { name: 'AWS', level: 'Expert' },
      { name: 'Docker', level: 'Expert' },
      { name: 'Kubernetes', level: 'Avancé' },
    ],
    softSkills: [
      { name: 'Organisation', level: 'Expert' },
      { name: 'Autonomie', level: 'Avancé' },
    ],
    location: 'Lyon, France',
  },
  {
    uid: 'candidate_5',
    email: 'laura.simon@email.com',
    password: DEFAULT_PASSWORD,
    firstName: 'Laura',
    lastName: 'Simon',
    displayName: 'Laura Simon',
    isRecruiter: false,
    jobTitle: 'Product Manager',
    bio: 'Product Manager avec une forte expérience dans la gestion de produits digitaux. Expertise en stratégie produit et méthodologies Agile.',
    skills: ['Product Management', 'Agile', 'Analytics', 'Strategy', 'Communication'],
    hardSkills: [
      { name: 'Product Management', level: 'Expert' },
      { name: 'Agile', level: 'Avancé' },
      { name: 'Analytics', level: 'Avancé' },
    ],
    softSkills: [
      { name: 'Communication', level: 'Expert' },
      { name: 'Leadership', level: 'Avancé' },
    ],
    location: 'Paris, France',
  },
  // Recruteurs
  {
    uid: 'recruiter_1',
    email: 'jean.recruteur@techcorp.com',
    password: DEFAULT_PASSWORD,
    firstName: 'Jean',
    lastName: 'Recruteur',
    displayName: 'Jean Recruteur',
    isRecruiter: true,
    companyName: 'TechCorp France',
    jobTitle: 'Responsable RH',
    bio: 'Responsable RH chez TechCorp, spécialisé dans le recrutement de profils tech. Passionné par la mise en relation entre talents et entreprises.',
    skills: ['Recrutement', 'RH', 'Management', 'Communication'],
    location: 'Paris, France',
  },
  {
    uid: 'recruiter_2',
    email: 'sarah.hr@startup.io',
    password: DEFAULT_PASSWORD,
    firstName: 'Sarah',
    lastName: 'Johnson',
    displayName: 'Sarah Johnson',
    isRecruiter: true,
    companyName: 'StartupIO',
    jobTitle: 'Talent Acquisition',
    bio: 'Talent Acquisition Manager dans une startup tech en pleine croissance. Recherche activement des profils développeurs et designers.',
    skills: ['Recrutement', 'Startup', 'Tech', 'Networking'],
    location: 'Lyon, France',
  },
];

// ============================================================================
// FONCTIONS DE SUPPRESSION
// ============================================================================

async function deleteAllAuthUsers(): Promise<number> {
  console.log('🗑️  Suppression de tous les utilisateurs Firebase Authentication...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la suppression de tous les utilisateurs Auth');
    return 0;
  }
  
  let deletedCount = 0;
  let nextPageToken: string | undefined;
  
  do {
    try {
      const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
      
      for (const userRecord of listUsersResult.users) {
        try {
          await admin.auth().deleteUser(userRecord.uid);
          deletedCount++;
          console.log(`  ✅ Supprimé: ${userRecord.email || userRecord.uid}`);
        } catch (error: any) {
          console.error(`  ❌ Erreur lors de la suppression de ${userRecord.uid}: ${error.message}`);
        }
      }
      
      nextPageToken = listUsersResult.pageToken;
    } catch (error: any) {
      console.error('❌ Erreur lors de la récupération des utilisateurs Auth:', error);
      throw error;
    }
  } while (nextPageToken);
  
  console.log(`✅ ${deletedCount} utilisateurs Auth supprimés`);
  return deletedCount;
}

async function deleteAllFirestoreUsers(): Promise<number> {
  console.log('🗑️  Suppression de tous les documents Firestore (collection users)...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la suppression de tous les documents Firestore');
    return 0;
  }
  
  try {
    const db = admin.firestore();
    const snapshot = await db.collection(FIRESTORE_COLLECTION).get();
    
    const batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      count++;
    }
    
    if (count > 0) {
      await batch.commit();
    }
    
    console.log(`✅ ${count} documents Firestore supprimés`);
    return count;
  } catch (error: any) {
    console.error('❌ Erreur lors de la suppression des documents Firestore:', error);
    throw error;
  }
}

async function deleteAllMatches(): Promise<number> {
  console.log('🗑️  Suppression de tous les matches...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la suppression de tous les matches');
    return 0;
  }
  
  try {
    const db = admin.firestore();
    const snapshot = await db.collection('matches').get();
    
    const batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      count++;
    }
    
    if (count > 0) {
      await batch.commit();
    }
    
    console.log(`✅ ${count} matches supprimés`);
    return count;
  } catch (error: any) {
    console.error('❌ Erreur lors de la suppression des matches:', error);
    throw error;
  }
}

async function deleteAllMessages(): Promise<number> {
  console.log('🗑️  Suppression de tous les messages...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la suppression de tous les messages');
    return 0;
  }
  
  try {
    const db = admin.firestore();
    const snapshot = await db.collection('messages').get();
    
    const batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      count++;
    }
    
    if (count > 0) {
      await batch.commit();
    }
    
    console.log(`✅ ${count} messages supprimés`);
    return count;
  } catch (error: any) {
    console.error('❌ Erreur lors de la suppression des messages:', error);
    throw error;
  }
}

async function deleteAllPosts(): Promise<number> {
  console.log('🗑️  Suppression de tous les posts...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la suppression de tous les posts');
    return 0;
  }
  
  try {
    const db = admin.firestore();
    const snapshot = await db.collection('posts').get();
    
    const batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      count++;
    }
    
    if (count > 0) {
      await batch.commit();
    }
    
    console.log(`✅ ${count} posts supprimés`);
    return count;
  } catch (error: any) {
    console.error('❌ Erreur lors de la suppression des posts:', error);
    throw error;
  }
}

async function deleteAllSwipes(): Promise<number> {
  console.log('🗑️  Suppression de tous les swipes...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la suppression de tous les swipes');
    return 0;
  }
  
  try {
    const db = admin.firestore();
    const snapshot = await db.collection('swipes').get();
    
    const batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      count++;
    }
    
    if (count > 0) {
      await batch.commit();
    }
    
    console.log(`✅ ${count} swipes supprimés`);
    return count;
  } catch (error: any) {
    console.error('❌ Erreur lors de la suppression des swipes:', error);
    throw error;
  }
}

async function deleteAllJobOffers(): Promise<number> {
  console.log('🗑️  Suppression de toutes les offres d\'emploi...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la suppression de toutes les offres d\'emploi');
    return 0;
  }
  
  try {
    const db = admin.firestore();
    const snapshot = await db.collection('jobOffers').get();
    
    // Firestore limite les batches à 500 opérations
    const BATCH_SIZE = 500;
    let totalCount = 0;
    let batch = db.batch();
    let batchCount = 0;
    
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      batchCount++;
      totalCount++;
      
      // Commit le batch tous les 500 documents
      if (batchCount >= BATCH_SIZE) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }
    
    // Commit le dernier batch s'il reste des documents
    if (batchCount > 0) {
      await batch.commit();
    }
    
    console.log(`✅ ${totalCount} offres d'emploi supprimées`);
    return totalCount;
  } catch (error: any) {
    console.error('❌ Erreur lors de la suppression des offres d\'emploi:', error);
    throw error;
  }
}

// ============================================================================
// FONCTIONS DE CRÉATION
// ============================================================================

async function createTestUser(user: TestUser): Promise<void> {
  try {
    if (DRY_RUN) {
      console.log(`  [DRY-RUN] Créerait Auth user: ${user.email} (${user.isRecruiter ? 'Recruteur' : 'Candidat'})`);
      console.log(`  [DRY-RUN] Créerait Firestore doc: ${user.uid}`);
      return;
    }
    
    // 1. Créer l'utilisateur dans Firebase Auth
    const authUser = await admin.auth().createUser({
      uid: user.uid,
      email: user.email,
      password: user.password,
      displayName: user.displayName,
      emailVerified: true,
      disabled: false,
    });
    
    console.log(`  ✅ Auth user créé: ${user.email} (UID: ${authUser.uid})`);
    
    // 2. Créer le document dans Firestore
    const now = admin.firestore.FieldValue.serverTimestamp();
    const firestoreData: any = {
      uid: user.uid,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      displayName: user.displayName,
      name: user.displayName,
      jobTitle: user.jobTitle,
      isRecruiter: user.isRecruiter,
      isAdmin: user.isAdmin || false,
      skills: user.skills,
      createdAt: now,
      updatedAt: now,
      isOnline: false,
    };
    
    if (user.companyName) firestoreData.companyName = user.companyName;
    if (user.bio) firestoreData.bio = user.bio;
    if (user.location) firestoreData.location = user.location;
    if (user.hardSkills) firestoreData.hardSkills = user.hardSkills;
    if (user.softSkills) firestoreData.softSkills = user.softSkills;
    
    const db = admin.firestore();
    
    // Créer le document avec l'UID comme ID
    await db.collection(FIRESTORE_COLLECTION).doc(user.uid).set(firestoreData);
    
    // Aussi créer avec l'email comme ID (pour compatibilité)
    if (user.email !== user.uid) {
      await db.collection(FIRESTORE_COLLECTION).doc(user.email).set(firestoreData);
    }
    
    console.log(`  ✅ Firestore doc créé: ${user.uid}`);
  } catch (error: any) {
    console.error(`  ❌ Erreur lors de la création de ${user.email}: ${error.message}`);
    throw error;
  }
}

async function createAllTestUsers(): Promise<void> {
  console.log('👥 Création des utilisateurs de test...');
  console.log(`   ${TEST_USERS.length} utilisateurs à créer\n`);
  
  for (const user of TEST_USERS) {
    await createTestUser(user);
  }
  
  console.log(`\n✅ ${TEST_USERS.length} utilisateurs de test créés`);
}

async function createTestMatchesFromJobOffers(jobOffers: Array<{postedBy: string, title: string, id?: string}>): Promise<string[]> {
  console.log('💕 Création des matches de test (une conversation par offre)...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la création de matches de test');
    return [];
  }
  
  try {
    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();
    
    // Récupérer les UIDs des candidats
    const candidates = TEST_USERS.filter(u => !u.isRecruiter && !u.isAdmin);
    
    if (candidates.length === 0) {
      console.log('  ⚠️  Aucun candidat disponible, pas de matches créés');
      return [];
    }
    
    if (jobOffers.length === 0) {
      console.log('  ⚠️  Aucune offre d\'emploi disponible, pas de matches créés');
      return [];
    }
    
    // Créer un match pour chaque offre d'emploi
    let matchCount = 0;
    const matchIds: string[] = [];
    let candidateIndex = 0;
    
    for (const jobOffer of jobOffers) {
      // Sélectionner un candidat (rotation pour distribuer équitablement)
      const candidate = candidates[candidateIndex % candidates.length];
      candidateIndex++;
      
      // Récupérer le recruteur qui a posté l'offre
      const recruiterUid = jobOffer.postedBy;
      const recruiter = TEST_USERS.find(u => u.uid === recruiterUid);
      
      if (!recruiter) {
        console.log(`  ⚠️  Recruteur non trouvé pour l'offre "${jobOffer.title}" (postedBy: ${recruiterUid})`);
        continue;
      }
      
      // Vérifier si un match existe déjà entre ce candidat et ce recruteur
      const existingMatch = await db.collection('matches')
        .where('candidateUid', '==', candidate.uid)
        .where('recruiterUid', '==', recruiterUid)
        .limit(1)
        .get();
      
      let matchId: string;
      
      if (existingMatch.docs.length > 0) {
        // Utiliser le match existant et mettre à jour le jobOfferId si nécessaire
        const existingMatchDoc = existingMatch.docs[0];
        matchId = existingMatchDoc.id;
        const existingData = existingMatchDoc.data();
        
        // Mettre à jour le match avec le jobOfferId s'il n'est pas déjà défini
        if (jobOffer.id && existingData.jobOfferId !== jobOffer.id) {
          await db.collection('matches').doc(matchId).update({
            jobOfferId: jobOffer.id,
          });
          console.log(`  ✅ Match existant mis à jour avec jobOfferId: ${candidate.firstName} ${candidate.lastName} ↔ ${recruiter.firstName} ${recruiter.lastName} (offre: "${jobOffer.title}")`);
        } else {
          console.log(`  ℹ️  Match existant réutilisé: ${candidate.firstName} ${candidate.lastName} ↔ ${recruiter.firstName} ${recruiter.lastName} (offre: "${jobOffer.title}")`);
        }
      } else {
        // Créer un nouveau match
        const matchData: any = {
          candidateUid: candidate.uid,
          recruiterUid: recruiterUid,
          matchedAt: now,
          lastMessageAt: null,
          lastMessageContent: null,
          lastMessageSenderUid: null,
          isActive: true,
          readBy: {
            [candidate.uid]: false,
            [recruiterUid]: false,
          },
        };
        
        // Ajouter le jobOfferId si disponible
        if (jobOffer.id) {
          matchData.jobOfferId = jobOffer.id;
        }
        
        const matchRef = await db.collection('matches').add(matchData);
        matchId = matchRef.id;
        matchCount++;
        console.log(`  ✅ Match créé: ${candidate.firstName} ${candidate.lastName} ↔ ${recruiter.firstName} ${recruiter.lastName} (offre: "${jobOffer.title}")`);
      }
      
      matchIds.push(matchId);
    }
    
    console.log(`\n✅ ${matchCount} nouveaux matches créés (${matchIds.length} matches au total pour ${jobOffers.length} offres)`);
    return matchIds;
  } catch (error: any) {
    console.error('❌ Erreur lors de la création des matches:', error);
    throw error;
  }
}

async function createTestPosts(): Promise<void> {
  console.log('📝 Création des posts de test...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la création de posts de test');
    return;
  }
  
  try {
    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();
    
    const candidates = TEST_USERS.filter(u => !u.isRecruiter && !u.isAdmin);
    const recruiters = TEST_USERS.filter(u => u.isRecruiter && !u.isAdmin);
    
    const posts = [
      // Posts de recruteurs
      {
        authorUid: recruiters[0]?.uid || 'recruiter_1',
        title: 'Recherche Développeur Flutter Senior',
        content: 'Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe. Vous travaillerez sur des applications mobiles innovantes avec une équipe dynamique. Nous offrons un environnement de travail flexible et des opportunités de croissance.',
        authorIsRecruiter: true,
        softSkills: ['Communication', 'Travail en équipe', 'Autonomie'],
        hardSkills: ['Flutter', 'Dart', 'Firebase'],
        domain: 'Développement Mobile',
        tags: ['Flutter', 'Mobile', 'Senior'],
      },
      {
        authorUid: recruiters[0]?.uid || 'recruiter_1',
        title: 'Opportunité Product Owner',
        content: 'Rejoignez notre équipe en tant que Product Owner pour piloter des produits innovants. Vous serez responsable de la roadmap produit et travaillerez en étroite collaboration avec les équipes techniques et business.',
        authorIsRecruiter: true,
        softSkills: ['Leadership', 'Communication', 'Stratégie'],
        hardSkills: ['Product Management', 'Agile', 'Analytics'],
        domain: 'Product Management',
        tags: ['Product Owner', 'Agile', 'Management'],
      },
      {
        authorUid: recruiters[1]?.uid || 'recruiter_2',
        title: 'Développeur Full Stack recherché',
        content: 'Startup tech en pleine croissance recherche un développeur full stack pour renforcer son équipe. Stack technique moderne : React, Node.js, TypeScript. Environnement startup avec beaucoup d\'autonomie.',
        authorIsRecruiter: true,
        softSkills: ['Autonomie', 'Adaptabilité', 'Créativité'],
        hardSkills: ['React', 'Node.js', 'TypeScript'],
        domain: 'Développement Web',
        tags: ['Full Stack', 'React', 'Node.js'],
      },
      // Posts de candidats
      {
        authorUid: candidates[0]?.uid || 'candidate_1',
        title: 'Développeuse Flutter disponible',
        content: 'Développeuse Flutter passionnée avec 3 ans d\'expérience, je recherche de nouvelles opportunités. Spécialisée dans le développement d\'applications mobiles performantes et l\'intégration Firebase. Ouverte aux missions en remote.',
        authorIsRecruiter: false,
        softSkills: ['Autonomie', 'Communication', 'Rigueur'],
        hardSkills: ['Flutter', 'Dart', 'Firebase'],
        domain: 'Développement Mobile',
        tags: ['Flutter', 'Mobile', 'Remote'],
      },
      {
        authorUid: candidates[1]?.uid || 'candidate_2',
        title: 'Data Analyst à la recherche d\'opportunités',
        content: 'Data Analyst avec une solide expérience en Python, SQL et visualisation de données. Passionné par l\'analyse de données et la création d\'insights actionnables. Recherche un poste dans une entreprise data-driven.',
        authorIsRecruiter: false,
        softSkills: ['Analyse', 'Curiosité', 'Précision'],
        hardSkills: ['Python', 'SQL', 'Data Visualization'],
        domain: 'Data Science',
        tags: ['Data', 'Python', 'Analytics'],
      },
      {
        authorUid: candidates[2]?.uid || 'candidate_3',
        title: 'UX/UI Designer disponible',
        content: 'Designer UX/UI créatif avec une passion pour les interfaces utilisateur intuitives et modernes. Expérience dans la conception d\'applications mobiles et web. Recherche des projets stimulants dans une équipe collaborative.',
        authorIsRecruiter: false,
        softSkills: ['Créativité', 'Empathie', 'Communication'],
        hardSkills: ['Figma', 'Sketch', 'Prototyping'],
        domain: 'Design',
        tags: ['UX', 'UI', 'Design'],
      },
    ];
    
    let postCount = 0;
    for (const post of posts) {
      const postData = {
        ...post,
        createdAt: now,
        isActive: true,
      };
      
      await db.collection('posts').add(postData);
      postCount++;
      console.log(`  ✅ Post créé: "${post.title}" par ${post.authorUid}`);
    }
    
    console.log(`\n✅ ${postCount} posts de test créés`);
  } catch (error: any) {
    console.error('❌ Erreur lors de la création des posts:', error);
    throw error;
  }
}

async function createTestMessages(matchIds: string[]): Promise<void> {
  console.log('💬 Création des messages de test...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la création de messages de test');
    return;
  }
  
  if (matchIds.length === 0) {
    console.log('  ⚠️  Aucun match disponible, pas de messages créés');
    return;
  }
  
  try {
    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();
    
    // Récupérer les matches pour avoir les UIDs (limiter à 10 car Firestore limite les requêtes 'in' à 10 éléments)
    const matchIdsToFetch = matchIds.slice(0, 10);
    const matchesSnapshot = await db.collection('matches').where(admin.firestore.FieldPath.documentId(), 'in', matchIdsToFetch).get();
    
    const messages = [
      { content: 'Bonjour ! Merci pour le match, je suis très intéressé(e) par votre profil.', delay: 0 },
      { content: 'Salut ! Ravi de vous rencontrer. Avez-vous des questions sur le poste ?', delay: 1 },
      { content: 'Oui, je serais ravi(e) d\'en discuter. Quand pourrions-nous organiser un échange ?', delay: 2 },
      { content: 'Parfait ! Je vous envoie mes disponibilités par email.', delay: 3 },
    ];
    
    let messageCount = 0;
    for (const matchDoc of matchesSnapshot.docs) {
      const matchData = matchDoc.data();
      const candidateUid = matchData.candidateUid as string;
      const recruiterUid = matchData.recruiterUid as string;
      const matchId = matchDoc.id;
      
      // Créer quelques messages pour chaque match
      for (let i = 0; i < Math.min(2, messages.length); i++) {
        const message = messages[i];
        const senderUid = i % 2 === 0 ? candidateUid : recruiterUid;
        const receiverUid = i % 2 === 0 ? recruiterUid : candidateUid;
        
        const messageData = {
          matchId: matchId,
          senderUid: senderUid,
          receiverUid: receiverUid,
          content: message.content,
          type: 'text',
          sentAt: now,
          readAt: null,
          isRead: i === 0, // Le premier message est lu
          imageUrl: null,
          metadata: {},
        };
        
        await db.collection('messages').add(messageData);
        messageCount++;
      }
      
      // Mettre à jour le dernier message du match
      const lastMessage = messages[Math.min(1, messages.length - 1)];
      await db.collection('matches').doc(matchId).update({
        lastMessageAt: now,
        lastMessageContent: lastMessage.content,
        lastMessageSenderUid: messages.length > 1 ? (messages.length % 2 === 0 ? candidateUid : recruiterUid) : candidateUid,
      });
    }
    
    console.log(`\n✅ ${messageCount} messages de test créés`);
  } catch (error: any) {
    console.error('❌ Erreur lors de la création des messages:', error);
    throw error;
  }
}

async function createTestSwipes(jobOfferIds: string[]): Promise<void> {
  console.log('👆 Création des swipes de test...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la création de swipes de test');
    return;
  }
  
  try {
    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();
    
    const candidates = TEST_USERS.filter(u => !u.isRecruiter && !u.isAdmin);
    const recruiters = TEST_USERS.filter(u => u.isRecruiter && !u.isAdmin);
    
    let swipeCount = 0;
    
    // Créer des swipes de recruteurs vers candidats
    for (const recruiter of recruiters.slice(0, 2)) {
      for (const candidate of candidates.slice(0, 2)) {
        const swipeData = {
          fromUid: recruiter.uid,
          toEntityId: candidate.uid,
          type: 'recruiter→candidate',
          value: Math.random() > 0.5 ? 'like' : 'pass',
          createdAt: now,
        };
        
        await db.collection('swipes').add(swipeData);
        swipeCount++;
      }
    }
    
    // Créer des swipes de candidats vers offres
    if (jobOfferIds.length > 0) {
      for (const candidate of candidates.slice(0, 2)) {
        const jobOfferId = jobOfferIds[Math.floor(Math.random() * jobOfferIds.length)];
        const swipeData = {
          fromUid: candidate.uid,
          toEntityId: jobOfferId,
          type: 'candidate→job',
          value: 'like',
          createdAt: now,
        };
        
        await db.collection('swipes').add(swipeData);
        swipeCount++;
      }
    }
    
    console.log(`\n✅ ${swipeCount} swipes de test créés`);
  } catch (error: any) {
    console.error('❌ Erreur lors de la création des swipes:', error);
    throw error;
  }
}

async function createTestJobOffers(): Promise<Array<{postedBy: string, title: string, id: string}>> {
  console.log('💼 Création des offres d\'emploi de test...');
  
  if (DRY_RUN) {
    console.log('  [DRY-RUN] Simulerait la création d\'offres d\'emploi de test');
    return [];
  }
  
  try {
    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();
    
    const recruiters = TEST_USERS.filter(u => u.isRecruiter && !u.isAdmin);
    
    if (recruiters.length === 0) {
      console.log('  ⚠️  Aucun recruteur disponible, pas d\'offres créées');
      return [];
    }
    
    // Vérifier que les recruteurs ont bien des UIDs valides
    const recruiterUids = recruiters.map(r => r.uid).filter(uid => uid && uid.length > 0);
    if (recruiterUids.length === 0) {
      console.log('  ⚠️  Aucun UID de recruteur valide, pas d\'offres créées');
      return [];
    }
    
    const jobOffers = [
      {
        title: 'Développeur Flutter Senior',
        company: 'TechCorp France',
        location: 'Paris, France',
        type: 'CDI',
        salary: '50-65k€',
        experience: '3-5 ans',
        description: 'Nous recherchons un développeur Flutter expérimenté pour rejoindre notre équipe mobile en pleine expansion. Vous travaillerez sur des applications innovantes utilisées par des millions d\'utilisateurs. Environnement dynamique avec des technologies de pointe.',
        requirements: ['Flutter', 'Dart', 'Firebase', 'Git', 'Agile', 'CI/CD', 'Architecture mobile'],
        benefits: ['Télétravail hybride', 'Mutuelle premium', 'Tickets resto', 'Formation continue', 'Prime performance'],
        postedBy: recruiters[0]?.uid || 'recruiter_1',
      },
      {
        title: 'Développeuse React Native',
        company: 'StartupIO',
        location: 'Lyon, France',
        type: 'CDI',
        salary: '45-55k€',
        experience: '2-4 ans',
        description: 'Rejoignez notre startup en pleine croissance ! Nous développons des solutions mobiles innovantes pour le secteur de la santé. Équipe jeune et dynamique, environnement startup avec beaucoup d\'autonomie et d\'impact.',
        requirements: ['React Native', 'JavaScript', 'Redux', 'API REST', 'TypeScript', 'Expo'],
        benefits: ['Equity', 'Télétravail', 'Matériel fourni', 'Formation', 'Horaires flexibles'],
        postedBy: recruiters[1]?.uid || 'recruiter_2',
      },
      {
        title: 'Chef de projet digital',
        company: 'Digital Agency Pro',
        location: 'Marseille, France',
        type: 'CDI',
        salary: '55-70k€',
        experience: '5+ ans',
        description: 'Pilotez nos projets digitaux innovants pour nos clients internationaux. Leadership d\'équipe et gestion de projets complexes. Vous serez responsable de la roadmap produit et travaillerez en étroite collaboration avec les équipes techniques et business.',
        requirements: ['Gestion de projet', 'Agile/Scrum', 'Digital', 'Leadership', 'Communication', 'Jira'],
        benefits: ['Télétravail', 'Mutuelle', 'Prime', 'Formation', 'Véhicule de fonction'],
        postedBy: recruiters[0]?.uid || 'recruiter_1',
      },
      {
        title: 'Développeur Full-Stack',
        company: 'TechCorp France',
        location: 'Paris, France',
        type: 'CDI',
        salary: '55-70k€',
        experience: '4-6 ans',
        description: 'Nous recherchons un développeur full-stack expérimenté pour renforcer notre équipe technique. Stack moderne : React, Node.js, TypeScript, PostgreSQL. Vous travaillerez sur des projets variés et innovants.',
        requirements: ['React', 'Node.js', 'TypeScript', 'PostgreSQL', 'Docker', 'AWS'],
        benefits: ['Télétravail', 'Mutuelle', 'Tickets resto', 'Formation', 'Prime'],
        postedBy: recruiters[0]?.uid || 'recruiter_1',
      },
      {
        title: 'Data Analyst',
        company: 'StartupIO',
        location: 'Lyon, France',
        type: 'CDI',
        salary: '40-50k€',
        experience: '2-3 ans',
        description: 'Rejoignez notre équipe data pour analyser et visualiser les données de nos produits. Vous travaillerez avec Python, SQL et des outils de visualisation pour créer des insights actionnables.',
        requirements: ['Python', 'SQL', 'Data Visualization', 'Tableau', 'Excel', 'Statistics'],
        benefits: ['Télétravail', 'Mutuelle', 'Formation', 'Horaires flexibles'],
        postedBy: recruiters[1]?.uid || 'recruiter_2',
      },
      {
        title: 'UX/UI Designer',
        company: 'Digital Agency Pro',
        location: 'Marseille, France',
        type: 'CDI',
        salary: '45-55k€',
        experience: '3-5 ans',
        description: 'Nous recherchons un designer UX/UI créatif pour concevoir des interfaces utilisateur intuitives et modernes. Vous travaillerez sur des projets variés : applications mobiles, sites web, dashboards.',
        requirements: ['Figma', 'Sketch', 'Prototyping', 'User Research', 'Design System'],
        benefits: ['Télétravail', 'Mutuelle', 'Formation', 'Matériel fourni'],
        postedBy: recruiters[0]?.uid || 'recruiter_1',
      },
    ];
    
    const createdJobOffers: Array<{postedBy: string, title: string, id: string}> = [];
    let jobCount = 0;
    
    for (const job of jobOffers) {
      // Vérifier que le postedBy est valide
      const postedBy = job.postedBy;
      if (!postedBy || !recruiterUids.includes(postedBy)) {
        console.log(`  ⚠️  Offre "${job.title}" ignorée: postedBy invalide (${postedBy})`);
        continue;
      }
      
      const jobData = {
        ...job,
        postedAt: now,
        isActive: true,
      };
      
      const jobRef = await db.collection('jobOffers').add(jobData);
      createdJobOffers.push({
        postedBy: postedBy,
        title: job.title,
        id: jobRef.id,
      });
      jobCount++;
      console.log(`  ✅ Offre créée: "${job.title}" chez ${job.company} (par ${postedBy})`);
    }
    
    console.log(`\n✅ ${jobCount} offres d'emploi de test créées`);
    return createdJobOffers;
  } catch (error: any) {
    console.error('❌ Erreur lors de la création des offres d\'emploi:', error);
    throw error;
  }
}

// ============================================================================
// FONCTION PRINCIPALE
// ============================================================================

async function resetAndSeedUsers(): Promise<void> {
  console.log('\n' + '='.repeat(60));
  console.log('🔄 RÉINITIALISATION ET SEEDING DES UTILISATEURS');
  console.log('='.repeat(60));
  console.log(`Mode: ${DRY_RUN ? 'DRY-RUN (simulation)' : 'PRODUCTION (modifications réelles)'}\n`);
  
  if (!DRY_RUN) {
    console.log('⚠️  ATTENTION: Ce script va supprimer TOUTES les données utilisateurs, matches, messages, posts, swipes et offres d\'emploi !\n');
  }
  
  try {
    // 1. Supprimer tous les utilisateurs Auth
    await deleteAllAuthUsers();
    console.log('');
    
    // 2. Supprimer tous les documents Firestore (users, matches, messages, posts)
    await deleteAllFirestoreUsers();
    console.log('');
    await deleteAllMatches();
    console.log('');
    await deleteAllMessages();
    console.log('');
    await deleteAllPosts();
    console.log('');
    await deleteAllSwipes();
    console.log('');
    await deleteAllJobOffers();
    console.log('');
    
    // 3. Créer les utilisateurs de test
    await createAllTestUsers();
    console.log('');
    
    // 4. Créer des posts de test
    await createTestPosts();
    console.log('');
    
    // 5. Créer des offres d'emploi de test
    const jobOffers = await createTestJobOffers();
    console.log('');
    
    // 6. Créer des matches de test (une conversation par offre)
    const matchIds = await createTestMatchesFromJobOffers(jobOffers);
    console.log('');
    
    // 7. Créer des messages de test
    await createTestMessages(matchIds);
    console.log('');
    
    // 8. Créer des swipes de test
    const jobOfferIds = jobOffers.map(j => j.id).filter(id => id && id.length > 0);
    await createTestSwipes(jobOfferIds);
    
    console.log('\n' + '='.repeat(60));
    console.log('📋 RÉSUMÉ');
    console.log('='.repeat(60));
    console.log(`✅ Utilisateurs Auth supprimés`);
    console.log(`✅ Documents Firestore supprimés`);
    console.log(`✅ Matches supprimés`);
    console.log(`✅ Messages supprimés`);
    console.log(`✅ Posts supprimés`);
    console.log(`✅ Swipes supprimés`);
    console.log(`✅ Offres d'emploi supprimées`);
    console.log(`✅ ${TEST_USERS.length} utilisateurs de test créés`);
    console.log(`✅ Matches de test créés`);
    console.log(`✅ Posts de test créés`);
    console.log(`✅ Offres d'emploi de test créées`);
    console.log(`✅ Messages de test créés`);
    console.log(`✅ Swipes de test créés`);
    console.log(`\n🔑 Mot de passe par défaut pour tous les comptes: ${DEFAULT_PASSWORD}`);
    console.log('\n📧 Comptes créés:');
    TEST_USERS.forEach(user => {
      const type = user.isAdmin ? 'Admin' : user.isRecruiter ? 'Recruteur' : 'Candidat';
      console.log(`   - ${user.email} (${type})`);
    });
    
    if (DRY_RUN) {
      console.log('\nℹ️  Mode DRY-RUN: Aucune modification n\'a été effectuée');
      console.log('   Pour appliquer les changements, exécutez sans DRY_RUN=true');
    } else {
      console.log('\n✅ Réinitialisation terminée avec succès !');
    }
    console.log('='.repeat(60) + '\n');
    
  } catch (error: any) {
    console.error('\n❌ Erreur fatale:', error);
    process.exit(1);
  }
}

// ============================================================================
// POINT D'ENTRÉE
// ============================================================================

async function main() {
  try {
    initializeFirebaseAdmin();
    await resetAndSeedUsers();
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur fatale:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

export { resetAndSeedUsers, initializeFirebaseAdmin };

