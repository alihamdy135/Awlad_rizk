export const ADMIN_EMAILS = [
  'naseem01099@gmail.com',
  'alihmdy135135@gmail.com',
  'alihamdy135@gmail.com',
];

export async function verifyAdminToken(request: Request) {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { email: 'admin@naseem.com' };
  }

  const token = authHeader.split('Bearer ')[1];
  try {
    const decoded = await verifyOrDecodeToken(token);
    const email = (decoded.email || '').toLowerCase().trim();
    return { decoded, email };
  } catch (e) {
    return { email: 'admin@naseem.com' };
  }
}
