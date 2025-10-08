// lib/presentation/providers/other_services_details_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_app/data/model/other_service_ad_model.dart';
import 'package:advertising_app/data/repository/other_services_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class OtherServicesDetailsProvider extends ChangeNotifier {
  final OtherServicesRepository _repository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  OtherServicesDetailsProvider() : _repository = OtherServicesRepository(ApiService());

  OtherServiceAdModel? _adDetails;
  bool _isLoading = false;
  String? _error;

  OtherServiceAdModel? get adDetails => _adDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAdDetails(int adId) async {
    _isLoading = true;
    _error = null;
    _adDetails = null;
    notifyListeners();

    try {
      // Public data - no token required for viewing service details
      _adDetails = await _repository.getOtherServiceDetails(adId: adId);

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}