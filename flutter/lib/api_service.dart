import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'models.dart';

class ApiService {
  static const _headers = {'Content-Type': 'application/json'};

  static Future<List<ServiceModel>> getServices({bool featured = false}) async {
    try {
      final url = '$kBaseUrl/api/services${featured ? '?featured=true' : ''}';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => ServiceModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return _fallbackServices;
  }

  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/api/categories'), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return _fallbackCategories;
  }

  static Future<List<TestimonialModel>> getTestimonials() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/api/testimonials'), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => TestimonialModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return _fallbackTestimonials;
  }

  static Future<List<FAQModel>> getFAQs({int limit = 4}) async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/api/faq?limit=$limit'), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => FAQModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return _fallbackFAQs;
  }

  // ─── Fallback Data ────────────────────────────────────────
  static final _fallbackServices = [
    ServiceModel(id:'1', serviceId:'SRV-001', nameAr:'تنظيف مكيف سبليت', shortDescriptionAr:'تنظيف شامل للوحدة الداخلية والخارجية بمواد متخصصة', basePriceSar:120, priceUnit:'للوحدة', warrantyDays:30, slug:'split-ac-cleaning', isFeatured:true),
    ServiceModel(id:'2', serviceId:'SRV-002', nameAr:'صيانة وإصلاح مكيفات', shortDescriptionAr:'تشخيص وإصلاح جميع أعطال المكيفات بضمان كامل', basePriceSar:200, priceUnit:'للزيارة', warrantyDays:30, slug:'ac-repair', isFeatured:true),
    ServiceModel(id:'3', serviceId:'SRV-003', nameAr:'تعبئة فريون', shortDescriptionAr:'إعادة شحن غاز الفريون لتحسين كفاءة التبريد', basePriceSar:150, priceUnit:'للوحدة', warrantyDays:15, slug:'freon-refill', isFeatured:true),
    ServiceModel(id:'4', serviceId:'SRV-004', nameAr:'لحام نحاس', shortDescriptionAr:'إصلاح التسربات بتقنية اللحام النحاسي الاحترافي', basePriceSar:250, priceUnit:'للتدخل', warrantyDays:30, slug:'copper-welding', isFeatured:false),
  ];
  static final _fallbackCategories = [
    CategoryModel(id:'1', categoryId:'CAT-01', nameAr:'تنظيف', iconName:'🧹'),
    CategoryModel(id:'2', categoryId:'CAT-02', nameAr:'صيانة', iconName:'🔧'),
    CategoryModel(id:'3', categoryId:'CAT-03', nameAr:'فريون', iconName:'❄️'),
    CategoryModel(id:'4', categoryId:'CAT-04', nameAr:'لحام', iconName:'🔥'),
    CategoryModel(id:'5', categoryId:'CAT-05', nameAr:'عقود', iconName:'📋'),
  ];
  static final _fallbackTestimonials = [
    TestimonialModel(id:'1', customerName:'محمد العمري', district:'حي الروضة', rating:5, reviewTextAr:'خدمة ممتازة وفنيون محترفون. أنصح الجميع بهم.', serviceNameAr:'تنظيف مكيف سبليت'),
    TestimonialModel(id:'2', customerName:'سارة القحطاني', district:'حي النزهة', rating:5, reviewTextAr:'جاؤوا في نفس اليوم وأصلحوا العطل بسرعة. شكراً!', serviceNameAr:'صيانة وإصلاح مكيفات'),
    TestimonialModel(id:'3', customerName:'عبدالله الغامدي', district:'حي الصفا', rating:5, reviewTextAr:'الدفع بعد الخدمة أعطاني راحة بال كبيرة.', serviceNameAr:'تعبئة فريون'),
  ];
  static final _fallbackFAQs = [
    FAQModel(id:'1', questionAr:'متى يتم الدفع؟', answerAr:'الدفع بعد إتمام الخدمة بالكامل وتأكدك من جودة العمل.'),
    FAQModel(id:'2', questionAr:'ما هي مدة الضمان؟', answerAr:'ضمان 30 يوماً على الأقل لجميع خدماتنا.'),
    FAQModel(id:'3', questionAr:'كم وقت الاستجابة؟', answerAr:'نتواصل معكم خلال دقائق لتأكيد الموعد.'),
    FAQModel(id:'4', questionAr:'هل تخدمون جميع أحياء جدة؟', answerAr:'نخدم معظم أحياء جدة. يمكنك التحقق عند الحجز.'),
  ];
}
