import 'dart:async';
import 'dart:io';
import 'package:advertising_app/data/model/car_ad_model.dart';
import 'package:advertising_app/data/model/car_sales_filter_options_model.dart';
import 'package:advertising_app/data/model/best_advertiser_model.dart';
import 'package:advertising_app/data/repository/car_sales_ad_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CarAdProvider with ChangeNotifier {
  final CarAdRepository _carAdRepository;
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  CarAdProvider(this._carAdRepository);

  // --- SECTION 1: Ad List State (for Search & Manage Screens) ---
  bool _isLoadingAds = false;
  String? _loadAdsError;
  List<CarAdModel> _carAds = [];
  List<CarAdModel> _ads = [];
  int _totalAds = 0;

  // --- SECTION 2: Submit Ad State ---
  bool _isSubmittingAd = false;
  String? _submitAdError;

  bool get isLoadingAds => _isLoadingAds;
  String? get loadAdsError => _loadAdsError;
  List<CarAdModel> get carAds => _carAds;
  List<CarAdModel> get ads => _ads;
  int get totalAds => _totalAds;
  bool get isSubmittingAd => _isSubmittingAd;
  String? get submitAdError => _submitAdError;

  // --- SECTION 2: Ad Details & Editing State ---
  CarAdModel? _adDetails;
  bool _isLoadingDetails = false;
  String? _detailsError;
  bool _isUpdatingAd = false;
  String? _updateAdError;

  CarAdModel? get adDetails => _adDetails;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get detailsError => _detailsError;
  bool get isUpdatingAd => _isUpdatingAd;
  String? get updateAdError => _updateAdError;

  // --- SECTION 3: Create Ad State ---
  bool _isCreatingAd = false;
  String? _createAdError;
  bool get isCreatingAd => _isCreatingAd;
  String? get createAdError => _createAdError;

  // --- SECTION 4: Filter Options State ---
  List<MakeModel> _makes = [];
  List<CarModel> _models = [];
  List<TrimModel> _trims = [];
  bool _isLoadingMakes = false;
  bool _isLoadingModels = false;
  bool _isLoadingTrims = false;

  List<MakeModel> get makes {
    if (_makes.isEmpty) return [];
    return [
      MakeModel(id: -1, name: "All"),
      ..._makes,
      MakeModel(id: -2, name: "Other")
    ];
  }

  List<CarModel> get models => _models;
  List<TrimModel> get trims => _trims;
  bool get isLoadingMakes => _isLoadingMakes;
  bool get isLoadingModels => _isLoadingModels;
  bool get isLoadingTrims => _isLoadingTrims;

  // --- SECTION 5: Selected Filters State ---
  MakeModel? _selectedMake;
  CarModel? _selectedModel;
  List<TrimModel> _selectedTrims = [];
  List<MakeModel> _selectedMakes = [];
  List<CarModel> _selectedModels = [];
  List<String> _selectedYears = [];
  List<String> _years = [];
  String? yearFrom, yearTo, kmFrom, kmTo, priceFrom, priceTo;

  MakeModel? get selectedMake => _selectedMake;
  CarModel? get selectedModel => _selectedModel;
  List<TrimModel> get selectedTrims => _selectedTrims;
  List<MakeModel> get selectedMakes => _selectedMakes;
  List<CarModel> get selectedModels => _selectedModels;
  List<String> get selectedYears => _selectedYears;
  List<String> get years => _years.isEmpty
      ? [
          '2024',
          '2023',
          '2022',
          '2021',
          '2020',
          '2019',
          '2018',
          '2017',
          '2016',
          '2015'
        ]
      : _years;

  List<BestAdvertiser> _topDealerAds = [];
  bool _isLoadingTopDealers = false;
  String? _topDealersError;

  List<BestAdvertiser> get topDealerAds => _topDealerAds;
  bool get isLoadingTopDealers => _isLoadingTopDealers;
  String? get topDealersError => _topDealersError;

  bool _disposed = false;

  // Debouncing for search
  Timer? _searchDebounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  // Performance optimization
  bool _isInitialized = false;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // تحديث قائمة الإعلانات (للترتيب حسب الموقع)
  void updateCarAds(List<CarAdModel> sortedAds) {
    _carAds = sortedAds;
    safeNotifyListeners();
  }

  // Reset all states
  void resetAllStates() {
    _searchDebounceTimer?.cancel();
    _isLoadingAds = false;
    _loadAdsError = null;
    _carAds.clear();
    _allFetchedAds.clear();
    _totalAds = 0;
    _isInitialized = false;
    safeNotifyListeners();
  }

  // Check if provider is ready
  bool get isInitialized => _isInitialized;

  // Batch update for better performance
  void batchUpdate(Function() updates) {
    updates();
    safeNotifyListeners();
  }

  // --- All Functions ---

  /// The main function to fetch ads.
  // Debounced search function
  void debouncedFetchCarAds({Map<String, String>? filters}) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_debounceDelay, () {
      fetchCarAds(filters: filters);
    });
  }

  Future<void> fetchCarAds({Map<String, String>? filters}) async {
    // Prevent multiple simultaneous requests
    if (_isLoadingAds) return;

    _isLoadingAds = true;
    _loadAdsError = null;
    safeNotifyListeners();

    try {
      // Public data - no token required for browsing ads
      final queryParameters = filters ?? {};
      if (kDebugMode) print("==> FINAL QUERY TO API: $queryParameters");

      final response = await _carAdRepository.getCarAds(query: queryParameters);

      // Only update if not disposed
      if (!_disposed) {
        _allFetchedAds =
            response.ads; // Store all fetched ads for local filtering
        _totalAds = response.totalAds;

        // Apply local filters on the fetched data
        _performLocalFilter();
        _isInitialized = true;
      }
    } catch (e) {
      if (!_disposed) {
        _loadAdsError = e.toString();
        _carAds = [];
        _allFetchedAds = [];
        if (kDebugMode) print("Error fetching car ads: $e");
      }
    } finally {
      if (!_disposed) {
        _isLoadingAds = false;
        safeNotifyListeners();
      }
    }
  }

  // Store all fetched ads for local filtering
  List<CarAdModel> _allFetchedAds = [];

  /// Gathers all filters and triggers the fetch.
  Future<void> applyAndFetchAds({Map<String, String>? initialFilters}) async {
    Map<String, String> finalFilters = {};

    if (initialFilters != null) {
      finalFilters.addAll(initialFilters);

      final makeName = initialFilters['make'];
      if (makeName != null &&
          !_makes.any((m) => m.name == makeName) &&
          makes.any((m) => m.name == makeName)) {
        updateSelectedMake(makes.firstWhere((m) => m.name == makeName));
      }

      final modelName = initialFilters['model'];
      if (modelName != null &&
          !_models.any((m) => m.name == modelName) &&
          models.any((m) => m.name == modelName)) {
        updateSelectedModel(models.firstWhere((m) => m.name == modelName));
      }
    }

    // Only include API filters for make, model, and trim - year, km, price will be filtered locally
    if (_selectedMake != null) {
      if (_selectedMake!.id == -2) {
        // Other
        finalFilters['make'] = "Other";
      } else if (_selectedMake!.id > 0) {
        // Real Make
        finalFilters['make'] = _selectedMake!.name;
      }
      // If "All" is selected (id: -1), we don't add any 'make' filter
    }
    if (_selectedModel != null) {
      if (_selectedModel!.id == -2) {
        // Other
        finalFilters['model'] = "Other";
      } else if (_selectedModel!.id > 0) {
        // Real Model
        finalFilters['model'] = _selectedModel!.name;
      }
      // If "All" is selected (id: -1), we don't add any 'model' filter
    }
    if (_selectedTrims.isNotEmpty)
      finalFilters['trim'] = _selectedTrims.map((e) => e.name).join(',');

    await fetchCarAds(filters: finalFilters);
  }

  void _performLocalFilter() {
    List<CarAdModel> filteredList = List.from(_allFetchedAds);

    // Filter by Year
    final fromYear = int.tryParse(yearFrom ?? '');
    final toYear = int.tryParse(yearTo ?? '');
    if (fromYear != null)
      filteredList
          .retainWhere((ad) => (int.tryParse(ad.year) ?? 0) >= fromYear);
    if (toYear != null)
      filteredList.retainWhere((ad) => (int.tryParse(ad.year) ?? 0) <= toYear);

    // Filter by Km
    final fromKm = int.tryParse(kmFrom?.replaceAll(',', '') ?? '');
    final toKm = int.tryParse(kmTo?.replaceAll(',', '') ?? '');
    if (fromKm != null)
      filteredList.retainWhere(
          (ad) => (int.tryParse(ad.km.replaceAll(',', '')) ?? 0) >= fromKm);
    if (toKm != null)
      filteredList.retainWhere(
          (ad) => (int.tryParse(ad.km.replaceAll(',', '')) ?? 0) <= toKm);

    // Filter by Price
    final fromPrice = double.tryParse(priceFrom?.replaceAll(',', '') ?? '');
    final toPrice = double.tryParse(priceTo?.replaceAll(',', '') ?? '');
    if (fromPrice != null)
      filteredList.retainWhere((ad) =>
          (double.tryParse(ad.price.replaceAll(',', '')) ?? 0) >= fromPrice);
    if (toPrice != null)
      filteredList.retainWhere((ad) =>
          (double.tryParse(ad.price.replaceAll(',', '')) ?? 0) <= toPrice);

    // Filter by Trim - إضافة فلتر الـ trim للاختيارات المتعددة
    if (_selectedTrims.isNotEmpty) {
      final selectedTrimNames =
          _selectedTrims.map((trim) => trim.name.toLowerCase()).toSet();
      filteredList.retainWhere((ad) {
        if (ad.trim == null || ad.trim!.isEmpty) return false;
        return selectedTrimNames.contains(ad.trim!.toLowerCase());
      });
    }

    _carAds = filteredList;
    safeNotifyListeners();
  }

  // --- Functions to UPDATE filters & Trigger Local Filtering ---
  void updateYearRange(String? from, String? to) {
    yearFrom = from;
    yearTo = to;
    _performLocalFilter();
  }

  void updateKmRange(String? from, String? to) {
    kmFrom = from;
    kmTo = to;
    _performLocalFilter();
  }

  void updatePriceRange(String? from, String? to) {
    priceFrom = from;
    priceTo = to;
    _performLocalFilter();
  }

  void updateSelectedTrims(List<TrimModel> selection) {
    _selectedTrims = selection;
    _performLocalFilter(); // تطبيق الفلترة المحلية بدلاً من استدعاء API
  }

  void updateSelectedModel(CarModel? selection) {
    _selectedModel = selection;
    _selectedTrims.clear();
    _trims.clear();
    if (_selectedModel != null) {
      fetchTrimsForModel(_selectedModel!);
    }
    applyAndFetchAds();
    safeNotifyListeners();
  }

  void updateSelectedMake(MakeModel? selection) {
    _selectedMake = selection;
    _selectedModel = null;
    _selectedTrims.clear();
    _models.clear();
    _trims.clear();
    if (_selectedMake != null && _selectedMake!.id > 0) {
      fetchModelsForMake(_selectedMake!);
    } else if (_selectedMake != null && _selectedMake!.id == -1) {
      // When "All" is selected, fetch all models
      fetchAllModels();
    } else {
      applyAndFetchAds();
    }
    safeNotifyListeners();
  }

  void updateSelectedMakes(List<MakeModel> selection) {
    _selectedMakes = selection;
    _selectedModels.clear();
    _selectedTrims.clear();
    _models.clear();
    _trims.clear();
    if (_selectedMakes.length == 1) {
      fetchModelsForMake(_selectedMakes.first);
    } else {
      applyAndFetchAds();
    }
    safeNotifyListeners();
  }

  void updateSelectedModels(List<CarModel> selection) {
    _selectedModels = selection;
    _selectedTrims.clear();
    _trims.clear();
    if (_selectedModels.length == 1) {
      fetchTrimsForModel(_selectedModels.first);
    } else {
      applyAndFetchAds();
    }
    safeNotifyListeners();
  }

  void updateSelectedYears(List<String> selection) {
    _selectedYears = selection;
    applyAndFetchAds();
    safeNotifyListeners();
  }

  // دالة لمسح جميع الفلاتر
  void clearAllFilters() {
    _selectedMake = null;
    _selectedModel = null;
    _selectedTrims.clear();
    _selectedMakes.clear();
    _selectedModels.clear();
    _selectedYears.clear();
    _models.clear();
    _trims.clear();
    yearFrom = null;
    yearTo = null;
    kmFrom = null;
    kmTo = null;
    priceFrom = null;
    priceTo = null;
    safeNotifyListeners();
  }

  // --- Other Functions ---
  Future<void> fetchAdDetails(int adId) async {
    // Prevent multiple simultaneous requests for the same ad
    if (_isLoadingDetails) return;

    _isLoadingDetails = true;
    _detailsError = null;
    _adDetails = null;
    safeNotifyListeners();

    try {
      // Public data - no token required for viewing ad details
      final details = await _carAdRepository.getCarAdDetails(adId: adId);

      // Only update if not disposed
      if (!_disposed) {
        _adDetails = details;
      }
    } catch (e) {
      if (!_disposed) {
        _detailsError = e.toString();
        if (kDebugMode) print("Error fetching ad details: $e");
      }
    } finally {
      if (!_disposed) {
        _isLoadingDetails = false;
        safeNotifyListeners();
      }
    }
  }

  Future<void> fetchMakes() async {
    // Return early if already loaded or currently loading
    if (_makes.isNotEmpty || _isLoadingMakes) return;

    _isLoadingMakes = true;
    safeNotifyListeners();

    try {
      // Public data - no token required
      final makes = await _carAdRepository.getMakes();

      // Only update if not disposed
      if (!_disposed) {
        _makes = makes;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching makes: $e");
    } finally {
      if (!_disposed) {
        _isLoadingMakes = false;
        safeNotifyListeners();
      }
    }
  }

  Future<void> fetchModelsForMake(MakeModel make) async {
    _isLoadingModels = true;
    _models.clear();
    safeNotifyListeners();
    try {
      // Public data - no token required
      _models = await _carAdRepository.getModels(makeId: make.id);
    } catch (e) {
      if (kDebugMode) print("Error fetching models: $e");
    } finally {
      _isLoadingModels = false;
      safeNotifyListeners();
    }
  }

  Future<void> fetchAllModels() async {
    _isLoadingModels = true;
    _models.clear();
    safeNotifyListeners();
    try {
      // Public data - no token required
      _models = await _carAdRepository.getAllModels();
    } catch (e) {
      if (kDebugMode) print("Error fetching all models: $e");
    } finally {
      _isLoadingModels = false;
      safeNotifyListeners();
    }
  }

  Future<void> fetchTrimsForModel(CarModel model) async {
    _isLoadingTrims = true;
    _trims.clear();
    safeNotifyListeners();
    try {
      // Public data - no token required
      _trims = await _carAdRepository.getTrims(modelId: model.id);
    } catch (e) {
      if (kDebugMode) print("Error fetching trims: $e");
    } finally {
      _isLoadingTrims = false;
      safeNotifyListeners();
    }
  }

  Future<bool> updateAd(Map<String, dynamic> adData, String adId) async {
    _isUpdatingAd = true;
    _updateAdError = null;
    safeNotifyListeners();

    try {
      // الاعتماد حصراً على auth_token
      final token = await FlutterSecureStorage().read(key: 'auth_token');
      
      final response = await _apiService.put(
        '/api/car-ads/$adId',
        data: adData,
        token: token,
      );

      if (response['success'] == true) {
        // Update the ad in the local list if it exists
        final adIndex = _ads.indexWhere((ad) => ad.id == adId);
        if (adIndex != -1) {
          // Refresh the ads list to get updated data
          await fetchCarAds();
        }
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to update ad');
      }
    } catch (e) {
      _updateAdError = e.toString();
      return false;
    } finally {
      _isUpdatingAd = false;
      safeNotifyListeners();
    }
  }

  Future<bool> submitCarAd(Map<String, dynamic> adData) async {
    _isSubmittingAd = true;
    _submitAdError = null;
    safeNotifyListeners();

    try {
      // الاعتماد حصراً على auth_token
      final token = await FlutterSecureStorage().read(key: 'auth_token');
      
      final response = await _apiService.post(
        '/api/car-ads',
        data: adData,
        token: token,
      );

      if (response['success'] == true) {
        // Refresh the ads list to include the new ad
        await fetchCarAds();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to submit ad');
      }
    } catch (e) {
      _submitAdError = e.toString();
      return false;
    } finally {
      _isSubmittingAd = false;
      safeNotifyListeners();
    }
  }

  Future<void> fetchTopDealerAds({bool forceRefresh = false}) async {
    if (!forceRefresh && _topDealerAds.isNotEmpty) return;
    _isLoadingTopDealers = true;
    _topDealersError = null;
    safeNotifyListeners();
    try {
      // Public data - no token required
      _topDealerAds = await _carAdRepository.getBestAdvertiserAds(
          category: 'car_sales');
    } catch (e) {
      if (kDebugMode) print("Error fetching top dealer ads: $e");
      _topDealersError = e.toString();
    } finally {
      _isLoadingTopDealers = false;
      safeNotifyListeners();
    }
  }

  bool get isSearchEnabled {
    if (_selectedMake == null) return false;
    if (_selectedMake!.id == -1 || _selectedMake!.id == -2) return true;
    if (_isLoadingModels) return false;
    if (_models.isNotEmpty && _selectedModel == null) return false;
    return true;
  }

  String getSearchValidationMessage(S s) {
    if (_selectedMake == null) return "Please select make.";
    if (_selectedMake!.id > 0 && _models.isNotEmpty && _selectedModel == null)
      return "please_select_model";
    return ""; // No error
  }

  List<CarAdModel> _offerAds = [];
  bool _isLoadingOffers = false;
  String? _offersError;

  List<CarAdModel> get offerAds => _offerAds;
  bool get isLoadingOffers => _isLoadingOffers;
  String? get offersError => _offersError;

  // ... (كل الدوال القديمة)

  List<CarAdModel> _allFetchedOfferAds = []; // القائمة الكاملة للعروض

  // فلاتر خاصة بالعروض
  String? offerYearFrom,
      offerYearTo,
      offerKmFrom,
      offerKmTo,
      offerPriceFrom,
      offerPriceTo;

  // +++ أضف هذه الدالة الجديدة +++
  // Future<void> fetchOfferAds() async {
  //   _isLoadingOffers = true;
  //   _offersError = null;
  //   notifyListeners();
  //   try {
  //     final token = await const FlutterSecureStorage().read(key: 'auth_token');
  //     if (token == null) throw Exception('Token not found');
  //     _offerAds = await _carAdRepository.getOfferAds(token: token);
  //   } catch (e) {
  //     _offersError = e.toString();
  //     if (kDebugMode) print("Error fetching offer ads: $e");
  //   } finally {
  //     _isLoadingOffers = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchOfferAds() async {
    _isLoadingOffers = true;
    _offersError = null;
    safeNotifyListeners();
    try {
      // Public data - no token required for browsing car offer ads
      final ads = await _carAdRepository.getOfferAds();
      _allFetchedOfferAds = ads;

      _performLocalOfferFilter(); // Apply current filters (if any) right away
    } catch (e) {
      _offersError = e.toString();
    } finally {
      _isLoadingOffers = false;
      safeNotifyListeners();
    }
  }

  void _performLocalOfferFilter() {
    List<CarAdModel> filteredList = List.from(_allFetchedOfferAds);
    // Filter by Year
    final fromYear = int.tryParse(offerYearFrom ?? '');
    final toYear = int.tryParse(offerYearTo ?? '');
    if (fromYear != null)
      filteredList
          .retainWhere((ad) => (int.tryParse(ad.year) ?? 0) >= fromYear);
    if (toYear != null)
      filteredList.retainWhere((ad) => (int.tryParse(ad.year) ?? 0) <= toYear);
    // Filter by Km
    final fromKm = int.tryParse(offerKmFrom?.replaceAll(',', '') ?? '');
    final toKm = int.tryParse(offerKmTo?.replaceAll(',', '') ?? '');
    if (fromKm != null)
      filteredList.retainWhere(
          (ad) => (int.tryParse(ad.km.replaceAll(',', '')) ?? 0) >= fromKm);
    if (toKm != null)
      filteredList.retainWhere(
          (ad) => (int.tryParse(ad.km.replaceAll(',', '')) ?? 0) <= toKm);
    // Filter by Price
    final fromPrice =
        double.tryParse(offerPriceFrom?.replaceAll(',', '') ?? '');
    final toPrice = double.tryParse(offerPriceTo?.replaceAll(',', '') ?? '');
    if (fromPrice != null)
      filteredList.retainWhere((ad) =>
          (double.tryParse(ad.price.replaceAll(',', '')) ?? 0) >= fromPrice);
    if (toPrice != null)
      filteredList.retainWhere((ad) =>
          (double.tryParse(ad.price.replaceAll(',', '')) ?? 0) <= toPrice);

    _offerAds = filteredList;
    safeNotifyListeners();
  }

  void updateYearRangeForOffers(String? from, String? to) {
    offerYearFrom = from;
    offerYearTo = to;
    _performLocalOfferFilter();
  }

  void updateKmRangeForOffers(String? from, String? to) {
    offerKmFrom = from;
    offerKmTo = to;
    _performLocalOfferFilter();
  }

  void updatePriceRangeForOffers(String? from, String? to) {
    offerPriceFrom = from;
    offerPriceTo = to;
    _performLocalOfferFilter();
  }
}




