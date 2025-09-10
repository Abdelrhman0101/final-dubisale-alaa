// lib/presentation/providers/car_services_ad_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:advertising_app/data/repository/car_services_ad_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CarServicesAdProvider extends ChangeNotifier {
  final CarServicesAdRepository _repository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  CarServicesAdProvider() : _repository = CarServicesAdRepository(ApiService());

  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

Future<bool> submitCarServiceAd(Map<String, dynamic> adData) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found!');
      }

      // ++ الآن نقوم باستخراج كل البيانات من الـ Map وتمريرها ++
      await _repository.createCarServiceAd(
        token: token,
        title: adData['title'],
        description: adData['description'],
        emirate: adData['emirate'],
        district: adData['district'],
        area: adData['area'],
        serviceName: adData['service_name'],
        serviceType: adData['service_type'],
        price: adData['price'],
        advertiserName: adData['advertiser_name'],
        phoneNumber: adData['phone_number'],
        whatsapp: adData['whatsapp'],
        location: adData['location'],
        mainImage: adData['mainImage'],
        thumbnailImages: (adData['thumbnailImages'] as List<File>).isNotEmpty ? adData['thumbnailImages'] : null,
        
        // ++ أهم جزء: تمرير بيانات الخطة التي كانت مفقودة ++
        planType: adData['planType'],
        planDays: adData['planDays'],
        planExpiresAt: adData['planExpiresAt'],
      );

      _isSubmitting = false;
      notifyListeners();
      return true;

    } catch (e) {
      print('CarServicesAdProvider Error: $e');
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }


}