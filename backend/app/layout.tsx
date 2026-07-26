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
  title: "أولاد رزق للتبريد والتكييف | خدمات تكييف احترافية في جدة",
  description:
    "أولاد رزق — خدمات تنظيف وصيانة وإصلاح المكيفات في جدة. ضمان 30 يوم · الدفع بعد الخدمة · فنيون محترفون · أسعار شفافة · حجز أقل من 60 ثانية.",
  keywords: "تكييف جدة, صيانة مكيفات, تنظيف مكيفات, فريون, لحام نحاس, أولاد رزق",
  openGraph: {
    title: "أولاد رزق للتبريد والتكييف",
    description: "خدمات تكييف احترافية في جدة — ضمان 30 يوم · الدفع بعد الخدمة",
    locale: "ar_SA",
    type: "website",
    siteName: "أولاد رزق",
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
