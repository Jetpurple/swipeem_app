/**
 * Script de synchronisation entre Firebase Authentication et Firestore
 * 
 * Ce script synchronise les utilisateurs entre Firebase Authentication et la collection
 * `users` dans Firestore pour garantir que tous les utilisateurs existent des deux côtés.
 * 
 * USAGE:
 * ------
 * 
 * 1. Configuration requise:
 *    - Avoir un fichier de credentials Firebase Admin (service account JSON)
 *    - Définir la variable d'environnement GOOGLE_APPLICATION_CREDENTIALS pointant vers ce fichier
 *    - OU avoir les credentials configurés via gcloud CLI
 * 
 * 2. Installation des dépendances:
 *    npm install
 * 
 * 3. Compilation TypeScript:
 *    npm run build
 * 
 * 4. Exécution en mode DRY-RUN (simulation, ne modifie rien):
 *    DRY_RUN=true npm run sync:users
 *    ou
 *    npm run sync:users:dry
 * 
 * 5. Exécution en mode PRODUCTION (modifie réellement les données):
 *    npm run sync:users
 * 
 * 6. Exécution directe avec ts-node (sans compilation):
 *    DRY_RUN=true npx ts-node scripts/syncUsersAuthFirestore.ts
 *    npx ts-node scripts/syncUsersAuthFirestore.ts
 * 
 * SORTIE:
 * - Affiche le nombre d'utilisateurs synchronisés
 * - Liste les utilisateurs créés côté Auth
 * - Liste les documents créés côté Firestore
 * - Liste les erreurs rencontrées
 */

import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

// ============================================================================
// CONFIGURATION
// ============================================================================

const FIRESTORE_COLLECTION = 'users';
const DRY_RUN = process.env.DRY_RUN === 'true' || process.env.DRY_RUN === '1';

// Champs minimum requis pour créer un utilisateur Auth
const REQUIRED_AUTH_FIELDS = ['email'];

// Champs à copier depuis Auth vers Firestore
const AUTH_TO_FIRESTORE_FIELDS = [
  'uid',
  'email',
  'displayName',
  'photoURL',
  'phoneNumber',
  'emailVerified',
  'disabled',
  'metadata',
  'providerData',
];

// ============================================================================
// TYPES
// ============================================================================

interface AuthUser {
  uid: string;
  email?: string;
  displayName?: string;
  photoURL?: string;
  phoneNumber?: string;
  emailVerified?: boolean;
  disabled?: boolean;
  metadata?: {
    creationTime?: string;
    lastSignInTime?: string;
    lastRefreshTime?: string;
  };
  providerData?: Array<{
    uid: string;
    email?: string;
    displayName?: string;
    photoURL?: string;
    providerId: string;
  }>;
}

interface FirestoreUser {
  uid?: string;
  email?: string;
  firstName?: string;
  lastName?: string;
  displayName?: string;
  name?: string;
  profileImageUrl?: string;
  photoURL?: string;
  phoneNumber?: string;
  createdAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
  updatedAt?: admin.firestore.Timestamp | admin.firestore.FieldValue;
  isRecruiter?: boolean;
  isAdmin?: boolean;
  [key: string]: any;
}

interface SyncStats {
  alreadySynced: number;
  createdInAuth: number;
  createdInFirestore: number;
  failedAuth: string[];
  failedFirestore: string[];
  errors: Array<{ uid: string; error: string }>;
}

// ============================================================================
// INITIALISATION FIREBASE ADMIN
// ============================================================================

