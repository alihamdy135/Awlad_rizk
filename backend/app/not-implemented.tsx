import Link from 'next/link';

function NotImplemented({ title, description }: { title: string; description?: string }) {
  return (
    <>
      <div style={{
        position: 'sticky', top: 0, zIndex: 100,
        background: 'rgba(250, 243, 234, 0.95)',
        backdropFilter: 'blur(12px)',
        borderBottom: '1px solid #E8D9C4',
        padding: '0',
      }}>
        <div style={{ maxWidth: 1280, margin: '0 auto', padding: '0 16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 70 }}>
            <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: 10, fontWeight: 700, fontSize: 18, color: '#3B2A1F', textDecoration: 'none' }}>
              <div style={{ width: 44, height: 44, borderRadius: '50%', background: 'linear-gradient(135deg, #C1502E 0%, #A3401F 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white', fontSize: 22, boxShadow: '0 3px 10px rgba(193,80,46,0.4)' }}>❄️</div>
              <div>
                <div style={{ fontSize: 16, fontWeight: 700 }}>أولاد رزق</div>
                <div style={{ fontSize: 11, color: '#7A6355', fontWeight: 400 }}>للتبريد والتكييف</div>
              </div>
            </Link>
            <Link href="/booking" style={{ display: 'inline-flex', alignItems: 'center', gap: 8, background: '#C1502E', color: 'white', padding: '10px 20px', borderRadius: 12, fontWeight: 600, fontSize: 14, textDecoration: 'none' }}>
              📅 احجز الآن
            </Link>
          </div>
        </div>
      </div>
      <main style={{ minHeight: '70vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '48px 24px', background: '#FAF3EA', direction: 'rtl' }}>
        <div style={{ maxWidth: 560 }}>
          <div style={{ fontSize: 80, marginBottom: 24 }}>🚧</div>
          <div style={{ display: 'inline-block', background: 'rgba(212,166,67,0.15)', border: '1px solid rgba(212,166,67,0.4)', color: '#9A6F1A', padding: '8px 20px', borderRadius: 50, fontSize: 14, fontWeight: 600, marginBottom: 24 }}>
            قريباً
          </div>
          <h1 style={{ fontSize: 'clamp(22px,4vw,32px)', fontWeight: 700, color: '#3B2A1F', marginBottom: 12, fontFamily: 'Cairo, sans-serif' }}>
            {title}
          </h1>
          <p style={{ color: '#7A6355', fontSize: 16, lineHeight: 1.8, marginBottom: 32, fontFamily: 'Cairo, sans-serif' }}>
            {description || 'هذه الصفحة قيد التطوير وستكون متاحة قريباً. في الوقت الحالي يمكنك العودة للصفحة الرئيسية أو التواصل معنا مباشرة.'}
          </p>
          <div style={{ display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap' }}>
            <Link href="/" style={{ display: 'inline-flex', alignItems: 'center', gap: 8, background: '#C1502E', color: 'white', padding: '14px 28px', borderRadius: 12, fontWeight: 600, fontSize: 16, textDecoration: 'none', boxShadow: '0 4px 14px rgba(193,80,46,0.35)' }}>
              🏠 الصفحة الرئيسية
            </Link>
            <a href="https://wa.me/966500000000?text=أهلاً، أريد الاستفسار" target="_blank" rel="noopener noreferrer" style={{ display: 'inline-flex', alignItems: 'center', gap: 8, background: '#25D366', color: 'white', padding: '14px 28px', borderRadius: 12, fontWeight: 600, fontSize: 16, textDecoration: 'none' }}>
              💬 تواصل عبر واتساب
            </a>
          </div>
        </div>
      </main>
      <a href="https://wa.me/966500000000" target="_blank" rel="noopener noreferrer" style={{ position: 'fixed', bottom: 24, left: 24, width: 60, height: 60, borderRadius: '50%', background: '#25D366', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, boxShadow: '0 4px 20px rgba(37,211,102,0.5)', zIndex: 999, textDecoration: 'none' }}>
        💬
      </a>
    </>
  );
}

export default NotImplemented;
