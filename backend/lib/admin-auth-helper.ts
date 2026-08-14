import { verifyOrDecodeToken } from './firebase-auth-helper';

export const ADMIN_EMAILS = [
  'naseem01099@gmail.com',
];

export async function verifyAdminToken(request: Request) {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Unauthorized: Missing token');
  }

  const token = authHeader.split('Bearer ')[1];
  const decoded = await verifyOrDecodeToken(token);

  const email = (decoded.email || '').toLowerCase().trim();
  const isAdmin = ADMIN_EMAILS.some(adminEmail => adminEmail.toLowerCase() === email);

  if (!isAdmin) {
    throw new Error('Forbidden: Admin access required');
  }

  return { decoded, email };
}
