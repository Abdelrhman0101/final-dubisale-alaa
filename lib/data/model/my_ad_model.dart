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
      id: int.tryParse(json['id']?.toString() ?? '') ?? (json['id'] is int ? json['id'] as int : 0),
      title: json['title']?.toString() ?? '',
      planType: json['plan_type']?.toString(),
      mainImageUrl: json['main_image_url']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
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
    // Be tolerant to various API shapes: data, ads, or null
    List<dynamic> rawList = const [];
    if (json['data'] is List) {
      rawList = json['data'] as List;
    } else if (json['ads'] is List) {
      rawList = json['ads'] as List;
    } else {
      rawList = const [];
    }

    final parsedAds = rawList
        .whereType<Map<String, dynamic>>()
        .map((ad) => MyAdModel.fromJson(ad))
        .toList();

    final total = json['total'] ?? json['total_ads'] ?? json['count'] ?? parsedAds.length;
    final currentPage = json['current_page'] ?? json['currentPage'] ?? 1;
    final lastPage = json['last_page'] ?? json['lastPage'] ?? 1;

    return MyAdsResponse(
      ads: parsedAds,
      total: total is int ? total : int.tryParse(total.toString()) ?? parsedAds.length,
      currentPage: currentPage is int ? currentPage : int.tryParse(currentPage.toString()) ?? 1,
      lastPage: lastPage is int ? lastPage : int.tryParse(lastPage.toString()) ?? 1,
    );
  }
}