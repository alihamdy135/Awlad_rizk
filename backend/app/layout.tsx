import type { Metadata } from "next";
import { Cairo } from "next/font/google";
import "./globals.css";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  weight: ["400", "500", "600", "700", "900"],
  variable: "--font-cairo",
  display: "swap",
});

export const metadata: Metadata = {
  title: "نسيم للتبريد والتكييف | Naseem HVAC Services",
  description:
    "نسيم (Naseem) — خدمات تنظيف وصيانة وإصلاح المكيفات في المملكة. ضمان 30 يوم · الدفع بعد الخدمة · فنيون محترفون · أسعار شفافة · حجز أقل من 60 ثانية.",
  keywords: "تكييف جدة, صيانة مكيفات, تنظيف مكيفات, فريون, لحام نحاس, نسيم, Naseem",
  openGraph: {
    title: "نسيم للتبريد والتكييف - Naseem",
    description: "خدمات تكييف احترافية — ضمان 30 يوم · الدفع بعد الخدمة",
    locale: "ar_SA",
    type: "website",
    siteName: "نسيم (Naseem)",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className={cairo.variable}>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body className={cairo.className}>{children}</body>
    </html>
  );
}
