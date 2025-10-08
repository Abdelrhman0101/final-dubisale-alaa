class MyAdModel {
  final int id;
  final String title;
  final String? planType;
  final String mainImageUrl;
  final String price;
  final String status;
  final String category;
  final String createdAt;
  // إضافة حقول Make, Model, Trim للسيارات
  final String? make;
  final String? model;
  final String? trim;
  final String? year;
  // إضافة حقول المطاعم وخدمات السيارات
  final String? description;
  final String? emirate;
  final String? district;
  final String? area;
  final String? priceRange;
  final String? serviceType;
  final String? serviceName;
  final String categorySlug;
  MyAdModel({
    required this.id,
    required this.title,
    this.planType,
    required this.mainImageUrl,
    required this.price,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.categorySlug,
    this.make,
    this.model,
    this.trim,
    this.year,
    this.description,
    this.emirate,
    this.district,
    this.area,
    this.priceRange,
    this.serviceType,
    this.serviceName,
  });

  factory MyAdModel.fromJson(Map<String, dynamic> json) {
    return MyAdModel(
      id: json['id'],
      title: json['title'],
      planType: json['plan_type'],
      mainImageUrl: json['main_image_url'],
      price: json['price'],
      status: json['status'],
      category: json['category'],
      createdAt: json['created_at'],
      make: json['make']?.toString(),
      model: json['model']?.toString(),
      trim: json['trim']?.toString(),
      year: json['year']?.toString(),
      description: json['description']?.toString(),
      emirate: json['emirate']?.toString(),
      district: json['district']?.toString(),
      area: json['area']?.toString(),
      priceRange: json['price_range']?.toString(),
      serviceType: json['service_type']?.toString(),
      serviceName: json['service_name']?.toString(),
      categorySlug: json['category_slug']?.toString() ?? '',
    );
  }
}

class MyAdsResponse {
  final List<MyAdModel> ads;
  final int total;
  final int currentPage;
  final int lastPage;

  MyAdsResponse({
    required this.ads,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory MyAdsResponse.fromJson(Map<String, dynamic> json) {
    var adsList = json['data'] as List;
    List<MyAdModel> parsedAds = adsList.map((ad) => MyAdModel.fromJson(ad)).toList();

    return MyAdsResponse(
      ads: parsedAds,
      total: json['total'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
    );
  }
}