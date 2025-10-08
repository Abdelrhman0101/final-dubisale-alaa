// lib/presentation/providers/other_services_ad_post_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_app/data/repository/other_services_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class OtherServicesAdPostProvider extends ChangeNotifier {
  final OtherServicesRepository _repository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  OtherServicesAdPostProvider() : _repository = OtherServicesRepository(ApiService());
  
  bool _isSubmitting = false;
  String? _error;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<bool> submitOtherServiceAd(Map<String, dynamic> adData) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token not found');
      await _repository.createOtherServiceAd(token: token, adData: adData);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch(e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}