function initializeFirebaseAdmin(): void {
  try {
    // Vérifier si Firebase Admin est déjà initialisé
    if (admin.apps.length === 0) {
      // Vérifier si GOOGLE_APPLICATION_CREDENTIALS est défini
      const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
      
      if (credentialsPath) {
        // Vérifier si le fichier existe
        const fs = require('fs');
        if (!fs.existsSync(credentialsPath)) {
          console.error('\n❌ ERREUR: Le fichier de credentials n\'existe pas !');
          console.error(`   Chemin spécifié: ${credentialsPath}`);
          console.error('\n📋 Instructions:');
          console.error('   1. Téléchargez le fichier JSON de service account depuis Firebase Console');
          console.error('      (Paramètres du projet → Comptes de service → Générer une nouvelle clé privée)');
          console.error('   2. Définissez la variable d\'environnement avec le VRAI chemin:');
          console.error(`      export GOOGLE_APPLICATION_CREDENTIALS="/chemin/vers/votre-fichier.json"`);
          console.error('   3. OU utilisez gcloud auth:');
          console.error('      gcloud auth application-default login\n');
          throw new Error(`Fichier de credentials introuvable: ${credentialsPath}`);
        }
        console.log(`📁 Utilisation des credentials: ${credentialsPath}`);
      } else {
        console.log('ℹ️  GOOGLE_APPLICATION_CREDENTIALS non défini, tentative avec gcloud auth...');
      }
      
      // Initialiser avec les credentials par défaut (GOOGLE_APPLICATION_CREDENTIALS ou gcloud)
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
      console.log('✅ Firebase Admin initialisé');
    } else {
      console.log('✅ Firebase Admin déjà initialisé');
    }
  } catch (error: any) {
    console.error('\n❌ Erreur lors de l\'initialisation de Firebase Admin');
    
    if (error.code === 'app/invalid-credential') {
      console.error('\n📋 Solutions possibles:');
      console.error('   1. Télécharger le fichier JSON de service account depuis Firebase Console');
      console.error('      → Paramètres du projet → Comptes de service');
      console.error('      → Sélectionner le compte de service → Générer une nouvelle clé privée');
      console.error('   2. Définir la variable d\'environnement:');
      console.error('      export GOOGLE_APPLICATION_CREDENTIALS="/chemin/vers/votre-fichier.json"');
      console.error('   3. OU utiliser gcloud auth (alternative):');
      console.error('      gcloud auth application-default login\n');
    }
    
    console.error('Détails de l\'erreur:', error.message);
    throw error;
  }
}

// ============================================================================
// FONCTIONS UTILITAIRES
// ============================================================================

/**
 * Génère un mot de passe aléatoire sécurisé
 */
function generateRandomPassword(length: number = 16): string {
  const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  const randomBytes = crypto.randomBytes(length);
  let password = '';
  for (let i = 0; i < length; i++) {
    password += charset[randomBytes[i] % charset.length];
  }
  return password;
}

/**
 * Extrait l'email depuis un document Firestore (peut être dans le champ email ou comme ID)
 */
function extractEmailFromFirestore(docId: string, data: FirestoreUser): string | undefined {
  // Vérifier si l'ID du document est un email
  if (docId.includes('@') && docId.includes('.')) {
    return docId;
  }
  // Sinon, utiliser le champ email
  return data.email;
}

/**
 * Extrait le displayName depuis un document Firestore
 */
function extractDisplayName(data: FirestoreUser): string | undefined {
  return data.displayName || data.name || 
    (data.firstName && data.lastName ? `${data.firstName} ${data.lastName}` : undefined);
}

/**
 * Extrait firstName et lastName depuis displayName
 */
function parseNameFromDisplayName(displayName: string | undefined): { firstName: string; lastName: string } {
  if (!displayName) {
    return { firstName: 'Utilisateur', lastName: 'Anonyme' };
  }
  
  const nameParts = displayName.trim().split(/\s+/);
  if (nameParts.length === 0) {
    return { firstName: 'Utilisateur', lastName: 'Anonyme' };
  }
  
  const firstName = nameParts[0] || 'Utilisateur';
  const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : 'Anonyme';
  
  return { firstName, lastName };
}

/**
 * Crée un document Firestore minimal depuis un utilisateur Auth
 */
