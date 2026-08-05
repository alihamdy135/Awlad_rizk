import mongoose, { Schema, Document, Model } from 'mongoose';

// ─── Category ───────────────────────────────────────────────
export interface ICategory extends Document {
  category_id: string;
  name_ar: string;
  name_en: string;
  icon_name: string;
  display_order: number;
  is_active: boolean;
}
const CategorySchema = new Schema<ICategory>({
  category_id: { type: String, required: true, unique: true },
  name_ar: String,
  name_en: String,
  icon_name: String,
  display_order: Number,
  is_active: { type: Boolean, default: true },
}, { collection: 'categories', timestamps: true });

// ─── Service ────────────────────────────────────────────────
export interface IService extends Document {
  service_id: string;
  category_id: string;
  name_ar: string;
  name_en: string;
  short_description_ar: string;
  full_description_ar: string;
  base_price_sar: number;
  price_unit: string;
  duration_minutes: number;
  warranty_days: number;
  image_url: string;
  gallery_urls: string;
  slug: string;
  is_active: boolean;
  is_featured: boolean;
  display_order: number;
}
const ServiceSchema = new Schema<IService>({
  service_id: { type: String, required: true, unique: true },
  category_id: String,
  name_ar: String,
  name_en: String,
  short_description_ar: String,
  full_description_ar: String,
  base_price_sar: Number,
  price_unit: String,
  duration_minutes: Number,
  warranty_days: Number,
  image_url: String,
  gallery_urls: String,
  slug: String,
  is_active: { type: Boolean, default: true },
  is_featured: { type: Boolean, default: false },
  display_order: Number,
}, { collection: 'services', timestamps: true });

// ─── Testimonial ────────────────────────────────────────────
export interface ITestimonial extends Document {
  testimonial_id: string;
  customer_name: string;
  district: string;
  rating: number;
  review_text_ar: string;
  service_name_ar: string;
  avatar_url: string;
  is_active: boolean;
  display_order: number;
}
const TestimonialSchema = new Schema<ITestimonial>({
  testimonial_id: { type: String, required: true, unique: true },
  customer_name: String,
  district: String,
  rating: Number,
  review_text_ar: String,
  service_name_ar: String,
  avatar_url: String,
  is_active: { type: Boolean, default: true },
  display_order: Number,
}, { collection: 'testimonials', timestamps: true });

// ─── Offer ───────────────────────────────────────────────────
export interface IOffer extends Document {
  offer_id: string;
  title_ar: string;
  description_ar: string;
  discount_percent: number;
  applicable_service_ids: string;
  start_date: string;
  end_date: string;
  is_active: boolean;
  display_order: number;
  badge_color: string;
}
const OfferSchema = new Schema<IOffer>({
  offer_id: { type: String, required: true, unique: true },
  title_ar: String,
  description_ar: String,
  discount_percent: Number,
  applicable_service_ids: String,
  start_date: String,
  end_date: String,
  is_active: { type: Boolean, default: true },
  display_order: Number,
  badge_color: String,
}, { collection: 'offers', timestamps: true });

// ─── FAQ ────────────────────────────────────────────────────
export interface IFAQ extends Document {
  faq_id: string;
  question_ar: string;
  answer_ar: string;
  category_id: string;
  is_active: boolean;
  display_order: number;
}
const FAQSchema = new Schema<IFAQ>({
  faq_id: { type: String, required: true, unique: true },
  question_ar: String,
  answer_ar: String,
  category_id: String,
  is_active: { type: Boolean, default: true },
  display_order: Number,
}, { collection: 'faqs', timestamps: true });

// ─── ServiceArea ─────────────────────────────────────────────
export interface IServiceArea extends Document {
  area_id: string;
  name_ar: string;
  name_en: string;
  is_covered: boolean;
  display_order: number;
}
const ServiceAreaSchema = new Schema<IServiceArea>({
  area_id: { type: String, required: true, unique: true },
  name_ar: String,
  name_en: String,
  is_covered: { type: Boolean, default: true },
  display_order: Number,
}, { collection: 'service_areas', timestamps: true });

// ─── TimeSlot ────────────────────────────────────────────────
export interface ITimeSlot extends Document {
  slot_id: string;
  label_ar: string;
  start_time: string;
  end_time: string;
  is_active: boolean;
  display_order: number;
}
const TimeSlotSchema = new Schema<ITimeSlot>({
  slot_id: { type: String, required: true, unique: true },
  label_ar: String,
  start_time: String,
  end_time: String,
  is_active: { type: Boolean, default: true },
  display_order: Number,
}, { collection: 'time_slots', timestamps: true });

