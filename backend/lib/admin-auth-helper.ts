import { verifyOrDecodeToken } from '@/lib/firebase-auth-helper';

export const ADMIN_EMAILS = [
  'naseem01099@gmail.com',
  'alihmdy135135@gmail.com',
  'alihamdy135@gmail.com',
];

export async function verifyAdminToken(request: Request) {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // No token: allow for backward compat but mark as unauthenticated
    return { email: '', isAdmin: false, decoded: null as any };
  }

  const token = authHeader.split('Bearer ')[1];
  try {
    const decoded = await verifyOrDecodeToken(token);
    const email = (decoded.email || '').toLowerCase().trim();
    const isAdmin = ADMIN_EMAILS.map(e => e.toLowerCase().trim()).includes(email);
    return { decoded, email, isAdmin };
  } catch (e) {
    return { email: '', isAdmin: false, decoded: null as any };
  }
}

export function isAdminEmail(email: string | undefined): boolean {
  if (!email) return false;
  return ADMIN_EMAILS.map(e => e.toLowerCase().trim()).includes(email.toLowerCase().trim());
}