function createFirestoreDocFromAuth(authUser: AuthUser): FirestoreUser {
  const now = admin.firestore.FieldValue.serverTimestamp();
  
  // Extraire firstName et lastName depuis displayName
  const { firstName, lastName } = parseNameFromDisplayName(authUser.displayName);
  
  const doc: FirestoreUser = {
    uid: authUser.uid,
    email: authUser.email || '',
    firstName: firstName,
    lastName: lastName,
    createdAt: now,
    updatedAt: now,
    source: 'auth',
    syncedAt: now,
    isRecruiter: false, // Par défaut, sera mis à jour si nécessaire
    isAdmin: false,
  };

  // Ajouter les champs optionnels
  if (authUser.displayName) {
    doc.displayName = authUser.displayName;
    doc.name = authUser.displayName; // Pour compatibilité
  } else {
    // Si pas de displayName, créer un nom depuis firstName et lastName
    doc.name = `${firstName} ${lastName}`;
  }
  
  if (authUser.photoURL) {
    doc.profileImageUrl = authUser.photoURL;
    doc.photoURL = authUser.photoURL;
  }
  if (authUser.phoneNumber) doc.phoneNumber = authUser.phoneNumber;

  // Copier les providerData si disponible (en nettoyant les valeurs undefined)
  if (authUser.providerData && authUser.providerData.length > 0) {
    doc.providerData = authUser.providerData.map((provider) => {
      const cleanProvider: any = { providerId: provider.providerId };
      if (provider.uid) cleanProvider.uid = provider.uid;
      if (provider.email) cleanProvider.email = provider.email;
      if (provider.displayName) cleanProvider.displayName = provider.displayName;
      if (provider.photoURL) cleanProvider.photoURL = provider.photoURL;
      return cleanProvider;
    });
  }

  return doc;
}

/**
 * Crée un utilisateur Auth minimal depuis un document Firestore
 */
function createAuthUserFromFirestore(
  uid: string,
  data: FirestoreUser
): admin.auth.CreateRequest {
  const email = extractEmailFromFirestore(uid, data);
  if (!email) {
    throw new Error('Email manquant dans le document Firestore');
  }

  const displayName = extractDisplayName(data);
  const password = generateRandomPassword();

  const createRequest: admin.auth.CreateRequest = {
    uid: uid,
    email: email,
    password: password,
    displayName: displayName,
    photoURL: data.profileImageUrl || data.photoURL,
    phoneNumber: data.phoneNumber,
    emailVerified: false,
    disabled: false,
  };

  return createRequest;
}

// ============================================================================
// FONCTIONS DE RÉCUPÉRATION
// ============================================================================

/**
 * Récupère tous les utilisateurs Firebase Authentication
 */
async function getAllAuthUsers(): Promise<Map<string, AuthUser>> {
  console.log('📥 Récupération des utilisateurs Firebase Authentication...');
  const authUsers = new Map<string, AuthUser>();
  let nextPageToken: string | undefined;

  do {
    try {
      const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
      
      for (const userRecord of listUsersResult.users) {
        const authUser: AuthUser = {
          uid: userRecord.uid,
          email: userRecord.email,
          displayName: userRecord.displayName,
          photoURL: userRecord.photoURL,
          phoneNumber: userRecord.phoneNumber,
          emailVerified: userRecord.emailVerified,
          disabled: userRecord.disabled,
          metadata: {
            creationTime: userRecord.metadata.creationTime,
            lastSignInTime: userRecord.metadata.lastSignInTime,
            lastRefreshTime: userRecord.metadata.lastRefreshTime || undefined,
          },
          providerData: userRecord.providerData.map((provider) => ({
            uid: provider.uid,
            email: provider.email,
            displayName: provider.displayName,
            photoURL: provider.photoURL,
            providerId: provider.providerId,
          })),
        };
        authUsers.set(userRecord.uid, authUser);
      }

      nextPageToken = listUsersResult.pageToken;
    } catch (error) {
      console.error('❌ Erreur lors de la récupération des utilisateurs Auth:', error);
      throw error;
    }
  } while (nextPageToken);

  console.log(`✅ ${authUsers.size} utilisateurs récupérés depuis Firebase Auth`);
  return authUsers;
}