// ─── Booking ─────────────────────────────────────────────────
export interface IBooking extends Document {
  booking_id: string;
  user_id?: string;
  customer_name: string;
  customer_phone: string;
  customer_email?: string;
  service_id: string;
  area_id: string;
  address_detail: string;
  preferred_date: string;
  slot_id: string;
  quantity: number;
  notes: string;
  status_id: string;
  estimated_price_sar: number;
  rating?: number;
  review_text?: string;
  created_at: string;
}
const BookingSchema = new Schema<IBooking>({
  booking_id: { type: String, unique: true },
  user_id: String,
  customer_name: String,
  customer_phone: String,
  customer_email: String,
  service_id: String,
  area_id: String,
  address_detail: String,
  preferred_date: String,
  slot_id: String,
  quantity: { type: Number, default: 1 },
  notes: String,
  status_id: { type: String, default: 'STAT-01' },
  estimated_price_sar: Number,
  rating: Number,
  review_text: String,
  created_at: { type: String, default: () => new Date().toISOString() },
}, { collection: 'bookings', timestamps: true });

// ─── UserProfile ──────────────────────────────────────────────
export interface IUserProfile extends Document {
  user_id: string;
  full_name: string;
  email: string;
  phone: string;
  address: string;
  photo_url: string;
}
const UserProfileSchema = new Schema<IUserProfile>({
  user_id: { type: String, required: true, unique: true },
  full_name: String,
  email: String,
  phone: String,
  address: String,
  photo_url: String,
}, { collection: 'user_profiles', timestamps: true });

// ─── SiteSettings ────────────────────────────────────────────
export interface ISiteSetting extends Document {
  setting_key: string;
  setting_value: string;
  description: string;
}
const SiteSettingSchema = new Schema<ISiteSetting>({
  setting_key: { type: String, required: true, unique: true },
  setting_value: String,
  description: String,
}, { collection: 'site_settings', timestamps: true });

// ─── HeroBanner ──────────────────────────────────────────────
export interface IHeroBanner extends Document {
  banner_id: string;
  headline_ar: string;
  subheadline_ar: string;
  cta_primary_text_ar: string;
  cta_primary_url: string;
  cta_secondary_text_ar: string;
  cta_secondary_url: string;
  background_image_url: string;
  is_active: boolean;
  display_order: number;
}
const HeroBannerSchema = new Schema<IHeroBanner>({
  banner_id: { type: String, required: true, unique: true },
  headline_ar: String,
  subheadline_ar: String,
  cta_primary_text_ar: String,
  cta_primary_url: String,
  cta_secondary_text_ar: String,
  cta_secondary_url: String,
  background_image_url: String,
  is_active: { type: Boolean, default: true },
  display_order: Number,
}, { collection: 'hero_banners', timestamps: true });

// ─── ContactInformation ──────────────────────────────────────
export interface IContactInfo extends Document {
  field_key: string;
  field_value: string;
  label_ar: string;
}
const ContactInfoSchema = new Schema<IContactInfo>({
  field_key: { type: String, required: true, unique: true },
  field_value: String,
  label_ar: String,
}, { collection: 'contact_information', timestamps: true });

// ─── Model Helpers ───────────────────────────────────────────
function getModel<T extends Document>(name: string, schema: Schema): Model<T> {
  return mongoose.models[name] as Model<T> || mongoose.model<T>(name, schema);
}

export const Category = () => getModel<ICategory>('Category', CategorySchema);
export const Service = () => getModel<IService>('Service', ServiceSchema);
export const Testimonial = () => getModel<ITestimonial>('Testimonial', TestimonialSchema);
export const Offer = () => getModel<IOffer>('Offer', OfferSchema);
export const FAQ = () => getModel<IFAQ>('FAQ', FAQSchema);
export const ServiceArea = () => getModel<IServiceArea>('ServiceArea', ServiceAreaSchema);
export const TimeSlot = () => getModel<ITimeSlot>('TimeSlot', TimeSlotSchema);
export const Booking = () => getModel<IBooking>('Booking', BookingSchema);
export const UserProfile = () => getModel<IUserProfile>('UserProfile', UserProfileSchema);
export const SiteSetting = () => getModel<ISiteSetting>('SiteSetting', SiteSettingSchema);
export const HeroBanner = () => getModel<IHeroBanner>('HeroBanner', HeroBannerSchema);
export const ContactInfo = () => getModel<IContactInfo>('ContactInfo', ContactInfoSchema);
