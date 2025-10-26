import 'package:advertising_app/data/model/favorite_item_interface_model.dart';
import 'package:advertising_app/data/model/ad_priority.dart';

class FavoritesResponse {
  final bool status;
  final FavoritesData data;

  FavoritesResponse({
    required this.status,
    required this.data,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      status: json['status'] ?? false,
      data: FavoritesData.fromJson(json['data'] ?? {}),
    );
  }
}

class FavoritesData {
  final List<FavoriteItem> restaurant;
  final List<FavoriteItem> carServices;
  final List<FavoriteItem> carSales;
  final List<FavoriteItem> realEstate;
  final List<FavoriteItem> electronics;
  final List<FavoriteItem> jobs;
  final List<FavoriteItem> carRent;
  final List<FavoriteItem> otherServices;

  FavoritesData({
    this.restaurant = const [],
    this.carServices = const [],
    this.carSales = const [],
    this.realEstate = const [],
    this.electronics = const [],
    this.jobs = const [],
    this.carRent = const [],
    this.otherServices = const [],
  });

  factory FavoritesData.fromJson(Map<String, dynamic> json) {
    return FavoritesData(
      restaurant: _parseItemList(json['restaurant'] ?? json['Restaurant']),
      carServices: _parseItemList(json['car_services'] ?? json['Car Services']),
      carSales: _parseItemList(json['car_sales'] ?? json['Cars Sales']),
      realEstate: _parseItemList(json['real_estate'] ?? json['Real State']),
      electronics: _parseItemList(json['electronics'] ?? json['Electronics']),
      jobs: _parseItemList(json['jobs'] ?? json['Jobs'] ?? json['Jop'] ?? json['Job']),
      carRent: _parseItemList(json['car_rent'] ?? json['Car Rent']),
      otherServices: _parseItemList(json['other_services'] ?? json['Other Services']),
    );
  }

  static List<FavoriteItem> _parseItemList(dynamic jsonList) {
    if (jsonList == null) return [];
    return (jsonList as List)
        .map((item) => FavoriteItem.fromJson(item))
        .toList();
  }

  // Helper method to get all items as a list organized by category
  List<List<FavoriteItem>> getAllItemsByCategory() {
    return [
      carSales,      // index 0 - carsales
      realEstate,    // index 1 - realestate  
      electronics,   // index 2 - electronics
      jobs,          // index 3 - jobs
      carRent,       // index 4 - carrent
      carServices,   // index 5 - carservices
      restaurant,    // index 6 - restaurants
      otherServices, // index 7 - otherservices
    ];
  }
}

class FavoriteItem implements FavoriteItemInterface {
  final int favoriteId;
  final AdData ad;

