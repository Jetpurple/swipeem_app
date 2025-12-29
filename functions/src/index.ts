import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();
const db = admin.firestore();

export const getPublicProfile = functions.https.onCall(async (data) => {
  const uid: string = data?.uid;
  if (!uid) throw new functions.https.HttpsError('invalid-argument', 'uid required');
  const snap = await db.collection('users').doc(uid).get();
  if (!snap.exists) return null;
  const user = snap.data() ?? {};
  const profile = user['profile'] ?? {};
  return {
    uid,
    firstName: profile.firstName,
    lastName: profile.lastName,
    headline: profile.headline,
    location: profile.location,
    badges: profile.badges,
    photoUrls: profile.photoUrls,
  };
});

export const onSwipeCreate = functions.firestore
  .document('swipes/{pairId}')
  .onCreate(async (snap) => {
    const swipe = snap.data() as any;
    const { fromUid, toEntityId, type, value } = swipe;
    if (value !== 'like') return;
    // check reciprocal like to form a match (simplified placeholder)
    const reciprocal = await db
      .collection('swipes')
      .where('toEntityId', '==', fromUid)
      .where('fromUid', '==', toEntityId)
      .where('value', '==', 'like')
      .limit(1)
      .get();
    if (!reciprocal.empty) {
      await db.collection('matches').add({
        candidateUid: type === 'candidate→job' ? fromUid : toEntityId,
        recruiterUid: type === 'candidate→job' ? toEntityId : fromUid,
        jobId: type === 'candidate→job' ? toEntityId : null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        active: true,
      });
    }
  });

export const onMessageCreate = functions.firestore
  .document('messages/{matchId}/threads/{messageId}')
  .onCreate(async (snap, context) => {
    const { matchId } = context.params;
    await db.collection('matches').doc(matchId).set(
      { lastMessageAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true },
    );
  });

export const computeCompatibility = functions.https.onCall(async (data) => {
  const candidateUid: string = data?.candidateUid;
  const jobId: string = data?.jobId;
  if (!candidateUid || !jobId) {
    throw new functions.https.HttpsError('invalid-argument', 'candidateUid and jobId required');
  }
  // Placeholder computation
  return { score: 68 };
});

export const webhookStripeTest = functions.https.onRequest(async (_req, res) => {
  res.status(200).json({ ok: true });
});