/**
 * Récupère tous les documents Firestore de la collection users
 */
async function getAllFirestoreUsers(): Promise<Map<string, FirestoreUser>> {
  console.log('📥 Récupération des documents Firestore...');
  const firestoreUsers = new Map<string, FirestoreUser>();

  try {
    const db = admin.firestore();
    const snapshot = await db.collection(FIRESTORE_COLLECTION).get();

    for (const doc of snapshot.docs) {
      const data = doc.data() as FirestoreUser;
      const docId = doc.id;

      // Stocker par UID si disponible, sinon par ID du document
      const key = data.uid || docId;
      firestoreUsers.set(key, { ...data, uid: data.uid || docId });

      // Si l'ID du document est un email différent de l'UID, créer aussi une entrée par email
      if (docId.includes('@') && docId !== key) {
        firestoreUsers.set(docId, { ...data, uid: data.uid || docId });
      }
    }

    console.log(`✅ ${snapshot.size} documents récupérés depuis Firestore`);
  } catch (error) {
    console.error('❌ Erreur lors de la récupération des documents Firestore:', error);
    throw error;
  }

  return firestoreUsers;
}

// ============================================================================
// FONCTIONS DE CRÉATION
// ============================================================================

/**
 * Crée un document Firestore pour un utilisateur Auth qui n'existe pas encore
 */
