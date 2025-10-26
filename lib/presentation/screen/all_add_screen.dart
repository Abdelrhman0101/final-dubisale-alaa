import 'package:advertising_app/data/model/favorite_item_interface_model.dart';
import 'package:advertising_app/data/model/user_ad_adapters.dart';
import 'package:advertising_app/data/model/user_ads_model.dart';
import 'package:advertising_app/data/repository/user_ads_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/presentation/screen/all_ad_adapter.dart';
import 'package:advertising_app/presentation/widget/custom_category.dart';
import 'package:advertising_app/presentation/widget/custom_search_card.dart';
import 'package:advertising_app/presentation/widget/custom_search2_card.dart';
import 'package:advertising_app/presentation/widget/custome_search_job.dart';
import 'package:advertising_app/utils/phone_number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const Color KPrimaryColor = Color.fromRGBO(1, 84, 126, 1);

class AllAddScreen extends StatefulWidget {
  final String? advertiserId;

  const AllAddScreen({super.key, this.advertiserId});

  @override
  State<AllAddScreen> createState() => _AllAddScreenState();
}

class _AllAddScreenState extends State<AllAddScreen> {
  int selectedCategory = 0;
  bool isLoading = true;
  String? errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final UserAdsRepository _userAdsRepository;

  // قوائم البيانات لكل تصنيف
  final List<List<FavoriteItemInterface>> allData = [
    [], // car sales - index 0
    [], // real estate - index 1
    [], // electronics - index 2
    [], // jobs - index 3
    [], // car rent - index 4
    [], // car services - index 5
    [], // restaurants - index 6
    [], // other services - index 7
  ];

  @override
  void initState() {
    super.initState();
    _userAdsRepository = UserAdsRepository(ApiService());
    _loadUserAdsData();
  }

