// lib/data/repository/car_rent_repository.dart
import 'dart:io';

import 'package:advertising_app/data/model/car_rent_ad_model.dart';
import 'package:advertising_app/data/model/car_sales_filter_options_model.dart'; // لإعادة استخدام Make, Model
import 'package:advertising_app/data/model/car_specs_model.dart';
import 'package:advertising_app/data/web_services/api_service.dart';
import 'package:advertising_app/data/model/car_service_filter_models.dart'; // لإعادة استخدام EmirateModel
import 'package:advertising_app/data/model/best_advertiser_model.dart';


class CarRentRepository {
  final ApiService _apiService;
  CarRentRepository(this._apiService);

  // --- دالة لجلب قائمة إعلانات الإيجار (موجودة لديك) ---
  Future<CarRentAdResponse> getCarRentAds({String? token, Map<String, dynamic>? query}) async {
    // print('=== CarRentRepository.getCarRentAds ===');
    // print('Query parameters: $query');
    // print('API endpoint: /api/car-rent');
    
    final response = await _apiService.get('/api/car-rent', query: query);
    
    // print('Raw API response type: ${response.runtimeType}');
    // print('Raw API response: $response');
    
    if (response is Map<String, dynamic>) {
      final carRentResponse = CarRentAdResponse.fromJson(response);
      // print('Parsed response - Total: ${carRentResponse.total}, Ads count: ${carRentResponse.ads.length}');
      return carRentResponse;
    }
    throw Exception('API response format is not as expected for CarRentAdResponse.');
  }

  // --- دوال لجلب بيانات الفلاتر لشاشة الإضافة ---
  Future<List<EmirateModel>> getEmirates({String? token}) async {
    final response = await _apiService.get('/api/locations/emirates', token: token);
    if (response is Map<String, dynamic> && response.containsKey('emirates')) {
      return (response['emirates'] as List).map((json) => EmirateModel.fromJson(json)).toList();
    }
    throw Exception('Failed to parse emirates from API response.');
  }

  // نفترض أن قسم الإيجار يستخدم نفس فلاتر الماركات والموديلات
  Future<List<MakeModel>> getMakes({String? token}) async {
    final response = await _apiService.get('/api/filters/car-sale/makes');
    if (response is List) {
      return response.map((make) => MakeModel.fromJson(make)).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List).map((make) => MakeModel.fromJson(make)).toList();
    }
    throw Exception('Failed to parse Makes list.');
  }
  
  Future<List<CarModel>> getModels({required int makeId, String? token}) async {
    final response = await _apiService.get('/api/filters/car-sale/makes/$makeId/models');
    if (response is List) {
      return response.map((model) => CarModel.fromJson(model)).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List).map((model) => CarModel.fromJson(model)).toList();
    }
    throw Exception('Failed to parse Models list from API.');
  }

  // دالة جديدة لجلب جميع الموديلات بدون تحديد make
  Future<List<CarModel>> getAllModels({String? token}) async {
    final response = await _apiService.get('/api/filters/car-sale/models');
    if (response is List) {
      return response.map((model) => CarModel.fromJson(model)).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List).map((model) => CarModel.fromJson(model)).toList();
    }
    throw Exception('Failed to parse All Models list from API.');
  }

  Future<List<TrimModel>> getTrims({required int modelId, String? token}) async {
    final response = await _apiService.get('/api/filters/car-sale/models/$modelId/trims');
    if (response is List) {
       return response.map((trim) => TrimModel.fromJson(trim)).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
       return (response['data'] as List).map((trim) => TrimModel.fromJson(trim)).toList();
    }
    throw Exception('Failed to parse Trims list.');
  }

  // دالة إنشاء إعلان تأجير سيارات جديد
  Future<void> createCarRentAd({required String token, required Map<String, dynamic> adData}) async {
    await _apiService.postFormData(
      '/api/car-rent-ads/', // Updated endpoint as requested
      data: {
        'emirate': adData['emirate'],
        'make': adData['make'],
        'model': adData['model'],
        'trim': adData['trim'],
        'price': adData['price'],
        'year': adData['year'],
        'day_rent': adData['day_rent'],
        'month_rent': adData['month_rent'],
        'title': adData['title'],
        'car_type': adData['car_type'],
        'trans_type': adData['trans_type'],
        'fuel_type': adData['fuel_type'],
        'color': adData['color'],
        'interior_color': adData['interior_color'],
        'seats_no': adData['seats_no'],
        'area': adData['area'],
        'phone_number': adData['phone_number'],
        'whatsapp': adData['whatsapp'],
        'advertiser_name': adData['advertiser_name'],
        'description': adData['description'],
        'location': adData['location'],
        'plan_type': adData['planType'],
        'plan_days': adData['planDays'],
        'plan_expires_at': adData['planExpiresAt'],
      },
      mainImage: adData['mainImage'],
      thumbnailImages: adData['thumbnailImages'],
      token: token,
    );
  }


  Future<List<CarSpecField>> getCarAdSpecs({String? token}) async {
    final response = await _apiService.get('/api/car-sales-ad-specs');
    if (response is Map<String, dynamic> && response['success'] == true && response['data'] is List) {
      final List<dynamic> fieldsJson = response['data'];
      return fieldsJson.map((json) => CarSpecField.fromJson(json)).toList();
    }
    throw Exception('Failed to parse car specs from API response');
  }

  // دالة لجلب أفضل المعلنين لفئة تأجير السيارات
  Future<List<BestAdvertiser>> getBestAdvertiserAds({String? token, required String category}) async {
    // استخدام الـ category في الـ endpoint مباشرة بدلاً من query parameter
    String endpoint = '/api/best-advertisers';
    if (category.isNotEmpty) {
      endpoint = '/api/best-advertisers/$category';
    }
    
    final response = await _apiService.get(endpoint, token: token);
    
    if (response is List) {
      // استخدام الـ filterByCategory في الـ fromJson مباشرة
      List<BestAdvertiser> advertisers = response
          .map((json) => BestAdvertiser.fromJson(json, filterByCategory: category))
          .where((advertiser) => advertiser.ads.isNotEmpty) // فقط الـ advertisers الذين لديهم إعلانات
          .toList();
      return advertisers;
    } 
    else if (response is Map<String, dynamic> && response['data'] is List) {
      List<BestAdvertiser> advertisers = (response['data'] as List)
          .map((json) => BestAdvertiser.fromJson(json, filterByCategory: category))
          .where((advertiser) => advertiser.ads.isNotEmpty) // فقط الـ advertisers الذين لديهم إعلانات
          .toList();
      return advertisers;
    }
    
    throw Exception('Failed to parse Best Advertiser Ads from API response.');
  }

}