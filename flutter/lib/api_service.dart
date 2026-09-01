import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'models.dart';
import 'models/user_profile.dart';
import 'services/auth_service.dart';

class ApiService {
  static const _headers = {'Content-Type': 'application/json'};

  static Future<Map<String, String>> _authHeaders() async {
    final Map<String, String> h = {'Content-Type': 'application/json'};
    final idToken = await AuthService.getIdToken();
    if (idToken != null) h['Authorization'] = 'Bearer ' + idToken;
    return h;
  }

  static Future<List<ServiceModel>> getServices({bool featured = false, String? categoryId}) async {
    try {
      String url = kBaseUrl + '/api/services?nocache=' + DateTime.now().millisecondsSinceEpoch.toString() + '&';
      if (featured) url += 'featured=true&';
      if (categoryId != null && categoryId.isNotEmpty) url += 'category=' + categoryId + '&';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final list = (data['data'] as List).map((e) => ServiceModel.fromJson(e)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}
    var results = List<ServiceModel>.from(_fallbackServices);
    if (featured) results = results.where((s) => s.isFeatured).toList();
    if (categoryId != null && categoryId.isNotEmpty) results = results.where((s) => s.categoryId == categoryId).toList();
    return results;
  }

  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(kBaseUrl + '/api/categories?nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final list = (data['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}
    return _fallbackCategories;
  }

