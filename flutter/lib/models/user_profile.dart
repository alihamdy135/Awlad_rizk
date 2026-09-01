class UserProfileModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String photoUrl;

  UserProfileModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.photoUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      photoUrl: json['photo_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'photo_url': photoUrl,
    };
  }
}

class UserBookingModel {
  final String id;
  final String bookingId;
  final String customerName;
  final String customerPhone;
  final String serviceId;
  final String areaId;
  final String addressDetail;
  final String preferredDate;
  final String slotId;
  final int quantity;
  final String notes;
  final String statusId;
  final double estimatedPriceSar;
  final double? finalPriceSar;
  final String pricingType; // 'fixed' | 'on_visit'
  final bool isPriceOnVisit;
  final int? rating;
  final String? reviewText;
  final String createdAt;

  UserBookingModel({
    required this.id,
    required this.bookingId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceId,
    required this.areaId,
    required this.addressDetail,
    required this.preferredDate,
    required this.slotId,
    required this.quantity,
    required this.notes,
    required this.statusId,
    required this.estimatedPriceSar,
    this.finalPriceSar,
    this.pricingType = 'fixed',
    this.isPriceOnVisit = false,
    this.rating,
    this.reviewText,
    required this.createdAt,
  });

  String get statusCode => statusId;
  double get totalAmountSar => finalPriceSar != null && finalPriceSar! > 0 ? finalPriceSar! : estimatedPriceSar;
  bool get isOnVisitPricing => isPriceOnVisit || pricingType == 'on_visit';
  List<String> get serviceNames => [serviceId.isNotEmpty ? serviceId : 'خدمات تكييف وتبريد'];

  factory UserBookingModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['pricing_type'] ?? (json['is_price_on_visit'] == true ? 'on_visit' : 'fixed')).toString();
    final isOnVisit = rawType == 'on_visit' || json['is_price_on_visit'] == true;
    double? finalP;
    if (json['final_price_sar'] != null) {
      finalP = (json['final_price_sar'] as num).toDouble();
      if (finalP == 0) finalP = null;
    }
    return UserBookingModel(
      id: json['_id'] != null ? json['_id'].toString() : (json['booking_id']?.toString() ?? ''),
      bookingId: json['booking_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      areaId: json['area_id']?.toString() ?? '',
      addressDetail: json['address_detail']?.toString() ?? '',
      preferredDate: json['preferred_date']?.toString() ?? '',
      slotId: json['slot_id']?.toString() ?? '',
      quantity: json['quantity'] != null ? (json['quantity'] as num).toInt() : 1,
      notes: json['notes']?.toString() ?? '',
      statusId: json['status_id']?.toString() ?? json['status_code']?.toString() ?? json['status']?.toString() ?? 'STAT-01',
      estimatedPriceSar: json['estimated_price_sar'] != null
          ? (json['estimated_price_sar'] as num).toDouble()
          : (json['total_amount_sar'] != null
              ? (json['total_amount_sar'] as num).toDouble()
              : (json['total_price_sar'] != null ? (json['total_price_sar'] as num).toDouble() : 0.0)),
      finalPriceSar: finalP,
      pricingType: isOnVisit ? 'on_visit' : 'fixed',
      isPriceOnVisit: isOnVisit,
      rating: json['rating'] != null ? (json['rating'] as num).toInt() : null,
      reviewText: json['review_text']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }
}
