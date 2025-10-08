// lib/presentation/providers/electronics_ad_provider.dart
import 'package:advertising_app/data/model/electronics_ad_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_app/data/repository/electronics_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class ElectronicsAdProvider extends ChangeNotifier {
  final ElectronicsRepository _repository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ElectronicsAdProvider() : _repository = ElectronicsRepository(ApiService());
 
  List<String> _productNames = [];
  List<String> get productNames => _productNames;

  List<ElectronicAdModel> _ads = [];
  List<ElectronicAdModel> _allFetchedAds = []; // Store all fetched ads for local filtering
  bool _isLoading = false;
  String? _error;
  int _totalAds = 0;

  List<ElectronicAdModel> _offerAds = [];
  List<ElectronicAdModel> _allFetchedOfferAds = []; // Store all fetched offer ads for local filtering
  bool _isLoadingOffers = false;
  String? _offersError;
  
  // Product names derived from currently visible offer ads only
  List<String> _offerProductNames = [];
  List<String> get offerProductNames => _offerProductNames;

  // Price filter properties
  String? priceFrom;
  String? priceTo;
  
  // Offer price filter properties
  String? offerPriceFrom;
  String? offerPriceTo;

  List<ElectronicAdModel> get offerAds => _offerAds;
  bool get isLoadingOffers => _isLoadingOffers;
  String? get offersError => _offersError;

  List<ElectronicAdModel> get ads => _ads;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalAds => _ads.length;
  
  // Selected product names for local filtering
  List<String> _selectedProductNames = [];

  Future<void> fetchAds({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Public data - no token required for browsing electronic ads
      final response = await _repository.getElectronicAds(query: filters);
      _allFetchedAds = response.ads; // Store all fetched ads
      _ads = response.ads;
      _totalAds = response.total;

      if (_ads.isNotEmpty) {
        // .toSet() لإزالة التكرار
        _productNames = _ads.map((ad) => ad.productName).where((name) => name != null).cast<String>().toSet().toList();
      }

      // Apply local price filter if exists
      _performLocalFilter();
      
    } catch (e) {
      // 404-tolerant: في حال حدوث خطأ أثناء التصفح، نظهر قوائم فارغة بدل التعطل
      _error = e.toString();
      _allFetchedAds = [];
      _ads = [];
      _productNames = [];
      _totalAds = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update selected product names and apply local filter
  void updateSelectedProductNames(List<String> names) {
    _selectedProductNames = names;
    // Apply on both regular ads and offer ads
    _performLocalFilter();
    _performLocalOfferFilter();
  }

  Future<void> fetchOfferAds({Map<String, dynamic>? filters}) async {
    _isLoadingOffers = true;
    _offersError = null;
    notifyListeners();

    try {
      // Public data - no token required for browsing electronic offer ads
      final fetchedOffers = await _repository.getOffersBoxAds(query: filters);
      _allFetchedOfferAds = fetchedOffers; // Store all fetched offers
      _offerAds = fetchedOffers;
      
      // Extract product names ONLY from the currently fetched offer ads
      if (_offerAds.isNotEmpty) {
        _offerProductNames = _offerAds
            .map((ad) => ad.productName?.trim())
            .where((name) => name != null && name!.isNotEmpty)
            .cast<String>()
            .toSet()
            .toList();
      } else {
        _offerProductNames = [];
      }
      
      // Apply local price filter if exists
      _performLocalOfferFilter();
      
    } catch (e) {
      // 404-tolerant: إرجاع قائمة عروض فارغة عند الخطأ
      _offersError = e.toString();
      _allFetchedOfferAds = [];
      _offerAds = [];
      _offerProductNames = [];
    } finally {
      _isLoadingOffers = false;
      notifyListeners();
    }
  }

  /// Apply price filter locally
  List<ElectronicAdModel> _applyPriceFilter(List<ElectronicAdModel> ads) {
    List<ElectronicAdModel> filteredAds = List.from(ads);
    
    final fromPrice = double.tryParse(priceFrom?.replaceAll(',', '') ?? '');
    final toPrice = double.tryParse(priceTo?.replaceAll(',', '') ?? '');
    
    if (fromPrice != null) {
      filteredAds = filteredAds.where((ad) {
        final adPrice = double.tryParse(ad.price.replaceAll(',', '')) ?? 0;
        return adPrice >= fromPrice;
      }).toList();
    }
    
    if (toPrice != null) {
      filteredAds = filteredAds.where((ad) {
        final adPrice = double.tryParse(ad.price.replaceAll(',', '')) ?? 0;
        return adPrice <= toPrice;
      }).toList();
    }
    
    return filteredAds;
  }

  /// Update price range and apply filter locally
  void updatePriceRange(String? from, String? to) {
    priceFrom = (from == null || from.isEmpty) ? null : from.replaceAll(RegExp(r'[^0-9.]'), '');
    priceTo = (to == null || to.isEmpty) ? null : to.replaceAll(RegExp(r'[^0-9.]'), '');
    _performLocalFilter();
  }

  /// Clear price filters
  void clearPriceFilters() {
    priceFrom = null;
    priceTo = null;
    _performLocalFilter();
  }

  /// Apply price filter locally for offers
  List<ElectronicAdModel> _applyOfferPriceFilter(List<ElectronicAdModel> ads) {
    List<ElectronicAdModel> filteredAds = List.from(ads);
    
    final fromPrice = double.tryParse(offerPriceFrom?.replaceAll(',', '') ?? '');
    final toPrice = double.tryParse(offerPriceTo?.replaceAll(',', '') ?? '');
    
    if (fromPrice != null) {
      filteredAds = filteredAds.where((ad) {
        final adPrice = double.tryParse(ad.price.replaceAll(',', '')) ?? 0;
        return adPrice >= fromPrice;
      }).toList();
    }
    
    if (toPrice != null) {
      filteredAds = filteredAds.where((ad) {
        final adPrice = double.tryParse(ad.price.replaceAll(',', '')) ?? 0;
        return adPrice <= toPrice;
      }).toList();
    }
    
    return filteredAds;
  }

  /// Update offer price range and apply filter locally
  void updateOfferPriceRange(String? from, String? to) {
    offerPriceFrom = (from == null || from.isEmpty) ? null : from.replaceAll(RegExp(r'[^0-9.]'), '');
    offerPriceTo = (to == null || to.isEmpty) ? null : to.replaceAll(RegExp(r'[^0-9.]'), '');
    _performLocalOfferFilter();
  }

  /// Clear offer price filters
  void clearOfferPriceFilters() {
    offerPriceFrom = null;
    offerPriceTo = null;
    _performLocalOfferFilter();
  }

  /// Apply all local filters on stored offer data
  void _performLocalOfferFilter() {
    List<ElectronicAdModel> filteredList = List.from(_allFetchedOfferAds);
    
    // Apply price filter
    filteredList = _applyOfferPriceFilter(filteredList);

    // Apply product name filter locally for offers
    if (_selectedProductNames.isNotEmpty) {
      filteredList = filteredList.where((ad) {
        final name = ad.productName ?? '';
        return name.isNotEmpty && _selectedProductNames.contains(name);
      }).toList();
    }
    
    _offerAds = filteredList;
    
    // Refresh offer product names based on currently visible offers
    if (_offerAds.isNotEmpty) {
      _offerProductNames = _offerAds
          .map((ad) => ad.productName?.trim())
          .where((name) => name != null && name!.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
    } else {
      _offerProductNames = [];
    }
    notifyListeners();
  }

  /// Apply all local filters on stored data
  void _performLocalFilter() {
    List<ElectronicAdModel> filteredList = List.from(_allFetchedAds);
    
    // Apply price filter
    filteredList = _applyPriceFilter(filteredList);
    
    // Apply product name filter locally
    if (_selectedProductNames.isNotEmpty) {
      filteredList = filteredList.where((ad) {
        final name = ad.productName ?? '';
        return name.isNotEmpty && _selectedProductNames.contains(name);
      }).toList();
    }
    
    _ads = filteredList;
    notifyListeners();
  }
}