  Future<void> _loadUserAdsData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // الحصول على معرف المستخدم المعلن
      final advertiserId = await _getAdvertiserId();
      if (advertiserId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'لم يتم العثور على معرف المستخدم';
        });
        return;
      }

      // طباعة الـ endpoint مع الـ userId الفعلي في الترمنال
      debugPrint('Endpoint used: /api/user-ads/$advertiserId');

      // جلب إعلانات المستخدم من API
      final userAdsResponse = await _userAdsRepository.getUserAds(advertiserId);

      // تصنيف الإعلانات حسب الفئات
      final categorizedAds = _categorizeAds(userAdsResponse.ads);

      setState(() {
        allData[0] = categorizedAds['car_sales'] ?? [];
        allData[1] = categorizedAds['real_estate'] ?? [];
        allData[2] = categorizedAds['electronics'] ?? [];
        allData[3] = categorizedAds['jobs'] ?? [];
        allData[4] = categorizedAds['car_rent'] ?? [];
        allData[5] = categorizedAds['car_services'] ?? [];
        allData[6] = categorizedAds['restaurant'] ?? [];
        allData[7] = categorizedAds['other_services'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ أثناء تحميل البيانات: ${e.toString()}';
      });
      debugPrint('Error loading user ads: $e');
    }
  }

  Future<String?> _getAdvertiserId() async {
    // استخدام معرف المعلن من widget parameter إذا كان متاحًا
    if (widget.advertiserId != null) {
      // التحقق من أن معرف المعلن ليس '0' قبل استخدامه
      if (widget.advertiserId != '0') {
        debugPrint(
            'Using valid advertiser ID from widget parameter: ${widget.advertiserId}');
        return widget.advertiserId;
      } else {
        debugPrint('Received invalid advertiser ID (0) from widget parameter');
        // في حالة استلام معرف '0'، نستخدم معرف المستخدم من التخزين
      }
    }

    // استخدام معرف المستخدم من الـ storage كخيار أخير
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId != null && userId.isNotEmpty) {
        debugPrint('Using user ID from storage: $userId');
        return userId;
      }
    } catch (e) {
      debugPrint('Error getting user ID from storage: $e');
    }

    // إذا لم يتم العثور على معرف المستخدم، استخدم قيمة افتراضية
    debugPrint('Warning: No user ID found in storage, using fallback value');
    return '0';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkRouteParameters();
  }

  void _checkRouteParameters() {
    try {
      // استخدام معرف المعلن من الـ route parameter
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is String && routeArgs.isNotEmpty) {
        debugPrint('Using advertiser ID from route arguments: $routeArgs');
        // إعادة تحميل البيانات باستخدام معرف المعلن من الـ route
        _loadUserAdsData();
      }
    } catch (e) {
      debugPrint('Error checking route parameters: $e');
    }
  }

  Map<String, List<FavoriteItemInterface>> _categorizeAds(List<UserAd> ads) {
    final Map<String, List<FavoriteItemInterface>> categorizedAds = {
      'car_sales': [],
      'real_estate': [],
      'electronics': [],
      'jobs': [],
      'car_rent': [],
      'car_services': [],
      'restaurant': [],
      'other_services': [],
    };

    for (final ad in ads) {
      final category = ad.addCategory.toLowerCase();
      // طباعة القيمة الفعلية للفئة للتشخيص
      debugPrint(
          'Processing ad category: "$category" - Raw value: "${ad.addCategory}"');

      // استخدام المحولات المخصصة لكل فئة
      FavoriteItemInterface adapter;

      // تحسين التعرف على فئة السيارات
      if (category.contains('car') &&
          (category.contains('sale') || category.contains('sales'))) {
        adapter = CarSalesAdAdapter(ad);
        categorizedAds['car_sales']!.add(adapter);
        debugPrint('Added to car_sales with CarSalesAdAdapter');
      }
      // تحسين التعرف على فئة العقارات
      else if (category.contains('real') ||
          category.contains('estate') ||
          category.contains('property') ||
          category.contains('عقار')) {
        adapter = RealEstateAdAdapter(ad);
        categorizedAds['real_estate']!.add(adapter);
        debugPrint('Added to real_estate with RealEstateAdAdapter');
      } else if (category.contains('electronic')) {
        adapter = ElectronicsAdAdapter(ad);
        categorizedAds['electronics']!.add(adapter);
        debugPrint('Added to electronics with ElectronicsAdAdapter');
      }
      // تحسين التعرف على فئة الوظائف - إضافة دعم لصيغة "Jop"
      else if (category == 'jobs' ||
          category == 'job' ||
          category == 'jop' ||
          category == 'وظائف' ||
          category == 'وظيفة' ||
          category.contains('job') ||
          category.contains('jop') ||
          category.contains('وظيفة') ||
          category.contains('وظائف') ||
          category.contains('career') ||
          category.contains('employment') ||
          ad.addCategory == 'Jobs' ||
          ad.addCategory == 'JOB' ||
          ad.addCategory == 'JOBS' ||
          ad.addCategory == 'Jop') {
        adapter = JobAdAdapter(ad);
        categorizedAds['jobs']!.add(adapter);
        debugPrint(
            'Added to jobs with JobAdAdapter - Match condition: ${ad.addCategory}');
      } else if ((category.contains('car') || category.contains('auto')) &&
          category.contains('rent')) {
        adapter = CarRentAdAdapter(ad);
        categorizedAds['car_rent']!.add(adapter);
        debugPrint('Added to car_rent with CarRentAdAdapter');
      } else if ((category.contains('car') || category.contains('auto')) &&
          category.contains('service')) {
        adapter = CarServiceAdAdapter(ad);
        categorizedAds['car_services']!.add(adapter);
        debugPrint('Added to car_services with CarServiceAdAdapter');
      } else if (category.contains('restaurant') || category.contains('food')) {
        adapter = RestaurantAdAdapter(ad);
        categorizedAds['restaurant']!.add(adapter);
        debugPrint('Added to restaurant with RestaurantAdAdapter');
      } else {
        adapter = OtherServiceAdAdapter(ad);
        categorizedAds['other_services']!.add(adapter);
        debugPrint('Added to other_services with OtherServiceAdAdapter');
      }
    }

    // طباعة عدد الإعلانات في كل فئة للتشخيص
    categorizedAds.forEach((key, value) {
      debugPrint('Category $key has ${value.length} ads');
    });

    return categorizedAds;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    // قائمة التصنيفات النصية
    final List<String> categories = [
      S.of(context).carsales, // index 0
      S.of(context).realestate, // index 1
      S.of(context).electronics, // index 2
      S.of(context).jobs, // index 3
      S.of(context).carrent, // index 4
      S.of(context).carservices, // index 5
      S.of(context).restaurants, // index 6
      S.of(context).otherservices // index 7
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(height: 60),
            Text(
              S.of(context).favorites,
              style: TextStyle(
                color: Color(0xFF001E5B),
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 10),
            // شريط التصنيفات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CustomCategoryGrid(
                categories: categories,
                selectedIndex: selectedCategory,
                onTap: (index) {
                  setState(() {
                    selectedCategory = index;
                  });
                },
              ),
            ),
            // محتوى الشاشة الرئيسي
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserAdsData,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // اختيار قائمة البيانات الصحيحة بناءً على التصنيف المحدد
    final selectedItems =
        allData.isNotEmpty && selectedCategory < allData.length
            ? allData[selectedCategory]
            : <FavoriteItemInterface>[];

    // إذا كانت القائمة فارغة، عرض رسالة
    if (selectedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد إعلانات في هذا القسم',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      itemCount: selectedItems.length,
      cacheExtent: 500.0,
      itemBuilder: (context, index) {
        final item = selectedItems[index];
        return _buildCategorySpecificCard(item, index);
      },
    );
  }

  Widget _buildCategorySpecificCard(FavoriteItemInterface item, int index) {
    switch (selectedCategory) {
      case 0: // car_sales
        return _buildCarSalesCard(item, index);
      case 4: // car_rent
        return _buildCarRentCard(item, index);
      case 5: // car_service
        return _buildCarServiceCard(item, index);
      case 1: // real_estate
        return _buildRealEstateCard(item, index);
      case 2: // electronics
        return _buildElectronicsCard(item, index);
      case 3: // jobs
        return _buildJobCard(item, index);
      case 6: // restaurants
        return _buildRestaurantCard(item, index);
      case 7: // other_services
        return _buildOtherServiceCard(item, index);
      default:
        return _buildGenericCard(item, index);
    }
  }

  Widget _buildCarSalesCard(FavoriteItemInterface item, int index) {
    return SearchCard(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      showLine1: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildCarRentCard(FavoriteItemInterface item, int index) {
    return SearchCard(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      showLine1: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildCarServiceCard(FavoriteItemInterface item, int index) {
    return SearchCard(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      showLine1: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildRealEstateCard(FavoriteItemInterface item, int index) {
    return SearchCard(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      showLine1: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildElectronicsCard(FavoriteItemInterface item, int index) {
    return SearchCard2(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildJobCard(FavoriteItemInterface item, int index) {
    return SearchCardJob(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildRestaurantCard(FavoriteItemInterface item, int index) {
    return SearchCard(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      showLine1: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildOtherServiceCard(FavoriteItemInterface item, int index) {
    return SearchCard(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      showLine1: true,
      customActionButtons: _buildActionButtons(item),
    );
  }

  Widget _buildGenericCard(FavoriteItemInterface item, int index) {
    return SearchCard(
      item: item,
      onDelete: () {
        setState(() {
          allData[selectedCategory].removeAt(index);
        });
      },
      showDelete: true,
      showLine1: true,
    );
  }

  List<Widget> _buildActionButtons(FavoriteItemInterface item) {
    return [
      _buildWhatsAppButton(item),
      SizedBox(width: 8.w),
      _buildCallButton(item),
    ];
  }

  Widget _buildWhatsAppButton(FavoriteItemInterface item) {
    return Container(
      width: 40.w,
      height: 40.h,
       decoration: BoxDecoration(color: const Color(0xFF01547E), borderRadius: BorderRadius.circular(8)),
     
      child: IconButton(
        onPressed: () => _launchWhatsApp(item.contact),
        icon: FaIcon(
          FontAwesomeIcons.whatsapp,
          color: Colors.white,
          size: 20.sp,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCallButton(FavoriteItemInterface item) {
    return Container(
      width: 40.w,
      height: 40.h,
       decoration: BoxDecoration(color: const Color(0xFF01547E), borderRadius: BorderRadius.circular(8)),
      
      child: IconButton(
        onPressed: () => _makePhoneCall(item.contact),
        icon: Icon(
          Icons.call,
          color: Colors.white,
          size: 20.sp,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _launchWhatsApp(String phoneNumber) async {
    final url = PhoneNumberFormatter.getWhatsAppUrl(phoneNumber);

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = PhoneNumberFormatter.getTelUrl(phoneNumber);

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