  static Future<List<TestimonialModel>> getTestimonials() async {
    try {
      final response = await http.get(Uri.parse(kBaseUrl + '/api/testimonials?nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).map((e) => TestimonialModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse(kBaseUrl + '/api/stats?nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (_) {}
    return {'total_satisfied_customers': 0, 'average_rating': 0.0};
  }

  static Future<List<FAQModel>> getFAQs({int? limit}) async {
    try {
      final response = await http.get(Uri.parse(kBaseUrl + '/api/faq?limit=' + (limit?.toString() ?? '') + '&nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).map((e) => FAQModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return _fallbackFAQs;
  }

  static Future<String> sendChatMessage(String message) async {
    try {
      final response = await http.post(Uri.parse(kBaseUrl + '/api/chat'), headers: _headers, body: jsonEncode({'message': message})).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (_) {}
    return 'عذراً، لم أتمكن من الاتصال بالخادم. يرجى المحاولة لاحقاً.';
  }

  static Future<List<String>> getBookedSlotsForDate(String date) async {
    try {
      final response = await http.get(Uri.parse(kBaseUrl + '/api/bookings/slots?date=' + date + '&nocache=' + DateTime.now().millisecondsSinceEpoch.toString())).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) return List<String>.from(data['data']);
      }
    } catch (_) {}
    return [];
  }

  static Future<List<String>> getAdminAvailability(String date) async {
    // Returns union (customer + admin) for display, but internally we keep separation
    final detail = await getAdminAvailabilityDetail(date);
    return detail['all'] ?? [];
  }

  static Future<Map<String, List<String>>> getAdminAvailabilityDetail(String date) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(Uri.parse(kBaseUrl + '/api/admin/availability?date=' + date + '&nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'all': data['data'] != null ? List<String>.from(data['data']) : <String>[],
            'customer': data['customer_slots'] != null ? List<String>.from(data['customer_slots']) : <String>[],
            'admin': data['admin_slots'] != null ? List<String>.from(data['admin_slots']) : <String>[],
          };
        }
      }
    } catch (_) {}
    return {'all': [], 'customer': [], 'admin': []};
  }

  static Future<bool> setAdminAvailability(String date, List<String> blockedSlots) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(Uri.parse(kBaseUrl + '/api/admin/availability'), headers: headers, body: jsonEncode({'date': date, 'blocked_slots': blockedSlots})).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<UserProfileModel?> getUserProfile() async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return null;
      final response = await http.get(Uri.parse(kBaseUrl + '/api/user/profile?nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) return UserProfileModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateUserProfile(UserProfileModel profile) async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return false;
      final response = await http.put(Uri.parse(kBaseUrl + '/api/user/profile'), headers: headers, body: jsonEncode(profile.toJson())).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<List<UserBookingModel>> getUserBookings() async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return [];
      final response = await http.get(Uri.parse(kBaseUrl + '/api/user/bookings?nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: headers).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).map((e) => UserBookingModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> rateBooking(String bookingId, int rating, String reviewText) async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return false;
      final response = await http.post(Uri.parse(kBaseUrl + '/api/user/bookings'), headers: headers, body: jsonEncode({'booking_id': bookingId, 'rating': rating, 'review_text': reviewText})).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static const List<String> kAdminEmails = [
    'naseem01099@gmail.com',
    'alihmdy135135@gmail.com',
    'alihamdy135@gmail.com',
  ];

  static bool isAdmin() {
    final user = AuthService.currentUser;
    if (user == null || user.email == null) return false;
    return kAdminEmails.contains(user.email!.toLowerCase().trim());
  }

  static Future<List<UserBookingModel>> getAllBookingsAdmin() async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return [];
      final response = await http.get(Uri.parse(kBaseUrl + '/api/admin/bookings?nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: headers).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final list = (data['data'] as List).map((e) => UserBookingModel.fromJson(e)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getAdminStats() async {
    final allBookings = await getAllBookingsAdmin();
    double totalRevenue = 0;
    int pendingCount = 0, inProgressCount = 0, completedCount = 0, cancelledCount = 0;
    for (final b in allBookings) {
      totalRevenue += b.totalAmountSar;
      final st = b.statusCode.toUpperCase();
      if (st == 'STAT-01') pendingCount++;
      else if (st == 'STAT-02') inProgressCount++;
      else if (st == 'STAT-03') completedCount++;
      else if (st == 'STAT-04') cancelledCount++;
      else pendingCount++;
    }
    int totalServices = 6;
    try {
      final headers = await _authHeaders();
      if (headers.containsKey('Authorization')) {
        final resp = await http.get(Uri.parse(kBaseUrl + '/api/admin/stats?nocache=' + DateTime.now().millisecondsSinceEpoch.toString()), headers: headers).timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200) {
          final d = jsonDecode(resp.body);
          if (d['success'] == true) totalServices = d['data']['total_services'] ?? totalServices;
        }
      }
    } catch (_) {}
    return {'total_bookings': allBookings.length, 'total_revenue_sar': totalRevenue, 'pending_count': pendingCount, 'in_progress_count': inProgressCount, 'completed_count': completedCount, 'cancelled_count': cancelledCount, 'total_services': totalServices, 'total_users': 1};
  }

  static Future<bool> updateBookingStatusAdmin(String bookingId, String statusCode, {double? finalPriceSar}) async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return false;
      final Map<String, dynamic> body = {'booking_id': bookingId, 'status_code': statusCode};
      if (finalPriceSar != null) body['final_price_sar'] = finalPriceSar;
      final response = await http.put(Uri.parse(kBaseUrl + '/api/admin/bookings'), headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>?> getAdminAnalytics({int? year, int? month}) async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return null;
      String url = kBaseUrl + '/api/admin/analytics?nocache=' + DateTime.now().millisecondsSinceEpoch.toString();
      if (year != null) url += '&year=$year';
      if (month != null) url += '&month=$month';
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) return data['data'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> createServiceAdmin(Map<String, dynamic> serviceData) async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return false;
      final response = await http.post(Uri.parse(kBaseUrl + '/api/admin/services'), headers: headers, body: jsonEncode(serviceData)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> updateServiceAdmin(Map<String, dynamic> serviceData) async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return false;
      final response = await http.put(Uri.parse(kBaseUrl + '/api/admin/services'), headers: headers, body: jsonEncode(serviceData)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> deleteServiceAdmin(String serviceId) async {
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) return false;
      final response = await http.delete(Uri.parse(kBaseUrl + '/api/admin/services?service_id=' + serviceId), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static void addLocalBooking(UserBookingModel booking) {}
  static List<UserBookingModel> getLocalBookings() => [];

  static final _fallbackServices = [
    ServiceModel(id:'1', serviceId:'SRV-001', categoryId:'CAT-01', nameAr:'تنظيف مكيف سبليت', shortDescriptionAr:'تنظيف شامل للوحدة الداخلية والخارجية بمواد متخصصة', basePriceSar:120, priceUnit:'للوحدة', warrantyDays:30, slug:'split-ac-cleaning', isFeatured:true, pricingType:'fixed', isPriceOnVisit:false),
    ServiceModel(id:'2', serviceId:'SRV-002', categoryId:'CAT-02', nameAr:'صيانة وإصلاح مكيفات', shortDescriptionAr:'تشخيص وإصلاح جميع أعطال المكيفات بضمان كامل', basePriceSar:200, priceUnit:'للزيارة', warrantyDays:30, slug:'ac-repair', isFeatured:true, pricingType:'fixed', isPriceOnVisit:false),
    ServiceModel(id:'3', serviceId:'SRV-003', categoryId:'CAT-03', nameAr:'تعبئة فريون', shortDescriptionAr:'إعادة شحن غاز الفريون لتحسين كفاءة التبريد', basePriceSar:150, priceUnit:'للوحدة', warrantyDays:30, slug:'freon-refill', isFeatured:true, pricingType:'fixed', isPriceOnVisit:false),
    ServiceModel(id:'4', serviceId:'SRV-004', categoryId:'CAT-04', nameAr:'لحام نحاس', shortDescriptionAr:'إصلاح التسربات بتقنية اللحام النحاسي الاحترافي', basePriceSar:250, priceUnit:'للتدخل', warrantyDays:30, slug:'copper-welding', isFeatured:false, pricingType:'on_visit', isPriceOnVisit:true),
    ServiceModel(id:'5', serviceId:'SRV-005', categoryId:'CAT-05', nameAr:'عقد صيانة دورية', shortDescriptionAr:'عقود صيانة سنوية للحفاظ على كفاءة المكيفات', basePriceSar:1000, priceUnit:'سنوي', warrantyDays:30, slug:'annual-maintenance', isFeatured:false, pricingType:'fixed', isPriceOnVisit:false),
    ServiceModel(id:'6', serviceId:'SRV-006', categoryId:'CAT-01', nameAr:'تنظيف داكت سنترال', shortDescriptionAr:'تنظيف مجاري الهواء للمكيفات المركزية', basePriceSar:500, priceUnit:'للوحدة', warrantyDays:30, slug:'duct-cleaning', isFeatured:true, pricingType:'fixed', isPriceOnVisit:false),
  ];
  static final _fallbackCategories = [
    CategoryModel(id:'1', categoryId:'CAT-01', nameAr:'تنظيف', iconName:'🧹'),
    CategoryModel(id:'2', categoryId:'CAT-02', nameAr:'صيانة', iconName:'🔧'),
    CategoryModel(id:'3', categoryId:'CAT-03', nameAr:'تعبئة', iconName:'❄️'),
    CategoryModel(id:'4', categoryId:'CAT-04', nameAr:'لحام', iconName:'🔥'),
    CategoryModel(id:'5', categoryId:'CAT-05', nameAr:'عقود', iconName:'📋'),
  ];
  static final _fallbackFAQs = [
    FAQModel(id:'1', questionAr:'متى يتم الدفع؟', answerAr:'الدفع بعد إتمام الخدمة بالكامل وتأكدك من جودة العمل.'),
    FAQModel(id:'2', questionAr:'ما هي مدة الضمان؟', answerAr:'ضمان 30 يوماً على الأقل لجميع خدماتنا.'),
    FAQModel(id:'3', questionAr:'كم وقت الاستجابة؟', answerAr:'نتواصل معكم خلال دقائق لتأكيد الموعد.'),
    FAQModel(id:'4', questionAr:'هل تخدمون جميع أحياء جدة؟', answerAr:'نخدم معظم أحياء جدة. يمكنك التحقق عند الحجز.'),
  ];
}
