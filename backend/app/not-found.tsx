import Link from 'next/link';
export default function NotFound() {
  return (
    <main dir="rtl" style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: 48, background: '#FAF3EA', fontFamily: 'Cairo, sans-serif' }}>
      <div style={{ fontSize: 100, marginBottom: 24 }}>❄️</div>
      <h1 style={{ fontSize: 'clamp(22px,4vw,32px)', fontWeight: 700, color: '#3B2A1F', marginBottom: 12 }}>الصفحة غير موجودة</h1>
      <p style={{ color: '#7A6355', fontSize: 16, lineHeight: 1.8, marginBottom: 32, maxWidth: 400 }}>عذراً، الصفحة التي تبحث عنها غير موجودة. يمكنك العودة للصفحة الرئيسية.</p>
      <Link href="/" style={{ background: '#C1502E', color: 'white', padding: '14px 28px', borderRadius: 12, fontWeight: 600, fontSize: 16, textDecoration: 'none' }}>
        🏠 العودة للرئيسية
      </Link>
    </main>
  );
}
