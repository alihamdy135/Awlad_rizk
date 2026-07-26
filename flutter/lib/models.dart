class ServiceModel {
  final String id;
  final String serviceId;
  final String nameAr;
  final String shortDescriptionAr;
  final double basePriceSar;
  final String priceUnit;
  final int warrantyDays;
  final String? imageUrl;
  final String slug;
  final bool isFeatured;

  ServiceModel({
    required this.id,
    required this.serviceId,
    required this.nameAr,
    required this.shortDescriptionAr,
    required this.basePriceSar,
    required this.priceUnit,
    required this.warrantyDays,
    this.imageUrl,
    required this.slug,
    required this.isFeatured,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? '',
      serviceId: json['service_id'] ?? '',
      nameAr: json['name_ar'] ?? '',
      shortDescriptionAr: json['short_description_ar'] ?? '',
      basePriceSar: (json['base_price_sar'] ?? 0).toDouble(),
      priceUnit: json['price_unit'] ?? '',
      warrantyDays: json['warranty_days'] ?? 0,
      imageUrl: json['image_url'],
      slug: json['slug'] ?? '',
      isFeatured: json['is_featured'] ?? false,
    );
  }
}

class CategoryModel {
  final String id;
  final String categoryId;
  final String nameAr;
  final String iconName;

  CategoryModel({required this.id, required this.categoryId, required this.nameAr, required this.iconName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      nameAr: json['name_ar'] ?? '',
      iconName: json['icon_name'] ?? '❄️',
    );
  }
}

class TestimonialModel {
  final String id;
  final String customerName;
  final String district;
  final int rating;
  final String reviewTextAr;
  final String serviceNameAr;

  TestimonialModel({required this.id, required this.customerName, required this.district, required this.rating, required this.reviewTextAr, required this.serviceNameAr});

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: json['_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      district: json['district'] ?? '',
      rating: json['rating'] ?? 5,
      reviewTextAr: json['review_text_ar'] ?? '',
      serviceNameAr: json['service_name_ar'] ?? '',
    );
  }
}

class FAQModel {
  final String id;
  final String questionAr;
  final String answerAr;

  FAQModel({required this.id, required this.questionAr, required this.answerAr});

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['_id'] ?? '',
      questionAr: json['question_ar'] ?? '',
      answerAr: json['answer_ar'] ?? '',
    );
  }
}
