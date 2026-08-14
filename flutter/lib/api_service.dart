import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'models.dart';
import 'models/user_profile.dart';
import 'services/auth_service.dart';

class ApiService {
  static const _headers = {'Content-Type': 'application/json'};

  static final List<ServiceModel> _localServices = List.from(_fallbackServices);

  static Future<List<ServiceModel>> getServices({bool featured = false, String? categoryId}) async {
    try {
      String url = '$kBaseUrl/api/services?';
      if (featured) url += 'featured=true&';
      if (categoryId != null && categoryId.isNotEmpty) url += 'category=$categoryId&';
      
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null && (data['data'] as List).isNotEmpty) {
          final remote = (data['data'] as List).map((e) => ServiceModel.fromJson(e)).toList();
          for (final r in remote) {
            final idx = _localServices.indexWhere((s) => s.serviceId == r.serviceId);
            if (idx != -1) {
              _localServices[idx] = r;
            } else {
              _localServices.add(r);
            }
          }
        }
      }
    } catch (_) {}

    var results = List<ServiceModel>.from(_localServices);
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

  // ─── User Profile & Dashboard APIs ───────────────────────────
  static Future<UserProfileModel?> getUserProfile() async {
    try {
      String? idToken = await AuthService.getIdToken();
      if (idToken == null) return null;
      final response = await http.get(
        Uri.parse('$kBaseUrl/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UserProfileModel.fromJson(data['data']);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateUserProfile(UserProfileModel profile) async {
    try {
      String? idToken = await AuthService.getIdToken();
      if (idToken == null) return false;
      final response = await http.put(
        Uri.parse('$kBaseUrl/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(profile.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<List<UserBookingModel>> getUserBookings() async {
    try {
      String? idToken = await AuthService.getIdToken();
      if (idToken == null) return [];
      final response = await http.get(
        Uri.parse('$kBaseUrl/api/user/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      ).timeout(const Duration(seconds: 10));

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
      String? idToken = await AuthService.getIdToken();
      if (idToken == null) return false;
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/user/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'rating': rating,
          'review_text': reviewText,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ─── Admin APIs ──────────────────────────────────────────
  static const List<String> kAdminEmails = [
    'naseem01099@gmail.com',
  ];

  static bool isAdmin() {
    final user = AuthService.currentUser;
    if (user == null || user.email == null) return false;
    return kAdminEmails.contains(user.email!.toLowerCase().trim());
  }

  // ─── Local persistence store for instant real-time admin sync ─
  static final List<UserBookingModel> _localBookings = [];

  static void addLocalBooking(UserBookingModel booking) {
    // Avoid duplicate bookingId
    _localBookings.removeWhere((b) => b.bookingId == booking.bookingId);
    _localBookings.insert(0, booking);
  }

  static List<UserBookingModel> getLocalBookings() => List.unmodifiable(_localBookings);

  static Future<Map<String, dynamic>?> getAdminStats() async {
    Map<String, dynamic>? remoteStats;
    try {
      String? idToken = await AuthService.getIdToken();
      if (idToken != null) {
        final response = await http.get(
          Uri.parse('$kBaseUrl/api/admin/stats'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            remoteStats = data['data'];
          }
        }
      }
    } catch (_) {}

    final allBookings = await getAllBookingsAdmin();
    double totalRevenue = 0;
    int pendingCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;

    for (final b in allBookings) {
      totalRevenue += b.totalAmountSar;
      final st = b.statusCode.toUpperCase();
      if (st == 'STAT-01' || st.contains('PENDING') || st.contains('انتظار')) {
        pendingCount++;
      } else if (st == 'STAT-02' || st.contains('PROGRESS') || st.contains('عمل')) {
        inProgressCount++;
      } else if (st == 'STAT-03' || st.contains('COMPLETED') || st.contains('مكتمل')) {
        completedCount++;
      } else if (st == 'STAT-04' || st.contains('CANCEL') || st.contains('ملغي')) {
        cancelledCount++;
      } else {
        pendingCount++;
      }
    }

    return {
      'total_bookings': allBookings.length,
      'total_revenue_sar': totalRevenue,
      'pending_count': pendingCount,
      'in_progress_count': inProgressCount,
      'completed_count': completedCount,
      'cancelled_count': cancelledCount,
      'total_services': remoteStats?['total_services'] ?? _fallbackServices.length,
      'total_users': remoteStats?['total_users'] ?? 1,
    };
  }

  static Future<List<UserBookingModel>> getAllBookingsAdmin() async {
    List<UserBookingModel> remote = [];
    try {
      String? idToken = await AuthService.getIdToken();
      if (idToken != null) {
        final response = await http.get(
          Uri.parse('$kBaseUrl/api/admin/bookings'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] != null) {
            remote = (data['data'] as List).map((e) => UserBookingModel.fromJson(e)).toList();
          }
        }
      }
    } catch (_) {}

    final Map<String, UserBookingModel> merged = {};
    for (final b in _localBookings) {
      merged[b.bookingId] = b;
    }
    for (final b in remote) {
      merged[b.bookingId] = b;
    }
    final result = merged.values.toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  static Future<bool> updateBookingStatusAdmin(String bookingId, String statusCode) async {
    try {
      String? idToken = await AuthService.getIdToken();
      if (idToken == null) return false;
      final response = await http.put(
        Uri.parse('$kBaseUrl/api/admin/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'status_code': statusCode,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> createServiceAdmin(Map<String, dynamic> serviceData) async {
    final newId = serviceData['service_id'] ?? 'SRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newService = ServiceModel(
      id: newId,
      serviceId: newId,
      categoryId: serviceData['category_id'] ?? 'CAT-01',
      nameAr: serviceData['name_ar'] ?? serviceData['name'] ?? 'خدمة جديدة',
      shortDescriptionAr: serviceData['short_description_ar'] ?? serviceData['name_ar'] ?? '',
      basePriceSar: (serviceData['base_price_sar'] ?? serviceData['price'] ?? 100).toDouble(),
      priceUnit: serviceData['price_unit'] ?? 'للوحدة',
      warrantyDays: serviceData['warranty_days'] ?? 30,
      slug: serviceData['slug'] ?? newId.toLowerCase(),
      isFeatured: serviceData['is_featured'] ?? false,
    );

    _localServices.insert(0, newService);

    try {
      String? idToken = await AuthService.getIdToken();
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (idToken != null) headers['Authorization'] = 'Bearer $idToken';
      await http.post(
        Uri.parse('$kBaseUrl/api/admin/services'),
        headers: headers,
        body: jsonEncode(serviceData),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}

    return true;
  }

  static Future<bool> updateServiceAdmin(Map<String, dynamic> serviceData) async {
    final serviceId = serviceData['service_id'];
    if (serviceId != null) {
      final index = _localServices.indexWhere((s) => s.serviceId == serviceId || s.id == serviceId);
      if (index != -1) {
        final old = _localServices[index];
        _localServices[index] = ServiceModel(
          id: old.id,
          serviceId: old.serviceId,
          categoryId: serviceData['category_id'] ?? old.categoryId,
          nameAr: serviceData['name_ar'] ?? old.nameAr,
          shortDescriptionAr: serviceData['short_description_ar'] ?? old.shortDescriptionAr,
          basePriceSar: (serviceData['base_price_sar'] ?? old.basePriceSar).toDouble(),
          priceUnit: serviceData['price_unit'] ?? old.priceUnit,
          warrantyDays: serviceData['warranty_days'] ?? old.warrantyDays,
          slug: old.slug,
          isFeatured: serviceData['is_featured'] ?? old.isFeatured,
        );
      }
    }

    try {
      String? idToken = await AuthService.getIdToken();
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (idToken != null) headers['Authorization'] = 'Bearer $idToken';
      await http.put(
        Uri.parse('$kBaseUrl/api/admin/services'),
        headers: headers,
        body: jsonEncode(serviceData),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}

    return true;
  }

  static Future<bool> deleteServiceAdmin(String serviceId) async {
    _localServices.removeWhere((s) => s.serviceId == serviceId || s.id == serviceId);

    try {
      String? idToken = await AuthService.getIdToken();
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (idToken != null) headers['Authorization'] = 'Bearer $idToken';
      await http.delete(
        Uri.parse('$kBaseUrl/api/admin/services?service_id=$serviceId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}

    return true;
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
