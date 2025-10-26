import 'package:advertising_app/data/model/user_model.dart';
import 'package:advertising_app/data/web_services/api_service.dart';

class AuthRepository {
  // 1. هنا نستخدم Composition: الـ AuthRepository "يمتلك" ApiService
  final ApiService _apiService;

  // 2. نقوم بحقن (Inject) الـ ApiService من خلال الـ constructor
  // ده بيخلي الكود قابل للاختبار بسهولة
  AuthRepository(this._apiService);

  // 3. دالة تسجيل الدخول الجديدة: تستخدم endpoint جديد مع phone فقط
   Future<Map<String, dynamic>> login({
    required String phone, // يستقبل رقم الهاتف فقط
  }) async {
    final Map<String, dynamic> loginData = {
      'phone': phone,
    };
    
    // استخدام الـ endpoint الجديد
    final response = await _apiService.post('/api/newSignin', data: loginData);

    if (response is Map<String, dynamic> && response.containsKey('user')) {
      return response;
    } else {
      throw Exception('Login response is not valid or user data is missing.');
    }
  }

  // دالة تسجيل الدخول للمعلنين مع كلمة المرور
  Future<Map<String, dynamic>> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    final Map<String, dynamic> loginData = {
      'phone': phone,
      'password': password,
    };
    
    // استخدام نفس الـ endpoint مع إرسال كلمة المرور
    final response = await _apiService.post('/api/newSignin', data: loginData);

    if (response is Map<String, dynamic> && response.containsKey('user') && response.containsKey('token')) {
      return response;
    } else {
      throw Exception('Advertiser login response is not valid or token is missing.');
    }
  }

  
  
  // 4. دالة إنشاء حساب جديد - تم إزالتها لأنها لم تعد مطلوبة في النظام الجديد

    // Future<void> signUp({
    //   required String username,
    //   required String email,
    //   required String password,
    //   required String phone,
    //   required String whatsapp,
    //   required String role,
    // }) async {
    //    final Map<String, dynamic> signUpData = {
    //     'username': username,
    //     'email': email,
    //     'password': password,
    //     'phone': phone,
    //     'whatsapp': whatsapp,
    //     'role': role,
    //    };
    //   
    //   await _apiService.post('/api/signup', data: signUpData);
    // }

   Future<void> logout({required String token}) async {
    // استدعاء endpoint تسجيل الخروج باستخدام POST وإرسال التوكن في الـ Header
    // ApiService سيقوم بإضافة "Bearer " تلقائيًا
    await _apiService.post(
      '/api/logout',
      data: {}, // غالبًا ما يكون الـ Body فارغًا
      token: token,
    );
  }

  
   Future<UserModel> getUserProfile({ String? token}) async {
    // استخدمنا GET لأننا نجلب بيانات
    final response = await _apiService.get('/api/user', token: token);
    
    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    throw Exception('Failed to parse user profile.');
  }


  Future<UserModel> updateProfile({
    required String token,
    required String username,
    required String email,
    required String phone,
    String? whatsapp,
    String? advertiserName,
    String? advertiserType,
    String? advertiserLogo,
    double? latitude,
    double? longitude,
    String? address,
    String? advertiserLocation,
  }) async {
    // نبني الـ payload بشكل مرن ونستبعد الحقول الفارغة
    final Map<String, dynamic> data = {};

    // حقول نصية: تضمين فقط إذا كانت غير فارغة
    if (username.trim().isNotEmpty) data['username'] = username.trim();
    if (email.trim().isNotEmpty) data['email'] = email.trim();
    if (phone.trim().isNotEmpty) data['phone'] = phone.trim();
    if (whatsapp != null && whatsapp.trim().isNotEmpty) {
      data['whatsapp'] = whatsapp.trim();
    }
    if (advertiserName != null && advertiserName.trim().isNotEmpty) {
      data['advertiser_name'] = advertiserName.trim();
    }
    if (advertiserType != null && advertiserType.trim().isNotEmpty) {
      data['advertiser_type'] = advertiserType.trim();
    }
    if (advertiserLogo != null && advertiserLogo.trim().isNotEmpty) {
      data['advertiser_logo'] = advertiserLogo.trim();
    }

    // حقول الموقع: تضمين فقط إذا كانت غير null
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (address != null && address.trim().isNotEmpty) {
      data['address'] = address.trim();
    }
    if (advertiserLocation != null && advertiserLocation.trim().isNotEmpty) {
      data['advertiser_location'] = advertiserLocation.trim();
    }

    final response = await _apiService.post(
      '/api/profile',
      data: data,
      token: token
    );

    // الـ API يرجع بيانات المستخدم المحدثة
    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    throw Exception('Failed to parse updated user profile.');
  }

  Future<UserModel> updateProfileWithUserId({
    required String userId,
    required String username,
    required String email,
    required String phone,
    String? whatsapp,
    String? advertiserName,
    String? advertiserType,
    String? advertiserLogo,
    double? latitude,
    double? longitude,
    String? address,
    String? advertiserLocation,
  }) async {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'whatsapp': whatsapp,
      'advertiser_name': advertiserName,
      'advertiser_type': advertiserType,
      'advertiser_logo': advertiserLogo,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
    
    // إضافة advertiser_location إذا كان متوفراً
    if (advertiserLocation != null) {
      data['advertiser_location'] = advertiserLocation;
    }

    final response = await _apiService.post(
      '/api/profile/update-by-id',
      data: data
    );

    // الـ API يرجع بيانات المستخدم المحدثة
    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    throw Exception('Failed to parse updated user profile.');
  }

  Future<UserModel> uploadLogo({
    required String token,
    required String logoPath,
  }) async {
    final response = await _apiService.uploadFile(
      '/api/profile',
      filePath: logoPath,
      fieldName: 'advertiser_logo',
      token: token,
    );

    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    throw Exception('Failed to upload logo.');
  }

  Future<UserModel> deleteLogo({
    required String token,
  }) async {
    final response = await _apiService.post(
      '/api/profile',
      data: {
        'advertiser_logo': null,
      },
      token: token,
    );

    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    throw Exception('Failed to delete logo.');
  }
  
  // --- الدالة الجديدة لتحديث كلمة المرور ---
  Future<void> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final Map<String, dynamic> data = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    };
    
    await _apiService.post(
      '/api/profile/password',
      data: data,
      token: token,
    );
  }

  // دالة تحويل المستخدم إلى معلن - POST /api/convert-to-advertiser/{user_id}
  // Future<void> convertToAdvertiser({required int userId}) async {
  //   await _apiService.post('/api/convert-to-advertiser/$userId', data: {});
  // }

  // // دالة التحقق من OTP - PUT /api/verify
  // Future<Map<String, dynamic>> verifyOTP({
  //   required String phone,
  //   required String otp,
  // }) async {
  //   final Map<String, dynamic> data = {
  //     'phone': phone,
  //     'otp': otp,
  //   };
    
  //   final response = await _apiService.put('/api/verify', data: data);
    
  //   if (response is Map<String, dynamic>) {
  //     return response;
  //   }
  //   throw Exception('Failed to verify OTP.');
  // }

}