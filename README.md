# Awlad Rizk — أولاد رزق للتبريد والتكييف

**خدمات تنظيف وصيانة وإصلاح المكيفات في جدة**

🌐 **الموقع:** [awlad-rizk.vercel.app](https://awlad-rizk.vercel.app)

---

## هيكل المشروع

```
Awlad_rizk/
├── backend/          ← Next.js 14 TypeScript (Vercel)
│   ├── app/
│   │   ├── page.tsx          ← الصفحة الرئيسية (مُنفَّذة بالكامل)
│   │   ├── services/         ← خدماتنا (قيد التطوير)
│   │   ├── booking/          ← الحجز (قيد التطوير)
│   │   ├── about/            ← من نحن (قيد التطوير)
│   │   ├── contact/          ← تواصل معنا (قيد التطوير)
│   │   ├── faq/              ← الأسئلة الشائعة (قيد التطوير)
│   │   └── api/              ← REST API للتطبيق
│   ├── lib/mongodb.ts         ← اتصال MongoDB
│   └── models/index.ts        ← نماذج البيانات (22 مجموعة)
└── flutter/          ← تطبيق Flutter (Firebase)
    └── lib/
        ├── main.dart           ← نقطة الدخول
        ├── screens/home_screen.dart  ← الشاشة الرئيسية (مُنفَّذة)
        └── screens/...         ← باقي الشاشات (قيد التطوير)
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/services` | GET | جميع الخدمات (؟featured=true) |
| `/api/categories` | GET | التصنيفات |
| `/api/testimonials` | GET | التقييمات |
| `/api/faq` | GET | الأسئلة الشائعة |
| `/api/offers` | GET | العروض النشطة |
| `/api/bookings` | POST | إنشاء حجز جديد |
| `/api/service-areas` | GET | أحياء جدة المخدومة |
| `/api/time-slots` | GET | الفترات الزمنية |

## Vercel Setup

- **Root Directory:** `backend`
- **Environment Variables:**
  - `MONGODB_URI`
  - `MONGODB_DB=awladrizk`
  - `NEXT_PUBLIC_API_URL=https://awlad-rizk.vercel.app`

## Tech Stack

- **Backend:** Next.js 14 + TypeScript + MongoDB (Mongoose)
- **Flutter:** Flutter 3.41 + Google Fonts (Cairo) + HTTP
- **Database:** MongoDB Atlas Cluster0
- **Design:** Terracotta + Cream + Dark Brown (Arabic RTL)