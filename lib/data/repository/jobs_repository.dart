// lib/data/repository/jobs_repository.dart
import 'package:advertising_app/data/model/job_ad_model.dart';
import 'package:advertising_app/data/model/best_advertiser_model.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class JobsRepository {
  final ApiService _apiService;
  JobsRepository(this._apiService);

  Future<JobAdResponse> getJobAds({String? token, Map<String, dynamic>? query}) async {
    final response = await _apiService.get('/api/jobs', query: query);
    
    if (response is Map<String, dynamic>) {
      return JobAdResponse.fromJson(response);
    }
    
    throw Exception('API response format is not as expected for JobAdResponse.');
  }

  Future<List<BestAdvertiser>> getBestAdvertisers({String? token}) async {
    final response = await _apiService.get('/api/best-advertisers/jobs');
    
    if (response is List) {
      return response.map((advertiserJson) => BestAdvertiser.fromJson(advertiserJson)).toList();
    }
    
    throw Exception('API response format is not as expected for BestAdvertisers.');
  }

  Future<List<JobAdModel>> getJobOfferAds({String? token, Map<String, String>? filters}) async {
    try {
      String endpoint = '/api/jobs/offers-box/ads';
      
      // إضافة الفلاتر كـ query parameters
      Map<String, dynamic>? queryParams;
      if (filters != null && filters.isNotEmpty) {
        queryParams = Map<String, dynamic>.from(filters);
      }
      
      final response = await _apiService.get(endpoint, token: token, query: queryParams);
      
      if (response is List) {
        return response.map((json) => JobAdModel.fromJson(json)).toList();
      } else if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List).map((json) => JobAdModel.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format for job offer ads');
      }
    } catch (e) {
      throw Exception('Failed to fetch job offer ads: $e');
    }
  }
  

  Future<Map<String, String>> getJobCategoryImages({String? token}) async {
    final response = await _apiService.get('/api/job-category-images', token: token);
    
    if (response is Map<String, dynamic> && response['success'] == true && response['data'] is Map) {
      final Map<String, dynamic> data = response['data'];
      final Map<String, String> imagesMap = {};

      data.forEach((key, value) {
        if (value is Map && value.containsKey('image')) {
          // الـ key سيكون 'job_offer' أو 'job_seeker'
          // الـ value['image'] هو مسار الصورة
          imagesMap[key] = value['image'];
        }
      });
      return imagesMap;
    }
    
    throw Exception('Failed to parse job category images.');
  }


Future<JobAdModel> getJobAdDetails({required int adId, String? token}) async {
    final response = await _apiService.get('/api/jobs/$adId', token: token);
    
    if (response is Map<String, dynamic>) {
      // الـ API قد يغلف البيانات داخل مفتاح "data"
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        return JobAdModel.fromJson(response['data']);
      }
      // أو قد يرسلها مباشرة (كما في المثال الذي أرسلته)
      return JobAdModel.fromJson(response);
    }
    
    throw Exception('API response format is not as expected for JobAdModel.');
  }


}