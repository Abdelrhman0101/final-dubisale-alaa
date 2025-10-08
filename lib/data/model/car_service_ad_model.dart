// lib/data/model/car_service_ad_model.dart
import 'dart:convert';

// Model لتمثيل الإعلان نفسه
class CarServiceModel {
  final int id;
  final String? planType;
  final String title;
  final String description;
  final String emirate;
  final String district;
  final String? area;
  final String serviceType;
  final String serviceName;
  final String price;
  final String advertiserName;
  final String phoneNumber;
  final String? whatsapp;
  final String? mainImage;
  final List<String> thumbnailImages;
  final String? location;
  final String? createdAt; // سنضيفه للترتيب

  CarServiceModel({
    required this.id,
    this.planType,
    required this.title,
    required this.description,
    required this.emirate,
    required this.district,
    this.area,
    required this.serviceType,
    required this.serviceName,
    required this.price,
    required this.advertiserName,
    required this.phoneNumber,
    this.whatsapp,
    this.mainImage,
    required this.thumbnailImages,
    this.location,
    this.createdAt,
  });

  factory CarServiceModel.fromJson(Map<String, dynamic> json) {
    // معالجة الصور المصغرة
    List<String> thumbs = [];
    
    // البحث عن thumbnail_images_urls أولاً (الاسم الصحيح من API)
    var thumbnailData = json['thumbnail_images_urls'] ?? json['thumbnail_images'];
    
    if (thumbnailData != null) {
      if (thumbnailData is String) {
        try {
          final decoded = jsonDecode(thumbnailData);
          if (decoded is List) {
            thumbs = decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          // في حال فشل التحويل، تبقى القائمة فارغة
        }
      } else if (thumbnailData is List) {
        // إذا كانت البيانات عبارة عن قائمة مباشرة
        thumbs = thumbnailData.map((e) => e.toString()).toList();
      }
    }
    
    return CarServiceModel(
      id: json['id'],
      planType: json['plan_type'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      emirate: json['emirate'] ?? 'Unknown Emirate',
      district: json['district'] ?? 'Unknown District',
      area: json['area'],
      serviceType: json['service_type'] ?? 'other',
      serviceName: json['service_name'] ?? 'No Service Name',
      price: (json['price'] ?? '0.00').toString(),
      advertiserName: json['advertiser_name'] ?? 'N/A',
      phoneNumber: json['phone_number'] ?? 'N/A',
      whatsapp: json['whatsapp'],
      mainImage: json['main_image'],
      thumbnailImages: thumbs,
      location: json['location'],
      createdAt: json['created_at'],
    );
  }
}

// Model لتغليف الاستجابة الكاملة من الـ API
class CarServiceAdResponse {
  final List<CarServiceModel> ads;
  final int currentPage;
  final int lastPage;

  CarServiceAdResponse({
    required this.ads,
    required this.currentPage,
    required this.lastPage,
  });

  factory CarServiceAdResponse.fromJson(Map<String, dynamic> json) {
    var adList = <CarServiceModel>[];
    if (json['data'] != null && json['data'] is List) {
      adList = (json['data'] as List).map((i) => CarServiceModel.fromJson(i)).toList();
    }
    return CarServiceAdResponse(
      ads: adList,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
    );
  }
}