// HTTP function to seed all test data to Firestore
export const seedAllTestData = functions.https.onRequest(async (req, res) => {
  try {
    // Optional: simple protection (provide ?key=YOUR_KEY)
    // const key = req.query.key as string | undefined;
    // if (key !== process.env.SEED_KEY) return res.status(401).json({ error: 'unauthorized' });

    const now = admin.firestore.FieldValue.serverTimestamp();

    // ---- USERS ----
    const users: Array<{
      uid: string;
      email: string;
      firstName: string;
      lastName: string;
      isRecruiter: boolean;
      isAdmin?: boolean;
      companyName?: string;
      jobTitle?: string;
      skills?: string[];
    }> = [
      { uid: 'admin_user', email: 'admin@hireme.com', firstName: 'Admin', lastName: 'HireMe', isRecruiter: true, isAdmin: true, companyName: 'HireMe Platform', jobTitle: 'Administrateur', skills: ['Administration','Gestion','Recrutement','Flutter','Firebase'] },
      { uid: 'candidate_1', email: 'marie.dupont@email.com', firstName: 'Marie', lastName: 'Dupont', isRecruiter: false, jobTitle: 'Développeuse Flutter', skills: ['Flutter','Dart','Firebase','Git','Mobile'] },
      { uid: 'candidate_2', email: 'pierre.martin@email.com', firstName: 'Pierre', lastName: 'Martin', isRecruiter: false, jobTitle: 'Développeur Full-Stack', skills: ['React','Node.js','PostgreSQL','AWS','Docker'] },
      { uid: 'candidate_3', email: 'sophie.bernard@email.com', firstName: 'Sophie', lastName: 'Bernard', isRecruiter: false, jobTitle: 'UX/UI Designer', skills: ['Figma','Adobe XD','Prototypage','User Research','Design System'] },
      { uid: 'candidate_4', email: 'thomas.leroy@email.com', firstName: 'Thomas', lastName: 'Leroy', isRecruiter: false, jobTitle: 'DevOps Engineer', skills: ['AWS','Docker','Kubernetes','Terraform','CI/CD'] },
      { uid: 'candidate_5', email: 'laura.simon@email.com', firstName: 'Laura', lastName: 'Simon', isRecruiter: false, jobTitle: 'Product Manager', skills: ['Product Management','Agile','Analytics','Strategy','Communication'] },
      { uid: 'recruiter_2', email: 'jean.recruteur@techcorp.com', firstName: 'Jean', lastName: 'Recruteur', isRecruiter: true, companyName: 'TechCorp France', jobTitle: 'Responsable RH', skills: ['Recrutement','RH','Management','Communication'] },
      { uid: 'recruiter_3', email: 'sarah.hr@startup.io', firstName: 'Sarah', lastName: 'Johnson', isRecruiter: true, companyName: 'StartupIO', jobTitle: 'Talent Acquisition', skills: ['Recrutement','Startup','Tech','Networking'] },
    ];

    for (const u of users) {
      const base = {
        uid: u.uid,
        email: u.email,
        firstName: u.firstName,
        lastName: u.lastName,
        companyName: u.companyName ?? null,
        jobTitle: u.jobTitle ?? null,
        skills: u.skills ?? [],
        softSkills: [],
        hardSkills: [],
        isRecruiter: u.isRecruiter,
        isAdmin: !!u.isAdmin,
        isOnline: true,
        createdAt: now,
        updatedAt: now,
      };
      // Create under uid
      await db.collection('users').doc(u.uid).set(base, { merge: true });
      // Also create under email to satisfy parts of the app expecting email doc id
      await db.collection('users').doc(u.email).set(base, { merge: true });
    }

    // ---- JOB OFFERS ----
    const jobOffers = [
      { title: 'Développeur Flutter Senior', company: 'TechCorp France', location: 'Paris, France', type: 'CDI', salary: '50-65k€', experience: '3-5 ans', requirements: ['Flutter','Dart','Firebase','Git','Agile','CI/CD'] },
      { title: 'Développeuse React Native', company: 'StartupIO', location: 'Lyon, France', type: 'CDI', salary: '45-55k€', experience: '2-4 ans', requirements: ['React Native','JavaScript','Redux','API REST','TypeScript'] },
    ];
    for (const job of jobOffers) {
      await db.collection('jobOffers').add({ ...job, isActive: true, postedBy: 'recruiter_2', postedAt: now, createdAt: now });
    }

    // ---- POSTS ----
    const posts = [
      { title: 'Recrutement urgent : Développeur Flutter', content: 'Projet passionnant avec une équipe dynamique. Télétravail possible.', tags: ['Flutter','Mobile','Télétravail','Urgent'] },
      { title: "Offre d'emploi : Chef de projet digital", content: "Gestion d'équipe, projets internationaux.", tags: ['Management','Digital','Projet','International'] },
    ];
    for (const p of posts) {
      await db.collection('posts').add({ ...p, authorUid: 'admin_user', createdAt: now, isActive: true });
    }

    // ---- MATCHES & MESSAGES ----
    const pairs: Array<[string,string]> = [
      ['recruiter_2','candidate_1'],
      ['recruiter_3','candidate_2'],
      ['admin_user','candidate_3'],
    ];
    const testMessages = [
      "Salut ! J'ai vu votre profil et je suis très intéressé.",
      'Bonjour ! Votre profil correspond parfaitement à nos besoins.',
      'Merci pour votre candidature !',
      "Parfait ! J'ai hâte de collaborer avec vous.",
    ];

    for (let i = 0; i < pairs.length; i++) {
      const [recruiterUid, candidateUid] = pairs[i];
      const matchRef = await db.collection('matches').add({
        candidateUid,
        recruiterUid,
        matchedAt: now,
        lastMessageAt: now,
        lastMessageContent: testMessages[0],
        lastMessageSenderUid: recruiterUid,
        isActive: true,
        readBy: { [candidateUid]: false, [recruiterUid]: false },
      });
      const matchId = matchRef.id;

      const count = 3 + (i % 2);
      for (let j = 0; j < count; j++) {
        const isFromRecruiter = j % 2 === 0;
        const senderUid = isFromRecruiter ? recruiterUid : candidateUid;
        const receiverUid = isFromRecruiter ? candidateUid : recruiterUid;
        await db.collection('messages').add({
          matchId,
          senderUid,
          receiverUid,
          content: testMessages[j % testMessages.length],
          type: 'text',
          sentAt: now,
          isRead: j < count - 1,
          readAt: j < count - 1 ? now : null,
        });
      }
    }

    return res.status(200).json({ ok: true, seeded: true });
  } catch (e: any) {
    console.error('Seed error', e);
    return res.status(500).json({ ok: false, error: String(e?.message || e) });
  }
});

