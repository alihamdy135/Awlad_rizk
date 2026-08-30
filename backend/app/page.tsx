'use client';

import { useState, useEffect, useRef } from 'react';
import Link from 'next/link';

// ─── Types ────────────────────────────────────────────────────────────
interface Service {
  _id: string; service_id: string; name_ar: string; short_description_ar: string;
  base_price_sar: number; price_unit: string; warranty_days: number;
  image_url?: string; slug: string; is_featured: boolean;
}
interface Category {
  _id: string; category_id: string; name_ar: string; icon_name: string;
}
interface Testimonial {
  _id: string; customer_name: string; district: string; rating: number;
  review_text_ar: string; service_name_ar: string;
}
interface FAQ {
  _id: string; faq_id: string; question_ar: string; answer_ar: string;
}
interface Offer {
  _id: string; title_ar: string; description_ar: string; discount_percent: number;
}

// ─── Static Fallback Data ─────────────────────────────────────────────
const FALLBACK_SERVICES: Service[] = [
  { _id:'1', service_id:'SRV-001', name_ar:'تنظيف مكيف سبليت', short_description_ar:'تنظيف شامل للوحدة الداخلية والخارجية بمواد متخصصة', base_price_sar:120, price_unit:'للوحدة', warranty_days:30, slug:'split-ac-cleaning', is_featured:true },
  { _id:'2', service_id:'SRV-002', name_ar:'صيانة وإصلاح مكيفات', short_description_ar:'تشخيص وإصلاح جميع أعطال المكيفات بضمان كامل', base_price_sar:200, price_unit:'للزيارة', warranty_days:30, slug:'ac-repair', is_featured:true },
  { _id:'3', service_id:'SRV-003', name_ar:'تعبئة فريون', short_description_ar:'إعادة شحن غاز الفريون لتحسين كفاءة التبريد', base_price_sar:150, price_unit:'للوحدة', warranty_days:15, slug:'freon-refill', is_featured:true },
  { _id:'4', service_id:'SRV-004', name_ar:'لحام نحاس', short_description_ar:'إصلاح التسربات بتقنية اللحام النحاسي الاحترافي', base_price_sar:250, price_unit:'للتدخل', warranty_days:30, slug:'copper-welding', is_featured:false },
  { _id:'5', service_id:'SRV-005', name_ar:'عقد صيانة دورية', short_description_ar:'عقد سنوي بزيارات دورية لصيانة وقائية شاملة', base_price_sar:500, price_unit:'سنوياً', warranty_days:365, slug:'maintenance-contract', is_featured:false },
  { _id:'6', service_id:'SRV-006', name_ar:'تنظيف داكت سنترال', short_description_ar:'تنظيف قنوات التهوية للأنظمة المركزية', base_price_sar:800, price_unit:'للنظام', warranty_days:30, slug:'duct-cleaning', is_featured:false },
];
const FALLBACK_CATEGORIES: Category[] = [
  { _id:'1', category_id:'CAT-01', name_ar:'تنظيف', icon_name:'🧹' },
  { _id:'2', category_id:'CAT-02', name_ar:'صيانة وإصلاح', icon_name:'🔧' },
  { _id:'3', category_id:'CAT-03', name_ar:'فريون وغاز', icon_name:'❄️' },
  { _id:'4', category_id:'CAT-04', name_ar:'لحام', icon_name:'🔥' },
  { _id:'5', category_id:'CAT-05', name_ar:'عقود', icon_name:'📋' },
  { _id:'6', category_id:'CAT-06', name_ar:'سنترال', icon_name:'🏢' },
];
const FALLBACK_TESTIMONIALS: Testimonial[] = [
  { _id:'1', customer_name:'محمد العمري', district:'حي الروضة', rating:5, review_text_ar:'خدمة ممتازة وفنيون محترفون. نظفوا المكيف بشكل احترافي والآن يعمل كأنه جديد. أنصح الجميع بهم.', service_name_ar:'تنظيف مكيف سبليت' },
  { _id:'2', customer_name:'سارة القحطاني', district:'حي النزهة', rating:5, review_text_ar:'تواصلت معهم وجاؤوا في نفس اليوم. الفني كان محترفاً وشرح لي سبب العطل وأصلحه بسرعة. شكراً أولاد رزق!', service_name_ar:'صيانة وإصلاح مكيفات' },
  { _id:'3', customer_name:'عبدالله الغامدي', district:'حي الصفا', rating:5, review_text_ar:'عبأوا الفريون وأصلحوا مشكلة التسريب بأسعار معقولة جداً. الدفع بعد الخدمة أعطاني راحة بال كبيرة.', service_name_ar:'تعبئة فريون' },
];
const FALLBACK_FAQS: FAQ[] = [
  { _id:'1', faq_id:'FAQ-01', question_ar:'متى يتم الدفع؟', answer_ar:'الدفع يكون بعد إتمام الخدمة بالكامل وتأكدك من جودة العمل. لا نطلب أي دفع مسبق.' },
  { _id:'2', faq_id:'FAQ-02', question_ar:'ما هي مدة الضمان على الخدمة؟', answer_ar:'جميع خدماتنا تحمل ضمان 30 يوماً على الأقل. إذا عاد المشكلة خلال هذه الفترة، نصلحها مجاناً.' },
  { _id:'3', faq_id:'FAQ-03', question_ar:'كم الوقت المستغرق للرد على طلب الحجز؟', answer_ar:'يتواصل معكم فريقنا خلال دقائق معدودة لتأكيد موعد الفني.' },
  { _id:'4', faq_id:'FAQ-04', question_ar:'هل تخدمون جميع أحياء جدة؟', answer_ar:'نخدم معظم أحياء جدة. يمكنك اختيار حيك في نموذج الحجز للتأكد من التغطية.' },
];

