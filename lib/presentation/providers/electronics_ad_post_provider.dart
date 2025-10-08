// lib/presentation/providers/electronics_ad_post_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_app/data/repository/electronics_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class ElectronicsAdPostProvider extends ChangeNotifier {
  final ElectronicsRepository _repository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ElectronicsAdPostProvider() : _repository = ElectronicsRepository(ApiService());
  
  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<bool> submitElectronicsAd(Map<String, dynamic> adData) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token not found');
      
      await _repository.createElectronicsAd(token: token, adData: adData);
      
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