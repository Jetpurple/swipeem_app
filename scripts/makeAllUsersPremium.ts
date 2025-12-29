/**
 * Script pour mettre tous les utilisateurs en premium
 *
 * Ce script met à jour tous les utilisateurs existants dans la collection 'subscriptions'
 * avec un abonnement premium permanent (isActive = true, expiresAt = null).
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
 *    DRY_RUN=true npm run make-premium
 *    ou
 *    DRY_RUN=true npx ts-node scripts/makeAllUsersPremium.ts
 *
 * 5. Exécution en mode PRODUCTION (modifie réellement les données):
 *    npm run make-premium
 *
 * 6. Exécution directe avec ts-node (sans compilation):
 *    DRY_RUN=true npx ts-node scripts/makeAllUsersPremium.ts
 *    npx ts-node scripts/makeAllUsersPremium.ts
 *
 * SORTIE:
 * - Affiche le nombre d'utilisateurs mis à jour
 * - Liste les utilisateurs créés/modifiés
 * - Liste les erreurs rencontrées
 */

import * as admin from 'firebase-admin';

// ============================================================================
// CONFIGURATION
// ============================================================================

const DRY_RUN = process.env.DRY_RUN === 'true' || process.env.DRY_RUN === '1';

// ============================================================================
// TYPES
// ============================================================================

interface PremiumStats {
  alreadyPremium: number;
  madePremium: number;
  failed: string[];
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
// FONCTIONS PRINCIPALES
// ============================================================================

/**
 * Récupère tous les utilisateurs Firebase Authentication
 */
async function getAllUserIds(): Promise<string[]> {
  console.log('📥 Récupération des utilisateurs Firebase Authentication...');
  const userIds: string[] = [];
  let nextPageToken: string | undefined;

  do {
    try {
      const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);

      for (const userRecord of listUsersResult.users) {
        userIds.push(userRecord.uid);
      }

      nextPageToken = listUsersResult.pageToken;
    } catch (error) {
      console.error('❌ Erreur lors de la récupération des utilisateurs Auth:', error);
      throw error;
    }
  } while (nextPageToken);

  console.log(`✅ ${userIds.length} utilisateurs récupérés depuis Firebase Auth`);
  return userIds;
}

/**
 * Met à jour ou crée un abonnement premium pour un utilisateur
 */
async function makeUserPremium(uid: string, stats: PremiumStats): Promise<void> {
  try {
    const db = admin.firestore();
    const docRef = db.collection('subscriptions').doc(uid);

    if (DRY_RUN) {
      console.log(`  [DRY-RUN] Mettrait à jour l'abonnement premium pour: ${uid}`);
      stats.madePremium++;
      return;
    }

    const doc = await docRef.get();
    const now = admin.firestore.FieldValue.serverTimestamp();

    if (doc.exists) {
      const data = doc.data();
      const isAlreadyPremium = data?.isActive === true && data?.expiresAt === null;

      if (isAlreadyPremium) {
        stats.alreadyPremium++;
        return;
      }

      // Mettre à jour l'abonnement existant
      await docRef.update({
        isActive: true,
        expiresAt: null, // Abonnement permanent
        updatedAt: now,
        planType: 'premium',
      });
      console.log(`  ✅ Mis à jour abonnement premium pour: ${uid}`);
    } else {
      // Créer un nouvel abonnement
      await docRef.set({
        uid: uid,
        isActive: true,
        expiresAt: null, // Abonnement permanent
        createdAt: now,
        updatedAt: now,
        planType: 'premium',
        autoRenew: false, // Abonnement permanent, pas de renouvellement
      });
      console.log(`  ✅ Créé abonnement premium pour: ${uid}`);
    }

    stats.madePremium++;
  } catch (error: any) {
    const errorMsg = `Erreur lors de la mise à jour premium pour ${uid}: ${error.message}`;
    console.error(`  ❌ ${errorMsg}`);
    stats.failed.push(uid);
    stats.errors.push({ uid: uid, error: errorMsg });
  }
}

// ============================================================================
// FONCTION PRINCIPALE
// ============================================================================

async function makeAllUsersPremium(): Promise<void> {
  console.log('\n🔄 Démarrage de la mise à jour premium...');
  console.log(`Mode: ${DRY_RUN ? 'DRY-RUN (simulation)' : 'PRODUCTION (modifications réelles)'}\n`);

  const stats: PremiumStats = {
    alreadyPremium: 0,
    madePremium: 0,
    failed: [],
    errors: [],
  };

  try {
    // 1. Récupérer tous les utilisateurs
    const userIds = await getAllUserIds();

    if (userIds.length === 0) {
      console.log('⚠️  Aucun utilisateur trouvé');
      return;
    }

    console.log('\n🔄 Mise à jour des abonnements premium...\n');

    // 2. Traiter chaque utilisateur
    for (const uid of userIds) {
      await makeUserPremium(uid, stats);
    }

    // 3. Afficher les statistiques
    console.log('\n' + '='.repeat(60));
    console.log('📈 RÉSULTATS DE LA MISE À JOUR PREMIUM');
    console.log('='.repeat(60));
    console.log(`✅ Déjà premium: ${stats.alreadyPremium}`);
    console.log(`➕ Mis à jour en premium: ${stats.madePremium}`);

    if (stats.failed.length > 0) {
      console.log(`\n❌ Échecs (${stats.failed.length}):`);
      stats.failed.forEach((uid) => console.log(`   - ${uid}`));
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
      console.log('✅ Mise à jour premium terminée');
      console.log(`   ${stats.madePremium} utilisateurs ont maintenant un abonnement premium permanent`);
    }
    console.log('='.repeat(60) + '\n');

  } catch (error: any) {
    console.error('\n❌ Erreur fatale lors de la mise à jour premium:', error);
    process.exit(1);
  }
}

// ============================================================================
// POINT D'ENTRÉE
// ============================================================================

async function main() {
  try {
    initializeFirebaseAdmin();
    await makeAllUsersPremium();
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

export { makeAllUsersPremium, initializeFirebaseAdmin };