// ─── Star Rating ──────────────────────────────────────────────────────
function Stars({ rating }: { rating: number }) {
  return (
    <div className="stars">
      {[1,2,3,4,5].map(i => (
        <span key={i} className="star" style={{ color: i <= rating ? '#D4A643' : '#E8D9C4' }}>★</span>
      ))}
    </div>
  );
}

// ─── Service Icon ──────────────────────────────────────────────────────
function ServiceIcon({ name }: { name: string }) {
  const icons: Record<string, string> = {
    'تنظيف مكيف سبليت': '🧹',
    'صيانة وإصلاح مكيفات': '🔧',
    'تعبئة فريون': '❄️',
    'لحام نحاس': '🔥',
    'عقد صيانة دورية': '📋',
    'تنظيف داكت سنترال': '🏢',
  };
  return <span style={{ fontSize: 52 }}>{icons[name] || '❄️'}</span>;
}

// ─── Header ───────────────────────────────────────────────────────────
function Header() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const navLinks = [
    { href: '/services', label: 'خدماتنا' },
    { href: '/about', label: 'من نحن' },
    { href: '/faq', label: 'الأسئلة الشائعة' },
    { href: '/contact', label: 'تواصل معنا' },
  ];

  return (
    <>
      <header className={`header${scrolled ? ' scrolled' : ''}`}>
        <div className="container">
          <div className="header-inner">
            {/* Logo */}
            <Link href="/" className="logo" id="header-logo">
              <div className="logo-icon">❄️</div>
              <div>
                <div style={{ fontSize: 16, fontWeight: 700 }}>نسيم (Naseem)</div>
                <div style={{ fontSize: 11, color: '#7A6355', fontWeight: 400 }}>للتبريد والتكييف</div>
              </div>
            </Link>

            {/* Desktop Nav */}
            <nav className="nav">
              {navLinks.map(l => (
                <Link key={l.href} href={l.href} className="nav-link" id={`nav-${l.href.slice(1)}`}>{l.label}</Link>
              ))}
            </nav>

            {/* Book CTA */}
            <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
              <Link href="/booking" className="btn btn-primary btn-sm" id="header-book-btn" style={{ display: 'none' }}>
                <span>📅</span> احجز الآن
              </Link>
              <style>{`@media(min-width:768px){#header-book-btn{display:flex!important}}`}</style>

              {/* Mobile toggle */}
              <button
                className="menu-toggle"
                id="mobile-menu-toggle"
                onClick={() => setMobileOpen(true)}
                aria-label="فتح القائمة"
              >☰</button>
            </div>
          </div>
        </div>
      </header>

      {/* Mobile Nav Overlay */}
      <div className={`mobile-nav${mobileOpen ? ' open' : ''}`} onClick={() => setMobileOpen(false)}>
        <div className="mobile-nav-panel" onClick={e => e.stopPropagation()}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
            <div className="logo">
              <div className="logo-icon" style={{ width: 38, height: 38, fontSize: 18 }}>❄️</div>
              <span style={{ fontWeight: 700 }}>أولاد رزق</span>
            </div>
            <button
              id="mobile-menu-close"
              onClick={() => setMobileOpen(false)}
              style={{ width:36, height:36, borderRadius:8, border:'1.5px solid #E8D9C4', background:'transparent', fontSize:18 }}
            >✕</button>
          </div>

          {navLinks.map(l => (
            <Link key={l.href} href={l.href} className="mobile-nav-link" id={`mobile-nav-${l.href.slice(1)}`} onClick={() => setMobileOpen(false)}>
              {l.label}
            </Link>
          ))}
          <div style={{ marginTop: 'auto', paddingTop: 24 }}>
            <Link href="/booking" className="btn btn-primary btn-full" id="mobile-book-btn" onClick={() => setMobileOpen(false)}>
              📅 احجز الآن
            </Link>
          </div>
        </div>
      </div>
    </>
  );
}

