import 'dart:io';

import 'package:advertising_app/data/web_services/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:advertising_app/constant/string.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(milliseconds: 60000), // زيادة إلى 60 ثانية
      receiveTimeout: const Duration(milliseconds: 60000), // زيادة إلى 60 ثانية
      sendTimeout: const Duration(milliseconds: 60000), // زيادة إلى 60 ثانية
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    ),
  );

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? query, String? token}) async {
    // --- هنا هو التحسين المطلوب ---
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      final response = await _dio.get(endpoint, queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      // Graceful 404 handling for public browsing endpoints
      final status = e.response?.statusCode;
      if (status == 404) {
        final ep = endpoint.toLowerCase();
        // Heuristics: most browse endpoints return list or {data: []}
        // Return empty list for ads/offer/list endpoints to avoid UI crashes
        final looksLikeListEndpoint = ep.contains('ads') || ep.contains('offers-box') || ep.contains('best-advertisers') || ep.contains('models') || ep.contains('specs') || ep.contains('options');
        if (looksLikeListEndpoint) {
          return [];
        }
        // Otherwise, return empty map as a generic fallback
        return <String, dynamic>{};
      }
      throw ErrorHandler.handleDioError(e);
    }
  }
  
  Future<dynamic> post(String endpoint, {required dynamic data, Map<String, dynamic>? query, String? token}) async {
    // --- وهنا أيضًا ---
     if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      print('=== API SERVICE POST ===');
      print('URL: $baseUrl$endpoint');
      print('Data: $data');
      print('Query: $query');
      print('Headers: ${_dio.options.headers}');
      print('=======================');

      final response = await _dio.post(endpoint, data: data, queryParameters: query);
      
      print('=== API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('==================');
      
      return response.data;
    } on DioException catch (e) {
      print('=== API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
      print('================');
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<dynamic> postFormData(
    String endpoint, {
    required Map<String, dynamic> data,
    File? mainImage,
    List<File>? thumbnailImages,
    String? token,
  }) async {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    // تغيير نوع المحتوى للطلبات التي تحتوي على ملفات
    _dio.options.headers['Content-Type'] = 'multipart/form-data';

    // استخدام FormData من Dio لتجميع البيانات النصية والملفات
    final formData = FormData.fromMap(data);

    // إضافة الصورة الرئيسية إذا كانت موجودة
    if (mainImage != null) {
      formData.files.add(MapEntry(
        'main_image',
        await MultipartFile.fromFile(mainImage.path),
      ));
    }
    
    // إضافة الصور المصغرة إذا كانت موجودة
    if (thumbnailImages != null && thumbnailImages.isNotEmpty) {
      for (var file in thumbnailImages) {
        formData.files.add(MapEntry(
          'thumbnail_images[]', // الاسم مهم جدًا ليعتبره الباك اند كمصفوفة
          await MultipartFile.fromFile(file.path),
        ));
      }
    }

    try {
      print('=== API REQUEST DEBUG ===');
      print('Endpoint: $endpoint');
      print('FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}');
      print('FormData files: ${formData.files.map((e) => e.key).join(', ')}');
      print('========================');
      
      final response = await _dio.post(endpoint, data: formData);
      
      print('=== API RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('=========================');
      
      return response.data;
    } on DioException catch (e) {
      print('=== API ERROR DEBUG ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('======================');
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<dynamic> put(String endpoint, {required dynamic data, Map<String, dynamic>? query, String? token}) async {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      print('=== API SERVICE PUT ===');
      print('URL: $baseUrl$endpoint');
      print('Data: $data');
      print('Query: $query');
      print('Headers: ${_dio.options.headers}');
      print('=======================');

      final response = await _dio.put(endpoint, data: data, queryParameters: query);
      
      print('=== API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('==================');
      
      return response.data;
    } on DioException catch (e) {
      print('=== API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
      print('================');
      throw ErrorHandler.handleDioError(e);
    }
  }

Future<dynamic> putFormData(
  String endpoint, {
  required Map<String, dynamic> data,
  File? mainImage,
  List<File>? thumbnailImages,
  String? token,
}) async {
  if (token != null) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  _dio.options.headers['Content-Type'] = 'multipart/form-data';

  // لإخبار الـ Backend بأن هذا الطلب هو PUT
  final Map<String, dynamic> finalData = {...data, '_method': 'PUT'};

  final formData = FormData.fromMap(finalData);

  if (mainImage != null) {
    formData.files.add(MapEntry(
      'main_image',
      await MultipartFile.fromFile(mainImage.path),
    ));
  }
  
  if (thumbnailImages != null && thumbnailImages.isNotEmpty) {
    for (var file in thumbnailImages) {
      formData.files.add(MapEntry(
        'thumbnail_images[]',
        await MultipartFile.fromFile(file.path),
      ));
    }
  }

  try {
    // نستخدم post ولكن الـ backend سيعتبره PUT بسبب حقل _method
    final response = await _dio.post(endpoint, data: formData);
    return response.data;
  } on DioException catch (e) {
    throw ErrorHandler.handleDioError(e);
  }
}

  Future<dynamic> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    String? token,
  }) async {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    _dio.options.headers['Content-Type'] = 'multipart/form-data';

    final formData = FormData();
    formData.files.add(MapEntry(
      fieldName,
      await MultipartFile.fromFile(filePath),
    ));

    try {
      final response = await _dio.post(endpoint, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

}