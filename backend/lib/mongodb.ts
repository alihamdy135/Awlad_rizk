import mongoose from 'mongoose';
import { Service, Category, FAQ } from '../models';

const DEFAULT_MONGODB_URI = 'mongodb+srv://allure_admin:AliHatabME_3625@cluster0.86pho5i.mongodb.net/?appName=Cluster0';
const MONGODB_URI = process.env.MONGODB_URI || DEFAULT_MONGODB_URI;
const MONGODB_DB = process.env.MONGODB_DB || 'awladrizk';

interface MongooseCache {
  conn: typeof mongoose | null;
  promise: Promise<typeof mongoose> | null;
}

declare global {
  // eslint-disable-next-line no-var
  var mongooseCache: MongooseCache;
}

let cached: MongooseCache = global.mongooseCache || { conn: null, promise: null };

if (!global.mongooseCache) {
  global.mongooseCache = cached;
}

export async function connectToDatabase() {
  if (cached.conn) {
    return cached.conn;
  }

  if (!cached.promise) {
    const opts = {
      dbName: MONGODB_DB,
      bufferCommands: false,
    };

    cached.promise = mongoose.connect(MONGODB_URI, opts);
  }

  try {
    cached.conn = await cached.promise;
    await seedInitialData();
  } catch (e) {
    cached.promise = null;
    throw e;
  }

  return cached.conn;
}

async function seedInitialData() {
  try {
    const ServiceModel = Service();
    const serviceCount = await ServiceModel.countDocuments();
    if (serviceCount === 0) {
      console.log('Seeding initial services into MongoDB...');
      await ServiceModel.insertMany([
        { service_id: 'SRV-001', category_id: 'CAT-01', name_ar: 'تنظيف مكيف سبليت', short_description_ar: 'تنظيف شامل للوحدة الداخلية والخارجية بمواد متخصصة', base_price_sar: 120, price_unit: 'للوحدة', warranty_days: 30, slug: 'split-ac-cleaning', is_active: true, is_featured: true, display_order: 1 },
        { service_id: 'SRV-002', category_id: 'CAT-02', name_ar: 'صيانة وإصلاح مكيفات', short_description_ar: 'تشخيص وإصلاح جميع أعطال المكيفات بضمان كامل', base_price_sar: 200, price_unit: 'للزيارة', warranty_days: 30, slug: 'ac-repair', is_active: true, is_featured: true, display_order: 2 },
        { service_id: 'SRV-003', category_id: 'CAT-03', name_ar: 'تعبئة فريون', short_description_ar: 'إعادة شحن غاز الفريون لتحسين كفاءة التبريد', base_price_sar: 150, price_unit: 'للوحدة', warranty_days: 30, slug: 'freon-refill', is_active: true, is_featured: true, display_order: 3 },
        { service_id: 'SRV-004', category_id: 'CAT-04', name_ar: 'لحام نحاس', short_description_ar: 'إصلاح التسربات بتقنية اللحام النحاسي الاحترافي', base_price_sar: 250, price_unit: 'للتدخل', warranty_days: 30, slug: 'copper-welding', is_active: true, is_featured: false, display_order: 4 },
        { service_id: 'SRV-005', category_id: 'CAT-05', name_ar: 'عقد صيانة دورية', short_description_ar: 'عقود صيانة سنوية للحفاظ على كفاءة المكيفات', base_price_sar: 1000, price_unit: 'سنوي', warranty_days: 30, slug: 'annual-maintenance', is_active: true, is_featured: false, display_order: 5 },
        { service_id: 'SRV-006', category_id: 'CAT-01', name_ar: 'تنظيف داكت سنترال', short_description_ar: 'تنظيف مجاري الهواء للمكيفات المركزية', base_price_sar: 500, price_unit: 'للوحدة', warranty_days: 30, slug: 'duct-cleaning', is_active: true, is_featured: true, display_order: 6 },
      ]);
    }

    const CategoryModel = Category();
    const categoryCount = await CategoryModel.countDocuments();
    if (categoryCount === 0) {
      await CategoryModel.insertMany([
        { category_id: 'CAT-01', name_ar: 'تنظيف', name_en: 'Cleaning', icon_name: '🧹', display_order: 1, is_active: true },
        { category_id: 'CAT-02', name_ar: 'صيانة', name_en: 'Maintenance', icon_name: '🔧', display_order: 2, is_active: true },
        { category_id: 'CAT-03', name_ar: 'تعبئة', name_en: 'Freon', icon_name: '❄️', display_order: 3, is_active: true },
        { category_id: 'CAT-04', name_ar: 'لحام', name_en: 'Welding', icon_name: '🔥', display_order: 4, is_active: true },
        { category_id: 'CAT-05', name_ar: 'عقود', name_en: 'Contracts', icon_name: '📋', display_order: 5, is_active: true },
      ]);
    }

    const FAQModel = FAQ();
    const faqCount = await FAQModel.countDocuments();
    if (faqCount === 0) {
      await FAQModel.insertMany([
        { faq_id: 'FAQ-001', question_ar: 'متى يتم الدفع؟', answer_ar: 'الدفع بعد إتمام الخدمة بالكامل وتأكدك من جودة العمل.', is_active: true, display_order: 1 },
        { faq_id: 'FAQ-002', question_ar: 'ما هي مدة الضمان؟', answer_ar: 'ضمان 30 يوماً على الأقل لجميع خدماتنا.', is_active: true, display_order: 2 },
        { faq_id: 'FAQ-003', question_ar: 'كم وقت الاستجابة؟', answer_ar: 'نتواصل معكم خلال دقائق لتأكيد الموعد.', is_active: true, display_order: 3 },
        { faq_id: 'FAQ-004', question_ar: 'هل تخدمون جميع أحياء جدة؟', answer_ar: 'نخدم جميع أحياء ومناطق جدة.', is_active: true, display_order: 4 },
      ]);
    }
  } catch (err) {
    console.error('Seed Initial Data Error:', err);
  }
}