// ─── Hero ──────────────────────────────────────────────────────────────
function Hero() {
  return (
    <section className="hero" id="hero-section" aria-label="الصفحة الرئيسية">
      <div className="hero-bg" />
      <div className="hero-pattern" />
      <div className="container">
        <div className="hero-content">
          <h1 className="hero-title fade-up fade-up-d1">
            مكيفك يستحق<br />
            <span>خدمة احترافية</span><br />
            بضمان حقيقي
          </h1>
          <p className="hero-subtitle fade-up fade-up-d2">
            تنظيف، صيانة، وإصلاح المكيفات في جدة — فنيون معتمدون،
            ضمان 30 يوم، والدفع فقط بعد اكتمال الخدمة.
          </p>
          <div className="hero-actions fade-up fade-up-d3">
            <Link href="/booking" className="btn btn-primary btn-lg" id="hero-book-btn">
              📅 احجز الآن — أقل من دقيقة
            </Link>
            <Link href="/services" className="btn btn-white btn-lg" id="hero-services-btn">
              تصفح خدماتنا
            </Link>
          </div>
          <div className="hero-stats fade-up">
            <div className="hero-stat">
              <span className="hero-stat-num">+500</span>
              <span className="hero-stat-label">عميل راضٍ</span>
            </div>
            <div className="hero-stat">
              <span className="hero-stat-num">4.9★</span>
              <span className="hero-stat-label">متوسط التقييم</span>
            </div>
            <div className="hero-stat">
              <span className="hero-stat-num">30</span>
              <span className="hero-stat-label">يوم ضمان</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

// ─── Trust Bar ─────────────────────────────────────────────────────────
function TrustBar() {
  const items = [
    { icon: '✅', text: 'ضمان 30 يوم على جميع الخدمات' },
    { icon: '💳', text: 'الدفع بعد اكتمال الخدمة فقط' },
    { icon: '👨‍🔧', text: 'فنيون محترفون ومدربون' },
    { icon: '💰', text: 'أسعار شفافة بدون رسوم خفية' },
    { icon: '⚡', text: 'حجز في أقل من 60 ثانية' },
  ];
  return (
    <div className="trust-bar" id="trust-bar">
      <div className="container">
        <div className="trust-bar-inner">
          {items.map((item, i) => (
            <div key={i} className="trust-item">
              <span className="trust-item-icon">{item.icon}</span>
              <span>{item.text}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Categories ────────────────────────────────────────────────────────
function Categories({ categories }: { categories: Category[] }) {
  return (
    <section className="section-gap" id="categories-section">
      <div className="container">
        <h2 className="section-title">تصفح حسب التصنيف</h2>
        <p className="section-subtitle">اختر نوع الخدمة التي تحتاجها</p>
        <div className="categories-scroll">
          {categories.map((cat, i) => (
            <Link href={`/services?category=${cat.category_id}`} key={cat._id} id={`cat-chip-${i}`}>
              <div className="category-chip">
                <span className="icon">{cat.icon_name}</span>
                <span className="label">{cat.name_ar}</span>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}

// ─── Services ──────────────────────────────────────────────────────────
function FeaturedServices({ services }: { services: Service[] }) {
  return (
    <section className="section-gap" id="featured-services-section" style={{ background: '#FFFBF5', padding: '48px 0' }}>
      <div className="container">
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', flexWrap:'wrap', gap:16, marginBottom:32 }}>
          <div>
            <h2 className="section-title" style={{ marginBottom:4 }}>خدماتنا الأكثر طلباً</h2>
            <p className="section-subtitle" style={{ marginBottom:0 }}>جودة تُثبت نفسها في كل زيارة</p>
          </div>
          <Link href="/services" className="btn btn-secondary" id="view-all-services-btn">
            عرض جميع الخدمات ←
          </Link>
        </div>

        <div className="services-grid">
          {services.slice(0, 6).map((svc, i) => (
            <div key={svc._id} className="service-card" id={`service-card-${i}`}>
              <div className="service-card-img">
                {svc.image_url
                  ? <img src={svc.image_url} alt={svc.name_ar} style={{ width:'100%', height:'100%', objectFit:'cover' }} />
                  : <ServiceIcon name={svc.name_ar} />}
              </div>
              <div className="service-card-body">
                <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', gap:8, flexWrap:'wrap' }}>
                  <h3 className="service-card-title">{svc.name_ar}</h3>
                  <span className="badge badge-gold">⭐ ضمان {svc.warranty_days} يوم</span>
                </div>
                <p className="service-card-desc">{svc.short_description_ar}</p>
                <div className="service-card-footer">
                  <div className="service-price">
                    {svc.base_price_sar} ريال <span>/ {svc.price_unit}</span>
                  </div>
                  <Link
                    href={`/services/${svc.slug}`}
                    className="btn btn-primary btn-sm"
                    id={`service-details-btn-${i}`}
                  >
                    التفاصيل
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

// ─── Offers Banner ─────────────────────────────────────────────────────
function OffersBanner({ offers }: { offers: Offer[] }) {
  if (!offers.length) return null;
  const offer = offers[0];
  return (
    <section className="section-gap" id="offers-section">
      <div className="container">
        <div className="offer-banner">
          <div className="offer-discount">{offer.discount_percent}%</div>
          <div className="offer-body">
            <div className="offer-title">{offer.title_ar}</div>
            <div className="offer-desc">{offer.description_ar}</div>
          </div>
          <div style={{ position:'relative', zIndex:1 }}>
            <Link href="/booking" className="btn btn-white" id="offer-book-btn">
              احجز الآن ولا تفوّت العرض
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

// ─── Testimonials ──────────────────────────────────────────────────────
function Testimonials({ testimonials }: { testimonials: Testimonial[] }) {
  return (
    <section className="section-gap" id="testimonials-section" style={{ background: '#FFFBF5', padding: '48px 0' }}>
      <div className="container">
        <h2 className="section-title">ماذا يقول عملاؤنا</h2>
        <p className="section-subtitle">تجارب حقيقية من عملاء جدة</p>
        <div className="testimonials-grid">
          {testimonials.map((t, i) => (
            <div key={t._id} className="testimonial-card" id={`testimonial-card-${i}`}>
              <div className="testimonial-header">
                <div className="testimonial-avatar">
                  {t.customer_name.charAt(0)}
                </div>
                <div>
                  <div className="testimonial-name">{t.customer_name}</div>
                  <div className="testimonial-location">📍 {t.district}</div>
                </div>
              </div>
              <Stars rating={t.rating} />
              <p className="testimonial-text">"{t.review_text_ar}"</p>
              <div className="testimonial-service">✅ {t.service_name_ar}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

// ─── FAQ ──────────────────────────────────────────────────────────────
function FAQSection({ faqs }: { faqs: FAQ[] }) {
  const [openIdx, setOpenIdx] = useState<number | null>(null);
  return (
    <section className="section-gap" id="faq-section">
      <div className="container">
        <div style={{ maxWidth:720, margin:'0 auto' }}>
          <h2 className="section-title" style={{ textAlign:'center' }}>الأسئلة الشائعة</h2>
          <p className="section-subtitle" style={{ textAlign:'center' }}>إجابات على أبرز أسئلتكم</p>
          <div className="faq-list">
            {faqs.slice(0, 4).map((faq, i) => (
              <div key={faq._id} className={`faq-item${openIdx === i ? ' open' : ''}`} id={`faq-item-${i}`}>
                <button
                  className="faq-question"
                  id={`faq-btn-${i}`}
                  onClick={() => setOpenIdx(openIdx === i ? null : i)}
                  aria-expanded={openIdx === i}
                >
                  <span>{faq.question_ar}</span>
                  <span className="faq-icon">+</span>
                </button>
                <div className="faq-answer">
                  <div className="faq-answer-inner">{faq.answer_ar}</div>
                </div>
              </div>
            ))}
          </div>
          <div style={{ textAlign:'center', marginTop:32 }}>
            <Link href="/faq" className="btn btn-secondary" id="view-all-faq-btn">
              عرض جميع الأسئلة
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

// ─── Final CTA ──────────────────────────────────────────────────────────
function FinalCTA() {
  return (
    <section className="section-gap" id="final-cta-section">
      <div className="container">
        <div className="cta-section">
          <h2 className="cta-title">جاهز لتحسين أداء مكيفك؟</h2>
          <p className="cta-subtitle">
            احجز الآن في أقل من دقيقة · فنيون في طريقهم إليك خلال ساعات · الدفع بعد الخدمة فقط
          </p>
          <div className="trust-bar-inner" style={{ marginBottom: 32, justifyContent: 'center', flexWrap: 'wrap', gap: 12 }}>
            {['✅ ضمان 30 يوم', '💳 الدفع بعد الخدمة', '⚡ استجابة فورية', '🔒 لا رسوم خفية'].map((t, i) => (
              <div key={i} style={{ background: 'rgba(255,255,255,0.1)', borderRadius: 8, padding: '6px 14px', fontSize: 13, color: 'rgba(255,255,255,0.9)', fontWeight: 500 }}>
                {t}
              </div>
            ))}
          </div>
          <div className="cta-actions">
            <Link href="/booking" className="btn btn-primary btn-lg" id="cta-book-btn">
              📅 احجز الآن مجاناً
            </Link>
            <a
              href="https://wa.me/966500000000?text=أهلاً، أريد حجز خدمة تكييف"
              className="btn btn-white btn-lg"
              id="cta-whatsapp-btn"
              target="_blank"
              rel="noopener noreferrer"
            >
              💬 تواصل عبر واتساب
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}

// ─── Footer ────────────────────────────────────────────────────────────
function Footer() {
  return (
    <footer className="footer" id="main-footer">
      <div className="container">
        <div className="footer-grid">
          {/* Brand */}
          <div>
            <div className="footer-logo">
              <div className="logo-icon" style={{ width:40, height:40, fontSize:18 }}>❄️</div>
              <div>
                <div>نسيم (Naseem)</div>
                <div style={{ fontSize:12, fontWeight:400, color:'rgba(255,255,255,0.6)' }}>للتبريد والتكييف</div>
              </div>
            </div>
            <p className="footer-desc">
              خدمات تنظيف وصيانة وإصلاح المكيفات في جدة بأعلى معايير الجودة. فنيون محترفون، ضمان حقيقي، ودفع بعد الخدمة.
            </p>
            <div className="social-links">
              {[
                { icon: '📘', label: 'فيسبوك', href: '#' },
                { icon: '📸', label: 'إنستغرام', href: '#' },
                { icon: '🐦', label: 'تويتر', href: '#' },
                { icon: '💬', label: 'واتساب', href: 'https://wa.me/966500000000' },
              ].map((s, i) => (
                <a key={i} href={s.href} className="social-link" id={`social-${i}`} aria-label={s.label}>{s.icon}</a>
              ))}
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="footer-heading">روابط سريعة</h3>
            <ul className="footer-links">
              {[
                { href:'/services', label:'خدماتنا' },
                { href:'/about', label:'من نحن' },
                { href:'/faq', label:'الأسئلة الشائعة' },
                { href:'/contact', label:'تواصل معنا' },
                { href:'/privacy', label:'سياسة الخصوصية' },
                { href:'/terms', label:'الشروط والأحكام' },
              ].map(l => (
                <li key={l.href}><Link href={l.href} id={`footer-link-${l.href.slice(1)}`}>{l.label}</Link></li>
              ))}
            </ul>
          </div>

          {/* Services */}
          <div>
            <h3 className="footer-heading">خدماتنا</h3>
            <ul className="footer-links">
              {['تنظيف مكيفات','صيانة وإصلاح','تعبئة فريون','لحام نحاس','عقود صيانة','داكت سنترال'].map((s, i) => (
                <li key={i}><Link href="/services" id={`footer-service-${i}`}>{s}</Link></li>
              ))}
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="footer-heading">تواصل معنا</h3>
            <div>
              <div className="footer-contact-item">
                <span className="fi">📍</span>
                <span>جدة، المملكة العربية السعودية</span>
              </div>
              <div className="footer-contact-item">
                <span className="fi">📞</span>
                <span>+966 50 000 0000</span>
              </div>
              <div className="footer-contact-item">
                <span className="fi">💬</span>
                <span>متاح على واتساب</span>
              </div>
            </div>
            <h3 className="footer-heading" style={{ marginTop: 24 }}>ساعات العمل</h3>
            <div style={{ fontSize: 14, color: 'rgba(255,255,255,0.7)' }}>
              <div style={{ marginBottom: 6 }}>السبت – الخميس: 8ص – 10م</div>
              <div>الجمعة: 2م – 10م</div>
            </div>
          </div>
        </div>

        <div className="footer-bottom">
          <span>© {new Date().getFullYear()} نسيم للتبريد والتكييف - Naseem. جميع الحقوق محفوظة.</span>
          <span>صُنع بـ ❤️ في جدة</span>
        </div>
      </div>
    </footer>
  );
}

// ─── WhatsApp FAB ──────────────────────────────────────────────────────
function WhatsAppFAB() {
  return (
    <a
      href="https://wa.me/966500000000?text=أهلاً، أريد الاستفسار عن خدمات التكييف"
      className="whatsapp-fab"
      id="whatsapp-fab"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="تواصل عبر واتساب"
    >
      <span className="whatsapp-fab-pulse" />
      💬
    </a>
  );
}

// ─── Sticky Book Button (Mobile) ──────────────────────────────────────
function StickyBookBtn() {
  return (
    <>
      <div id="sticky-book-bar" style={{
        position: 'fixed', bottom: 0, right: 0, left: 0, zIndex: 90,
        background: 'white', borderTop: '1px solid #E8D9C4',
        padding: '12px 16px', display: 'none',
      }}>
        <Link href="/booking" className="btn btn-primary btn-full" id="sticky-book-btn">
          📅 احجز الآن — مجاناً وبدون التزام
        </Link>
      </div>
      <style>{`@media(max-width:767px){#sticky-book-bar{display:block!important}}`}</style>
    </>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────
export default function HomePage() {
  const [services, setServices] = useState<Service[]>(FALLBACK_SERVICES);
  const [categories, setCategories] = useState<Category[]>(FALLBACK_CATEGORIES);
  const [testimonials, setTestimonials] = useState<Testimonial[]>(FALLBACK_TESTIMONIALS);
  const [faqs, setFaqs] = useState<FAQ[]>(FALLBACK_FAQS);
  const [offers, setOffers] = useState<Offer[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    const base = typeof window !== 'undefined' ? window.location.origin : '';
    Promise.allSettled([
      fetch(`${base}/api/services?featured=true`).then(r => r.json()),
      fetch(`${base}/api/categories`).then(r => r.json()),
      fetch(`${base}/api/testimonials`).then(r => r.json()),
      fetch(`${base}/api/faq?limit=4`).then(r => r.json()),
      fetch(`${base}/api/offers`).then(r => r.json()),
    ]).then(([svcs, cats, tests, faqR, offR]) => {
      if (svcs.status === 'fulfilled' && svcs.value.success && svcs.value.data.length) setServices(svcs.value.data);
      if (cats.status === 'fulfilled' && cats.value.success && cats.value.data.length) setCategories(cats.value.data);
      if (tests.status === 'fulfilled' && tests.value.success && tests.value.data.length) setTestimonials(tests.value.data);
      if (faqR.status === 'fulfilled' && faqR.value.success && faqR.value.data.length) setFaqs(faqR.value.data);
      if (offR.status === 'fulfilled' && offR.value.success) setOffers(offR.value.data);
      setLoaded(true);
    });
  }, []);

  return (
    <>
      <Header />
      <main id="main-content">
        <Hero />
        <TrustBar />
        <Categories categories={categories} />
        <FeaturedServices services={services} />
        <OffersBanner offers={offers} />
        <Testimonials testimonials={testimonials} />
        <FAQSection faqs={faqs} />
        <FinalCTA />
      </main>
      <Footer />
      <WhatsAppFAB />
      <StickyBookBtn />
    </>
  );
}
