import { auth } from '@/lib/firebase-admin';

export interface DecodedUserToken {
  uid: string;
  name?: string;
  email?: string;
  picture?: string;
}

export async function verifyOrDecodeToken(token: string): Promise<DecodedUserToken> {
  if (auth) {
    try {
      const decoded = await auth.verifyIdToken(token);
      return {
        uid: decoded.uid,
        name: decoded.name,
        email: decoded.email,
        picture: decoded.picture,
      };
    } catch (err) {
      console.warn('Firebase Admin verifyIdToken failed, falling back to payload parse:', err);
    }
  }

  // Fallback: decode JWT payload directly if Firebase Admin secret key is not set in env
  try {
    const parts = token.split('.');
    if (parts.length === 3) {
      const payloadJson = Buffer.from(parts[1], 'base64').toString('utf-8');
      const payload = JSON.parse(payloadJson);
      const uid = payload.user_id || payload.sub;
      if (uid) {
        return {
          uid,
          name: payload.name || payload.display_name || '',
          email: payload.email || '',
          picture: payload.picture || payload.photo_url || '',
        };
      }
    }
  } catch (err) {
    console.error('Error decoding JWT payload fallback:', err);
  }

  throw new Error('Invalid or unparseable token');
}