  FavoriteItem({
    required this.favoriteId,
    required this.ad,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    // Handle the case where 'ad' might be a List or Map
    dynamic adData = json['ad'] ?? {};
    Map<String, dynamic> adMap;
    
    if (adData is List && adData.isNotEmpty) {
      // If 'ad' is a List, take the first item
      adMap = adData[0] as Map<String, dynamic>;
    } else if (adData is Map<String, dynamic>) {
      // If 'ad' is already a Map, use it directly
      adMap = adData;
    } else {
      // Fallback to empty map
      adMap = <String, dynamic>{};
    }
    
    return FavoriteItem(
      favoriteId: json['favorite_id'] ?? 0,
      ad: AdData.fromJson(adMap),
    );
  }

  // Implementation of FavoriteItemInterface
  @override
  String get title => ad.title;

  @override
  String get location => '${ad.emirate}, ${ad.district}';

  @override
  String get price => ad.price ?? ad.priceRange ?? 'غير محدد';

  @override
  String get line1 => ad.advertiserName;

  @override
  String get details => ad.description;

  @override
  String get date => ad.createdAt.split('T')[0]; // Extract date part

  @override
  String get contact => ad.phoneNumber;

  @override
  bool get isPremium => ad.planType == 'featured';

  @override
  List<String> get images => [
    if (ad.mainImageUrl.isNotEmpty) ad.mainImageUrl,
    ...ad.thumbnailImagesUrls,
  ];

  @override
  AdPriority get priority => isPremium ? AdPriority.premium : AdPriority.free;

  @override
  String get category => ad.addCategory;

  @override
  String get addCategory => ad.addCategory; // Dynamic category from API

  @override
  int get id => ad.id;
}

class AdData {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String emirate;
  final String district;
  final String area;
  final String priceRange;
  final String? price;
  final String? category;
  final String mainImage;
  final List<String> thumbnailImages;
  final String advertiserName;
  final String whatsappNumber;
  final String phoneNumber;
  final String address;
  final String addCategory;
  final String addStatus;
  final bool adminApproved;
  final int views;
  final int rank;
  final String? planType;
  final int? planDays;
  final String? planExpiresAt;
  final bool activeOffersBoxStatus;
  final int? activeOffersBoxDays;
  final String? activeOffersBoxExpiresAt;
  final String createdAt;
  final double? latitude;
  final double? longitude;
  final String mainImageUrl;
  final List<String> thumbnailImagesUrls;
  final String status;
  final String section;

  // Additional fields for specific categories
  final String? serviceType;
  final String? serviceName;
  final String? location;

  AdData({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.emirate,
    required this.district,
    required this.area,
    required this.priceRange,
    this.price,
    this.category,
    required this.mainImage,
    required this.thumbnailImages,
    required this.advertiserName,
    required this.whatsappNumber,
    required this.phoneNumber,
    required this.address,
    required this.addCategory,
    required this.addStatus,
    required this.adminApproved,
    required this.views,
    required this.rank,
    this.planType,
    this.planDays,
    this.planExpiresAt,
    required this.activeOffersBoxStatus,
    this.activeOffersBoxDays,
    this.activeOffersBoxExpiresAt,
    required this.createdAt,
    this.latitude,
    this.longitude,
    required this.mainImageUrl,
    required this.thumbnailImagesUrls,
    required this.status,
    required this.section,
    this.serviceType,
    this.serviceName,
    this.location,
  });

  factory AdData.fromJson(Map<String, dynamic> json) {
    return AdData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emirate: json['emirate'] ?? '',
      district: json['district'] ?? '',
      area: json['area'] ?? '',
      priceRange: json['price_range'] ?? json['price'] ?? '',
      price: json['price']?.toString(),
      category: json['category'],
      mainImage: json['main_image'] ?? '',
      thumbnailImages: _parseStringList(json['thumbnail_images']),
      advertiserName: json['advertiser_name'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? json['whatsapp'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? json['location'] ?? '',
      addCategory: json['add_category'] ?? '',
      addStatus: json['add_status'] ?? '',
      adminApproved: json['admin_approved'] ?? false,
      views: json['views'] ?? 0,
      rank: json['rank'] ?? 0,
      planType: json['plan_type'],
      planDays: json['plan_days'],
      planExpiresAt: json['plan_expires_at'],
      activeOffersBoxStatus: json['active_offers_box_status'] ?? false,
      activeOffersBoxDays: json['active_offers_box_days'],
      activeOffersBoxExpiresAt: json['active_offers_box_expires_at'],
      createdAt: json['created_at'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      mainImageUrl: json['main_image_url'] ?? '',
      thumbnailImagesUrls: _parseStringList(json['thumbnail_images_urls']),
      status: json['status'] ?? '',
      section: json['section'] ?? json['add_category'] ?? '',
      serviceType: json['service_type'],
      serviceName: json['service_name'],
      location: json['location'],
    );
  }

  static List<String> _parseStringList(dynamic jsonList) {
    if (jsonList == null) return [];
    if (jsonList is List) {
      return jsonList.map((item) => item.toString()).toList();
    }
    return [];
  }
}