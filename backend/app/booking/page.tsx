import type { Metadata } from 'next';
import NotImplemented from '../not-implemented';

export const metadata: Metadata = {
  title: 'احجز الآن | أولاد رزق للتبريد والتكييف',
  description: 'احجز خدمة تكييف في جدة بأقل من 60 ثانية — الدفع بعد الخدمة فقط',
};

export default function BookingPage() {
  return <NotImplemented title="نموذج الحجز" description="نموذج الحجز السريع (الاسم، الجوال، الحي، العنوان، التاريخ، الفترة الزمنية) قيد التطوير. في الوقت الحالي يمكنك التواصل معنا عبر واتساب لحجز موعدك." />;
}
