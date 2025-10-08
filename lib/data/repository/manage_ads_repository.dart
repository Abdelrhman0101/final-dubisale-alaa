import 'package:advertising_app/data/model/my_ad_model.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class ManageAdsRepository {
  final ApiService _apiService;
  ManageAdsRepository(this._apiService);

  Future<MyAdsResponse> getMyAds({String? token}) async {
    // يمكن إضافة query parameters هنا إذا احتجت للـ pagination
    // مثال: final response = await _apiService.get('/api/my-ads', token: token, query: {'page': 1});
    final response = await _apiService.get('/api/my-ads', token: token);

    if (response is Map<String, dynamic>) {
      return MyAdsResponse.fromJson(response);
    }
    
    throw Exception('Failed to parse MyAdsResponse');
  }


  Future<void> activateOffer({
    required String token,
    required int adId,
    required String categorySlug,
    required int days,
  }) async {
    final body = {
      'ad_id': adId,
      'category_slug': categorySlug,
      'days': days,
    };
    
    try {
      // استخدم دالة 'post' الموجودة في ApiService
      final response = await _apiService.post('/api/offers-box/activate', data: body, token: token);
    } catch (e) {
      rethrow;
    }
  }
}