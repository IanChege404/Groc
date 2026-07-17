import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

function getServiceAccount() {
  const serviceAccountKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (serviceAccountKey) {
    const decoded = Buffer.from(serviceAccountKey, 'base64').toString('utf-8');
    return JSON.parse(decoded);
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

  if (projectId && clientEmail && privateKey) {
    return { projectId, clientEmail, privateKey };
  }

  throw new Error(
    'Firebase Admin: Provide FIREBASE_SERVICE_ACCOUNT_KEY (base64) or FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY'
  );
}

const app = getApps().length === 0
  ? initializeApp({ credential: cert(getServiceAccount()) })
  : getApps()[0];

export const adminDb = getFirestore(app);
