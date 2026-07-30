import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'models.dart';

class ApiService {
  static const _headers = {'Content-Type': 'application/json'};

  static Future<List<ServiceModel>> getServices({bool featured = false, String? categoryId}) async {
    try {
      String url = '$kBaseUrl/api/services?';
      if (featured) url += 'featured=true&';
      if (categoryId != null && categoryId.isNotEmpty) url += 'category=$categoryId&';
      
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => ServiceModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    // Filter fallback data if API fails
    var results = _fallbackServices;
    if (featured) results = results.where((s) => s.isFeatured).toList();
    if (categoryId != null && categoryId.isNotEmpty) results = results.where((s) => s.categoryId == categoryId).toList();
    return results;
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

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/api/stats'), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (_) {}
    // Fallback if backend is unavailable (set to 0 to show "Pending")
    return {
      'total_satisfied_customers': 0,
      'average_rating': 0.0,
    };
  }

  static Future<List<FAQModel>> getFAQs({int? limit}) async {
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

  static Future<String> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/chat'),
        headers: _headers,
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (_) {}
    return 'عذراً، لم أتمكن من الاتصال بالخادم. يرجى المحاولة لاحقاً.';
  }

  // ─── Fallback Data ────────────────────────────────────────
  static final _fallbackServices = [
    ServiceModel(id:'1', serviceId:'SRV-001', categoryId:'CAT-01', nameAr:'تنظيف مكيف سبليت', shortDescriptionAr:'تنظيف شامل للوحدة الداخلية والخارجية بمواد متخصصة', basePriceSar:120, priceUnit:'للوحدة', warrantyDays:30, slug:'split-ac-cleaning', isFeatured:true),
    ServiceModel(id:'2', serviceId:'SRV-002', categoryId:'CAT-02', nameAr:'صيانة وإصلاح مكيفات', shortDescriptionAr:'تشخيص وإصلاح جميع أعطال المكيفات بضمان كامل', basePriceSar:200, priceUnit:'للزيارة', warrantyDays:30, slug:'ac-repair', isFeatured:true),
    ServiceModel(id:'3', serviceId:'SRV-003', categoryId:'CAT-03', nameAr:'تعبئة فريون', shortDescriptionAr:'إعادة شحن غاز الفريون لتحسين كفاءة التبريد', basePriceSar:150, priceUnit:'للوحدة', warrantyDays:30, slug:'freon-refill', isFeatured:true),
    ServiceModel(id:'4', serviceId:'SRV-004', categoryId:'CAT-04', nameAr:'لحام نحاس', shortDescriptionAr:'إصلاح التسربات بتقنية اللحام النحاسي الاحترافي', basePriceSar:250, priceUnit:'للتدخل', warrantyDays:30, slug:'copper-welding', isFeatured:false),
    ServiceModel(id:'5', serviceId:'SRV-005', categoryId:'CAT-05', nameAr:'عقد صيانة دورية', shortDescriptionAr:'عقود صيانة سنوية للحفاظ على كفاءة المكيفات', basePriceSar:1000, priceUnit:'سنوي', warrantyDays:30, slug:'annual-maintenance', isFeatured:false),
    ServiceModel(id:'6', serviceId:'SRV-006', categoryId:'CAT-01', nameAr:'تنظيف داكت سنترال', shortDescriptionAr:'تنظيف مجاري الهواء للمكيفات المركزية', basePriceSar:500, priceUnit:'للوحدة', warrantyDays:30, slug:'duct-cleaning', isFeatured:true),
  ];
  static final _fallbackCategories = [
    CategoryModel(id:'1', categoryId:'CAT-01', nameAr:'تنظيف', iconName:'🧹'),
    CategoryModel(id:'2', categoryId:'CAT-02', nameAr:'صيانة', iconName:'🔧'),
    CategoryModel(id:'3', categoryId:'CAT-03', nameAr:'تعبئة', iconName:'❄️'),
    CategoryModel(id:'4', categoryId:'CAT-04', nameAr:'لحام', iconName:'🔥'),
    CategoryModel(id:'5', categoryId:'CAT-05', nameAr:'عقود', iconName:'📋'),
  ];
  static final List<TestimonialModel> _fallbackTestimonials = [];
  static final _fallbackFAQs = [
    FAQModel(id:'1', questionAr:'متى يتم الدفع؟', answerAr:'الدفع بعد إتمام الخدمة بالكامل وتأكدك من جودة العمل.'),
    FAQModel(id:'2', questionAr:'ما هي مدة الضمان؟', answerAr:'ضمان 30 يوماً على الأقل لجميع خدماتنا.'),
    FAQModel(id:'3', questionAr:'كم وقت الاستجابة؟', answerAr:'نتواصل معكم خلال دقائق لتأكيد الموعد.'),
    FAQModel(id:'4', questionAr:'هل تخدمون جميع أحياء جدة؟', answerAr:'نخدم معظم أحياء جدة. يمكنك التحقق عند الحجز.'),
  ];
}
