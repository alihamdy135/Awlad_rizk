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
    this.rating,
    this.reviewText,
    required this.createdAt,
  });

  factory UserBookingModel.fromJson(Map<String, dynamic> json) {
    return UserBookingModel(
      id: json['_id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      serviceId: json['service_id'] ?? '',
      areaId: json['area_id'] ?? '',
      addressDetail: json['address_detail'] ?? '',
      preferredDate: json['preferred_date'] ?? '',
      slotId: json['slot_id'] ?? '',
      quantity: json['quantity'] ?? 1,
      notes: json['notes'] ?? '',
      statusId: json['status_id'] ?? 'STAT-01',
      estimatedPriceSar: (json['estimated_price_sar'] ?? 0).toDouble(),
      rating: json['rating'],
      reviewText: json['review_text'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
