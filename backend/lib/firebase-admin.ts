import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  try {
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
    
    if (serviceAccountJson) {
      const serviceAccount = JSON.parse(serviceAccountJson);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log('Firebase Admin initialized successfully.');
    } else {
      console.warn('FIREBASE_SERVICE_ACCOUNT_KEY is not set. Firebase Admin not initialized.');
    }
  } catch (error) {
    console.error('Firebase Admin initialization error', error);
  }
}

export const auth = admin.apps.length ? admin.auth() : null;
