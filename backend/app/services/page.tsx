import type { Metadata } from 'next';
import NotImplemented from '../not-implemented';

export const metadata: Metadata = {
  title: 'خدماتنا | أولاد رزق للتبريد والتكييف',
  description: 'تصفح جميع خدمات تنظيف وصيانة وإصلاح المكيفات — قريباً',
};

export default function ServicesPage() {
  return <NotImplemented title="صفحة الخدمات" description="صفحة عرض جميع خدماتنا مع إمكانية التصفية حسب التصنيف قيد التطوير وستكون متاحة قريباً جداً." />;
}
