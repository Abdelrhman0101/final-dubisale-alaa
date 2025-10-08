// في ملف: data/model/best_advertiser_model.dart

class BestAdvertiserAd {
  final int id;
  final String make;
  final String model;
  final String? trim;
  final String year;
  final String km;
  final String price;
  final String mainImage;
  final String advertiserName;
  // Car service specific fields
  final String? serviceType;
  final String? serviceName;
  final String? district;
  // Car rent specific fields
  final String? dayRent;
  final String? monthRent;
  // Restaurant specific fields
  final String? title;
  final String? priceRange;
  final String? emirate;
  final String? area;
  final List<String> images;
  final String? category;
  final String? propertyType;
  final String? contractType;
  final String? salary;
  final String? job_name;
  
  BestAdvertiserAd(
    this.propertyType,
    this.contractType,
    this.salary, this.job_name, {
    required this.id,
    required this.make,
    required this.model,
    this.trim,
    required this.year,
    required this.km,
    required this.price,
    required this.mainImage,
    required this.advertiserName,
    this.serviceType,
    this.serviceName,
    this.district,
    this.dayRent,
    this.monthRent,
    this.title,
    this.priceRange,
    this.emirate,
    this.area,
    this.images = const [],
    this.category,
  });

  // Factory constructor that needs additional data (advertiser ID and name)
  factory BestAdvertiserAd.fromJson(Map<String, dynamic> json,
      {required int advertiserId, required String advertiserName}) {
    // Parse images list
    List<String> imagesList = [];
    if (json['images'] is List) {
      imagesList =
          (json['images'] as List).map((img) => img.toString()).toList();
    } else if (json['main_image'] != null) {
      imagesList = [json['main_image'].toString()];
    }

    // Handle main_image_url for car rent - ensure we use the correct field and clean malformed URLs
    String mainImageUrl = '';
    if (json['main_image_url'] != null &&
        json['main_image_url'].toString().isNotEmpty) {
      String rawUrl = json['main_image_url'].toString().trim();

      // Clean malformed URLs that contain embedded full URLs with backticks and extra characters
      // Example: "/storage/ `https://dubaisale.app/storage/car_rent/main/file.jpg` "
      if (rawUrl.contains('`') && rawUrl.contains('https://')) {
        // Extract the full URL from between backticks
        RegExp regExp = RegExp(r'`(https://[^`]+)`');
        Match? match = regExp.firstMatch(rawUrl);
        if (match != null) {
          mainImageUrl = match.group(1)!.trim();
        } else {
          // Fallback: try to extract any https URL
          RegExp httpsRegExp = RegExp(r'https://[^\s`]+');
          Match? httpsMatch = httpsRegExp.firstMatch(rawUrl);
          if (httpsMatch != null) {
            mainImageUrl = httpsMatch.group(0)!.trim();
          } else {
            mainImageUrl = rawUrl;
          }
        }
      } else {
        mainImageUrl = rawUrl;
      }
    } else if (json['main_image'] != null &&
        json['main_image'].toString().isNotEmpty) {
      mainImageUrl = json['main_image'].toString().trim();
    }

    return BestAdvertiserAd(
      json['property_type']?.toString() ?? '',
      json['contract_type']?.toString() ?? '',
      json['salary']?.toString() ?? '',
      json['job_name']?.toString() ?? '',
      id: json['id'] ?? advertiserId,
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      trim: json['trim']?.toString(),
      year: json['year']?.toString() ?? 'N/A',
      km: json['km']?.toString() ?? 'N/A',
      price: json['price']?.toString() ?? '0',
      mainImage: mainImageUrl,
      advertiserName: advertiserName,
      serviceType: json['service_type']?.toString(),
      serviceName: json['service_name']?.toString(),
      district: json['district']?.toString(),
      dayRent: json['day_rent']?.toString(),
      monthRent: json['month_rent']?.toString(),
      title: json['title']?.toString() ?? json['name']?.toString(),
      priceRange: json['price_range']?.toString() ?? json['price']?.toString(),
      emirate: json['emirate']?.toString(),
      area: json['area']?.toString(),
      images: imagesList,
      category: json['category']?.toString(),
    );
  }
}

class BestAdvertiser {
  final int id;
  final String name;
  final List<BestAdvertiserAd> ads;

  BestAdvertiser({
    required this.id,
    required this.name,
    required this.ads,
  });

  factory BestAdvertiser.fromJson(Map<String, dynamic> json,
      {String? filterByCategory}) {
    String advertiserName = json['advertiser_name']?.toString() ??
        'Top Dealer'; // Use a default name if null
    int advertiserId = json['id'] ?? 0;
    List<BestAdvertiserAd> parsedAds = [];

    // التعامل مع الهيكل الجديد للـ API response
    // الهيكل الجديد: { "id": 33, "advertiser_name": null, "category": "car_sales", "latest_ads": [...] }

    if (json['latest_ads'] is List) {
      // الهيكل الجديد - الإعلانات موجودة مباشرة في latest_ads
      String categoryName = json['category']?.toString() ?? '';
      parsedAds = (json['latest_ads'] as List).map((adJson) {
        // إضافة الفئة إلى بيانات الإعلان
        Map<String, dynamic> adWithCategory = Map<String, dynamic>.from(adJson);
        adWithCategory['category'] = categoryName;
        return BestAdvertiserAd.fromJson(adWithCategory,
            advertiserId: advertiserId, advertiserName: advertiserName);
      }).toList();
    } else if (json['featured_in'] is List &&
        (json['featured_in'] as List).isNotEmpty) {
      // الهيكل القديم - للتوافق مع النسخة السابقة
      // إذا تم تحديد category للفلترة، نبحث عن الـ category المطلوب
      if (filterByCategory != null) {
        final featuredList = json['featured_in'] as List;
        final matchingCategory = featuredList.firstWhere(
          (item) => item['category'] == filterByCategory,
          orElse: () => null,
        );

        if (matchingCategory != null &&
            matchingCategory['latest_ads'] is List) {
          String categoryName = matchingCategory['category']?.toString() ?? '';
          parsedAds = (matchingCategory['latest_ads'] as List).map((adJson) {
            // إضافة الفئة إلى بيانات الإعلان
            Map<String, dynamic> adWithCategory =
                Map<String, dynamic>.from(adJson);
            adWithCategory['category'] = categoryName;
            return BestAdvertiserAd.fromJson(adWithCategory,
                advertiserId: advertiserId, advertiserName: advertiserName);
          }).toList();
        }
      } else {
        // إذا لم يتم تحديد category، نأخذ جميع الإعلانات من جميع الفئات
        final featuredList = json['featured_in'] as List;
        for (var featuredData in featuredList) {
          if (featuredData['latest_ads'] is List) {
            String categoryName = featuredData['category']?.toString() ?? '';
            List<BestAdvertiserAd> categoryAds =
                (featuredData['latest_ads'] as List).map((adJson) {
              // إضافة الفئة إلى بيانات الإعلان
              Map<String, dynamic> adWithCategory =
                  Map<String, dynamic>.from(adJson);
              adWithCategory['category'] = categoryName;
              return BestAdvertiserAd.fromJson(adWithCategory,
                  advertiserId: advertiserId, advertiserName: advertiserName);
            }).toList();
            parsedAds.addAll(categoryAds);
          }
        }
      }
    }

    return BestAdvertiser(
      id: advertiserId,
      name: advertiserName,
      ads: parsedAds,
    );
  }
}