async function createFirestoreUser(
  authUser: AuthUser,
  stats: SyncStats
): Promise<void> {
  try {
    const docData = createFirestoreDocFromAuth(authUser);
    const docId = authUser.uid; // Utiliser l'UID comme ID du document

    if (DRY_RUN) {
      console.log(`  [DRY-RUN] Créerait Firestore doc: ${docId} pour Auth user: ${authUser.uid}`);
      console.log(`  [DRY-RUN]   - firstName: ${docData.firstName}, lastName: ${docData.lastName}, isRecruiter: ${docData.isRecruiter}`);
      stats.createdInFirestore++;
      return;
    }

    const db = admin.firestore();
    const docRef = db.collection(FIRESTORE_COLLECTION).doc(docId);
    
    // Vérifier si le document existe déjà partiellement
    const existingDoc = await docRef.get();
    if (existingDoc.exists) {
      // Mettre à jour seulement les champs manquants, préserver les existants
      const existingData = existingDoc.data() as FirestoreUser;
      const updateData: any = {
        uid: authUser.uid,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        source: 'auth',
        syncedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      // Ajouter seulement les champs manquants
      if (!existingData.firstName && docData.firstName) updateData.firstName = docData.firstName;
      if (!existingData.lastName && docData.lastName) updateData.lastName = docData.lastName;
      if (!existingData.email && docData.email) updateData.email = docData.email;
      if (!existingData.displayName && docData.displayName) updateData.displayName = docData.displayName;
      if (!existingData.name && docData.name) updateData.name = docData.name;
      if (docData.profileImageUrl && !existingData.profileImageUrl) updateData.profileImageUrl = docData.profileImageUrl;
      
      await docRef.update(updateData);
      console.log(`  ✅ Mis à jour Firestore doc: ${docId} pour Auth user: ${authUser.uid}`);
      console.log(`     - firstName: ${updateData.firstName || existingData.firstName}, lastName: ${updateData.lastName || existingData.lastName}`);
    } else {
      // Créer un nouveau document
      await docRef.set(docData);
      console.log(`  ✅ Créé Firestore doc: ${docId} pour Auth user: ${authUser.uid}`);
      console.log(`     - firstName: ${docData.firstName}, lastName: ${docData.lastName}, isRecruiter: ${docData.isRecruiter}`);
    }
    
    stats.createdInFirestore++;
  } catch (error: any) {
    const errorMsg = `Erreur lors de la création du document Firestore pour ${authUser.uid}: ${error.message}`;
    console.error(`  ❌ ${errorMsg}`);
    stats.failedFirestore.push(authUser.uid);
    stats.errors.push({ uid: authUser.uid, error: errorMsg });
  }
}

/**
 * Met à jour les champs manquants d'un document Firestore existant
 */
async function updateFirestoreUserFields(
  authUser: AuthUser,
  existingData: FirestoreUser,
  stats: SyncStats
): Promise<void> {
  try {
    // Essayer d'extraire le nom depuis displayName, ou depuis l'email si displayName est vide
    let displayName = authUser.displayName;
    if (!displayName && authUser.email) {
      // Extraire un nom depuis l'email (ex: "john.doe@example.com" -> "John Doe")
      const emailPart = authUser.email.split('@')[0];
      displayName = emailPart.split(/[._-]/).map(part => 
        part.charAt(0).toUpperCase() + part.slice(1)
      ).join(' ');
    }
    
    const { firstName, lastName } = parseNameFromDisplayName(displayName);
    const updateData: any = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    
    // Ajouter les champs manquants
    if (!existingData.firstName) updateData.firstName = firstName;
    if (!existingData.lastName) updateData.lastName = lastName;
    if (existingData.isRecruiter === undefined) updateData.isRecruiter = false;
    if (existingData.isAdmin === undefined) updateData.isAdmin = false;
    if (!existingData.email && authUser.email) updateData.email = authUser.email;
    if (!existingData.displayName && displayName) {
      updateData.displayName = displayName;
      updateData.name = displayName;
    }
    
    if (Object.keys(updateData).length <= 1) {
      // Seulement updatedAt, rien à mettre à jour
      stats.alreadySynced++;
      return;
    }
    
    if (DRY_RUN) {
      console.log(`  [DRY-RUN] Mettrait à jour Firestore doc: ${authUser.uid}`);
      console.log(`  [DRY-RUN]   - firstName: ${updateData.firstName || existingData.firstName}, lastName: ${updateData.lastName || existingData.lastName}`);
      stats.createdInFirestore++;
      return;
    }
    
    const db = admin.firestore();
    
    // Essayer de mettre à jour par UID d'abord
    let docRef = db.collection(FIRESTORE_COLLECTION).doc(authUser.uid);
    let doc = await docRef.get();
    
    // Si le document n'existe pas avec l'UID, essayer avec l'email
    if (!doc.exists && authUser.email) {
      docRef = db.collection(FIRESTORE_COLLECTION).doc(authUser.email);
      doc = await docRef.get();
    }
    
    if (!doc.exists) {
      // Le document n'existe pas, le créer
      const docData = createFirestoreDocFromAuth(authUser);
      await docRef.set(docData);
      console.log(`  ✅ Créé Firestore doc: ${docRef.id} pour Auth user: ${authUser.uid}`);
    } else {
      // Mettre à jour le document existant
      await docRef.update(updateData);
      console.log(`  ✅ Mis à jour Firestore doc: ${docRef.id} pour Auth user: ${authUser.uid}`);
    }
    
    console.log(`     - firstName: ${updateData.firstName || existingData.firstName}, lastName: ${updateData.lastName || existingData.lastName}, isRecruiter: ${updateData.isRecruiter !== undefined ? updateData.isRecruiter : existingData.isRecruiter}`);
    stats.createdInFirestore++;
  } catch (error: any) {
    const errorMsg = `Erreur lors de la mise à jour du document Firestore pour ${authUser.uid}: ${error.message}`;
    console.error(`  ❌ ${errorMsg}`);
    stats.failedFirestore.push(authUser.uid);
    stats.errors.push({ uid: authUser.uid, error: errorMsg });
  }
}

/**
 * Crée un utilisateur Auth pour un document Firestore qui n'existe pas encore
 */
async function createAuthUser(
  docId: string,
  firestoreData: FirestoreUser,
  stats: SyncStats
): Promise<void> {
  try {
    const email = extractEmailFromFirestore(docId, firestoreData);
    if (!email) {
      throw new Error('Email manquant - impossible de créer un utilisateur Auth');
    }

    // Vérifier si un utilisateur avec cet email existe déjà
    let existingUser: admin.auth.UserRecord | null = null;
    try {
      existingUser = await admin.auth().getUserByEmail(email);
    } catch (e: any) {
      // L'utilisateur n'existe pas, c'est normal
      if (e.code !== 'auth/user-not-found') {
        throw e;
      }
    }

    if (existingUser) {
      // L'utilisateur existe déjà avec cet email, lier le document Firestore à cet UID
      console.log(`  ℹ️  Utilisateur Auth existe déjà pour l'email ${email} (UID: ${existingUser.uid})`);
      console.log(`  🔗 Liaison du document Firestore ${docId} à l'utilisateur Auth existant`);
      
      if (!DRY_RUN) {
        const db = admin.firestore();
        // Mettre à jour le document Firestore avec l'UID de l'utilisateur Auth existant
        await db.collection(FIRESTORE_COLLECTION).doc(docId).update({
          uid: existingUser.uid,
          source: 'firestore',
          syncedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`  ✅ Document Firestore ${docId} lié à l'utilisateur Auth ${existingUser.uid}`);
      }
      stats.alreadySynced++;
      return;
    }

    const uid = firestoreData.uid || docId;
    const createRequest = createAuthUserFromFirestore(uid, firestoreData);
    const password = createRequest.password!;

    if (DRY_RUN) {
      console.log(`  [DRY-RUN] Créerait Auth user: ${uid} (email: ${email})`);
      console.log(`  [DRY-RUN] Mot de passe généré: ${password} (à noter pour l'utilisateur)`);
      stats.createdInAuth++;
      return;
    }

    await admin.auth().createUser(createRequest);
    console.log(`  ✅ Créé Auth user: ${uid} (email: ${email})`);
    console.log(`  ⚠️  Mot de passe généré: ${password} (à noter pour l'utilisateur)`);
    stats.createdInAuth++;

    // Mettre à jour le document Firestore avec source et syncedAt
    const db = admin.firestore();
    await db.collection(FIRESTORE_COLLECTION).doc(docId).update({
      source: 'firestore',
      syncedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error: any) {
    const errorMsg = `Erreur lors de la création de l'utilisateur Auth pour ${docId}: ${error.message}`;
    console.error(`  ❌ ${errorMsg}`);
    stats.failedAuth.push(docId);
    stats.errors.push({ uid: docId, error: errorMsg });
  }
}

// ============================================================================
// FONCTION PRINCIPALE DE SYNCHRONISATION
// ============================================================================

async function syncUsers(): Promise<void> {
  console.log('\n🔄 Démarrage de la synchronisation...');
  console.log(`Mode: ${DRY_RUN ? 'DRY-RUN (simulation)' : 'PRODUCTION (modifications réelles)'}\n`);

  const stats: SyncStats = {
    alreadySynced: 0,
    createdInAuth: 0,
    createdInFirestore: 0,
    failedAuth: [],
    failedFirestore: [],
    errors: [],
  };

  try {
    // 1. Récupérer tous les utilisateurs
    const authUsers = await getAllAuthUsers();
    const firestoreUsers = await getAllFirestoreUsers();

    // 2. Construire les maps indexées par UID
    const authUsersByUid = new Map<string, AuthUser>();
    const firestoreUsersByUid = new Map<string, FirestoreUser>();

    // Indexer les utilisateurs Auth par UID
    for (const [uid, user] of authUsers) {
      authUsersByUid.set(uid, user);
    }

    // Indexer les documents Firestore par UID (ou email si pas d'UID)
    for (const [key, data] of firestoreUsers) {
      const uid = data.uid || key;
      if (!firestoreUsersByUid.has(uid)) {
        firestoreUsersByUid.set(uid, data);
      }
    }

    console.log('\n📊 Analyse des différences...\n');

    // 3. Pour chaque utilisateur Auth, vérifier s'il existe dans Firestore
    console.log('🔍 Vérification des utilisateurs Auth...');
    for (const [uid, authUser] of authUsersByUid) {
      const firestoreUser = firestoreUsersByUid.get(uid);
      
      if (!firestoreUser) {
        // Utilisateur Auth sans document Firestore → créer le document
        console.log(`  ⚠️  Utilisateur Auth ${uid} n'existe pas dans Firestore`);
        await createFirestoreUser(authUser, stats);
      } else {
        // Vérifier si les champs essentiels sont présents
        const needsUpdate = !firestoreUser.firstName || !firestoreUser.lastName || firestoreUser.isRecruiter === undefined;
        
        if (needsUpdate) {
          console.log(`  🔄 Document Firestore ${uid} existe mais manque des champs (firstName, lastName, ou isRecruiter)`);
          await updateFirestoreUserFields(authUser, firestoreUser, stats);
        } else {
          // Déjà synchronisé et complet
          stats.alreadySynced++;
        }
      }
    }

    // 4. Pour chaque document Firestore, vérifier s'il existe dans Auth
    console.log('\n🔍 Vérification des documents Firestore...');
    for (const [uid, firestoreData] of firestoreUsersByUid) {
      const authUser = authUsersByUid.get(uid);
      
      if (!authUser) {
        // Document Firestore sans utilisateur Auth → créer l'utilisateur Auth
        console.log(`  ⚠️  Document Firestore ${uid} n'existe pas dans Auth`);
        await createAuthUser(uid, firestoreData, stats);
      }
    }

    // 5. Afficher les statistiques
    console.log('\n' + '='.repeat(60));
    console.log('📈 RÉSULTATS DE LA SYNCHRONISATION');
    console.log('='.repeat(60));
    console.log(`✅ Déjà synchronisés: ${stats.alreadySynced}`);
    console.log(`➕ Créés dans Auth: ${stats.createdInAuth}`);
    console.log(`➕ Créés dans Firestore: ${stats.createdInFirestore}`);
    
    if (stats.failedAuth.length > 0) {
      console.log(`\n❌ Échecs création Auth (${stats.failedAuth.length}):`);
      stats.failedAuth.forEach((uid) => console.log(`   - ${uid}`));
    }
    
    if (stats.failedFirestore.length > 0) {
      console.log(`\n❌ Échecs création Firestore (${stats.failedFirestore.length}):`);
      stats.failedFirestore.forEach((uid) => console.log(`   - ${uid}`));
    }

    if (stats.errors.length > 0) {
      console.log(`\n⚠️  Erreurs détaillées (${stats.errors.length}):`);
      stats.errors.forEach(({ uid, error }) => {
        console.log(`   - ${uid}: ${error}`);
      });
    }

    console.log('\n' + '='.repeat(60));
    if (DRY_RUN) {
      console.log('ℹ️  Mode DRY-RUN: Aucune modification n\'a été effectuée');
      console.log('   Pour appliquer les changements, exécutez sans DRY_RUN=true');
    } else {
      console.log('✅ Synchronisation terminée');
    }
    console.log('='.repeat(60) + '\n');

  } catch (error: any) {
    console.error('\n❌ Erreur fatale lors de la synchronisation:', error);
    process.exit(1);
  }
}

// ============================================================================
// POINT D'ENTRÉE
// ============================================================================

async function main() {
  try {
    initializeFirebaseAdmin();
    await syncUsers();
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur fatale:', error);
    process.exit(1);
  }
}

// Exécuter le script
if (require.main === module) {
  main();
}

export { syncUsers, initializeFirebaseAdmin };

