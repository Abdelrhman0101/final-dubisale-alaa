// lib/presentation/providers/restaurant_details_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_app/data/model/restaurant_ad_model.dart';
import 'package:advertising_app/data/repository/restaurants_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class RestaurantDetailsProvider extends ChangeNotifier {
  final RestaurantsRepository _repository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RestaurantDetailsProvider() : _repository = RestaurantsRepository(ApiService());

  RestaurantAdModel? _adDetails;
  bool _isLoading = false;
  String? _error;

  RestaurantAdModel? get adDetails => _adDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAdDetails(int adId) async {
    _isLoading = true;
    _error = null;
    _adDetails = null;
    notifyListeners();

    try {
      // Public data - no token required for viewing restaurant ad details
      _adDetails = await _repository.getRestaurantAdDetails(adId: adId);

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}