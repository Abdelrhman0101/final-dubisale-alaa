// lib/data/repository/electronics_repository.dart

import 'dart:io';
import 'package:advertising_app/data/model/car_service_filter_models.dart';
import 'package:advertising_app/data/model/electronics_ad_model.dart';
import 'package:advertising_app/data/model/best_electronics_advertiser_model.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class ElectronicsRepository {
  final ApiService _apiService;
  ElectronicsRepository(this._apiService);

  // دالة لجلب أنواع الأقسام
  Future<List<String>> getSectionTypes() async {
    final response = await _apiService.get('/api/electronic_ad_options');

    // الـ API يرجع قائمة من الكائنات، ونحن نريد 'options' من أول كائن
    if (response is List && response.isNotEmpty) {
      final sectionTypeObject = response.first;
      if (sectionTypeObject is Map &&
          sectionTypeObject['field_name'] == 'section_type' &&
          sectionTypeObject.containsKey('options') &&
          sectionTypeObject['options'] is List) {
        return List<String>.from(
            sectionTypeObject['options'].map((item) => item.toString()));
      }
      return <String>[];
    } else if (response is List && response.isEmpty) {
      // 404-safe: إذا رجعت قائمة فارغة نعيد قائمة فارغة بدون أخطاء
      return <String>[];
    } else if (response is Map<String, dynamic>) {
      if (response.containsKey('data') && response['data'] is List) {
        final dataList = response['data'] as List;
        if (dataList.isNotEmpty) {
          final sectionTypeObject = dataList.first;
          if (sectionTypeObject is Map &&
              sectionTypeObject.containsKey('options') &&
              sectionTypeObject['options'] is List) {
            return List<String>.from(
                sectionTypeObject['options'].map((item) => item.toString()));
          }
        }
        // data موجودة لكنها فارغة أو بدون options
        return <String>[];
      }
      // خريطة فارغة أو شكل غير متوقع
      return <String>[];
    }

    // أي شكل غير متوقع -> نعيد قائمة فارغة
    return <String>[];
  }
  
  // دالة لجلب الإمارات (معاد استخدامها)
  Future<List<EmirateModel>> getEmirates() async {
    final response = await _apiService.get('/api/locations/emirates',);
    if (response is Map<String, dynamic> && response.containsKey('emirates')) {
      return (response['emirates'] as List)
          .map((json) => EmirateModel.fromJson(json))
          .toList();
    }
    // 404-safe: في حال عدم توفر البيانات نعيد قائمة فارغة
    return <EmirateModel>[];
  }

  // دالة لإنشاء إعلان إلكترونيات جديد
 Future<void> createElectronicsAd({required String token, required Map<String, dynamic> adData}) async {
     final Map<String, dynamic> textData = {
        'title': adData['title'],
        'description': adData['description'],
        'emirate': adData['emirate'],
        'district': adData['district'],
        'area': adData['area'],
        'price': adData['price'],
        'product_name': adData['product_name'],
        'section_type': adData['section_type'],
        'advertiser_name': adData['advertiser_name'],
        'phone_number': adData['phone_number'],
        'whatsapp_number': adData['whatsapp_number'],
        'address': adData['address'],
        'plan_type': adData['planType'],
        'plan_days': adData['planDays'],
        'plan_expires_at': adData['planExpiresAt'],
     };

     await _apiService.postFormData(
       '/api/electronics',
       data: textData,
       mainImage: adData['mainImage'] as File,
       thumbnailImages: adData['thumbnailImages'] as List<File>,

     );
  }

  Future<ElectronicAdResponse> getElectronicAds({ Map<String, dynamic>? query}) async {
    // 1. استدعاء الـ API
    final response = await _apiService.get('/api/electronics', query: query);

    // 2. التحقق من شكل الاستجابة
    if (response is Map<String, dynamic>) {
      // 3. تحويل الـ JSON إلى الكائنات التي أنشأناها
      return ElectronicAdResponse.fromJson(response);
    }
    // 404-safe: بعض الحالات قد تعيد قائمة فارغة عند عدم وجود نتائج
    if (response is List) {
      return ElectronicAdResponse(ads: const [], total: 0);
    }

    // 404-safe: شكل غير متوقع -> إرجاع نتائج فارغة
    return ElectronicAdResponse(ads: const [], total: 0);
  }


Future<ElectronicAdModel> getElectronicAdDetails({required int adId, }) async {
    final response = await _apiService.get('/api/electronics/$adId');
    if (response is Map<String, dynamic>) {
      // API قد يغلف البيانات في 'data'
      return ElectronicAdModel.fromJson(response['data'] ?? response);
    }
    throw Exception('Failed to parse electronic ad details.');
  }

   Future<List<ElectronicAdModel>> getOffersBoxAds({ Map<String, dynamic>? query}) async {
    final response = await _apiService.get('/api/electronics/offers-box/ads', query: query);

    // Offers Box API typically returns a direct list or a list within a 'data' key.
    List<dynamic> adListJson = [];
    if (response is List) {
      adListJson = response;
    } else if (response is Map<String, dynamic> && response.containsKey('data') && response['data'] is List) {
      adListJson = response['data'];
    } else {
      // 404-safe: شكل غير متوقع -> إرجاع قائمة فارغة
      adListJson = const [];
    }

    return adListJson.map((json) => ElectronicAdModel.fromJson(json)).toList();
  }

  // دالة لجلب أفضل المعلنين للإلكترونيات
  Future<List<BestElectronicsAdvertiser>> getBestAdvertisers() async {
    final response = await _apiService.get('/api/best-advertisers/electronics');

    if (response is List) {
      return response
          .map((advertiserJson) => BestElectronicsAdvertiser.fromJson(advertiserJson))
          .toList();
    } else if (response is Map<String, dynamic> &&
        response.containsKey('data') && response['data'] is List) {
      return (response['data'] as List)
          .map((advertiserJson) => BestElectronicsAdvertiser.fromJson(advertiserJson))
          .toList();
    }

    // 404-safe: في حال عدم توفر البيانات نعيد قائمة فارغة
    return <BestElectronicsAdvertiser>[];
  }
}