import 'dart:math';
import 'package:advertising_app/presentation/widget/custom_bottom_nav.dart';
import 'package:advertising_app/presentation/widget/custom_category.dart';
import 'package:advertising_app/presentation/widget/unified_dropdown.dart';
import 'package:advertising_app/utils/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:advertising_app/presentation/providers/electronics_info_provider.dart';
import 'package:advertising_app/data/model/best_electronics_advertiser_model.dart';
import 'package:advertising_app/constant/image_url_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

// تعريف الثوابت المستخدمة في الألوان
const Color KTextColor = Color.fromRGBO(0, 30, 91, 1);
const Color KPrimaryColor =
    Color.fromRGBO(1, 84, 126, 1); // اللون الأساسي الموحد
final Color borderColor = Color.fromRGBO(8, 194, 201, 1);

class ElectronicScreen extends StatefulWidget {
  const ElectronicScreen({super.key});

  @override
  State<ElectronicScreen> createState() => _ElectronicScreenState();
}

class _ElectronicScreenState extends State<ElectronicScreen> {
  int _selectedIndex = 2;

  // ++ تحويل المتغيرات لاختيار فردي بدل متعدد ++
  String? _selectedEmirate;
  String? _selectedSectionType;

  List<String> get categories => [
        S.of(context).carsales,
        S.of(context).realestate,
        S.of(context).electronics,
        S.of(context).jobs,
        S.of(context).carrent,
        S.of(context).carservices,
        S.of(context).restaurants,
        S.of(context).otherservices,
      ];

  Map<String, String> get categoryRoutes => {
        S.of(context).carsales: "/home",
        S.of(context).realestate: "/realEstate",
        S.of(context).electronics: "/electronics",
        S.of(context).jobs: "/jobs",
        S.of(context).carrent: "/car_rent",
        S.of(context).carservices: "/carServices",
        S.of(context).restaurants: "/restaurants",
        S.of(context).otherservices: "/otherServices",
      };

  @override
  void initState() {
    super.initState();
    // اجلب بيانات الإمارات، أنواع الأقسام، وأفضل المعلنين عند فتح الشاشة
    Future.microtask(() {
      final provider =
          Provider.of<ElectronicsInfoProvider>(context, listen: false);
      provider.fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final s = S.of(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: CustomBottomNav(currentIndex: 0),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 35.h,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: s.smart_search,
                              hintStyle: TextStyle(
                                  color: const Color.fromRGBO(129, 126, 126, 1),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500),
                              prefixIcon: Icon(Icons.search,
                                  color: borderColor, size: 25.sp),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                      color: borderColor, width: 1.5)),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 0.h),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_none,
                            color: borderColor, size: 35.sp),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w),
                  child: CustomCategoryGrid(
                    categories: categories,
                    selectedIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    onCategoryPressed: (selectedCategory) {
                      final route = categoryRoutes[selectedCategory];
                      if (route != null) {
                        context.push(route);
                      } else {
                        print('Route not found for $selectedCategory');
                      }
                    },
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                  child: Consumer<ElectronicsInfoProvider>(
                    builder: (context, electronicsInfo, _) {
                      // احصل على القوائم الحقيقية من الـ Repository عبر الـ Provider وأضف خيار "All"
                      final emirateItems = [
                        'All',
                        ...electronicsInfo.emirateDisplayNames,
                      ];
                      final sectionTypeItems = [
                        'All',
                        ...electronicsInfo.sectionTypes,
                      ];
                      return Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber, size: 20.sp),
                              SizedBox(width: 6.w),
                              Text(
                                s.discover_elect,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: KTextColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          UnifiedDropdown<String>(
                            title: s.emirate,
                            selectedValue: _selectedEmirate,
                            items: emirateItems.isNotEmpty
                                ? emirateItems
                                : const <String>[],
                            onConfirm: (selection) =>
                                setState(() => _selectedEmirate = selection),
                          ),
                          SizedBox(height: 3.h),
                          UnifiedDropdown<String>(
                            title: s.section_type,
                            selectedValue: _selectedSectionType,
                            items: sectionTypeItems.isNotEmpty
                                ? sectionTypeItems
                                : const <String>[],
                            onConfirm: (selection) => setState(
                                () => _selectedSectionType = selection),
                          ),
                          SizedBox(height: 4.h),
                          UnifiedSearchButton(
                            onPressed: () {
                              // تحقق من صحة الإدخال: يجب اختيار الإمارة ونوع القسم قبل الانتقال
                              if ((_selectedEmirate == null ||
                                      _selectedEmirate!.isEmpty) ||
                                  (_selectedSectionType == null ||
                                      _selectedSectionType!.isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'يرجى اختيار الإمارة ونوع القسم أولاً'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              // حضّر الفلاتر للإرسال إلى صفحة البحث
                              final Map<String, String> filters = {};
                              if (_selectedEmirate != null &&
                                  _selectedEmirate != 'All') {
                                filters['emirate'] = _selectedEmirate!;
                              }
                              if (_selectedSectionType != null &&
                                  _selectedSectionType != 'All') {
                                filters['section_type'] = _selectedSectionType!;
                              }

                              context.push('/electronic_search',
                                  extra: filters);
                            },
                          ),
                          SizedBox(height: 7.h),
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 8.w),
                            child: GestureDetector(
                              onTap: () => context.push('/electronicofferbox'),
                              child: Container(
                                padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: 8.w),
                                height: 68.h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE4F8F6),
                                      Color(0xFFC9F8FE)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.click_for_deals_elect,
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: KTextColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 22.sp, color: KTextColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              SizedBox(width: 4.w),
                              Icon(Icons.star,
                                  color: Colors.amber, size: 20.sp),
                              SizedBox(width: 4.w),
                              Text(s.top_premium_dealers,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      color: KTextColor)),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          if (electronicsInfo.isLoading)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Center(
                                  child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: KPrimaryColor,
                                          strokeWidth: 2))),
                            )
                          else if (electronicsInfo.error != null)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Text(electronicsInfo.error!,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12.sp)),
                            )
                          else
                            Column(
                              children: electronicsInfo.bestAdvertisers
                                  .map((BestElectronicsAdvertiser advertiser) {
                                final ads = advertiser.latestAds;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 8.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(advertiser.advertiserName,
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: KTextColor)),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              // استخدام معرف المعلن مباشرة بدون تحويله إلى نص
                                              final advertiserId = advertiser.id;
                                              // التأكد من أن معرف المعلن ليس صفر
                                              if (advertiserId == 0) {
                                                debugPrint(
                                                    'WARNING: Invalid advertiser ID: $advertiserId');
                                                // عرض رسالة للمستخدم
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('لا يمكن عرض إعلانات هذا المعلن'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                                return; // منع الانتقال إذا كان المعرف صفر
                                              }
                                              debugPrint(
                                                  'Navigating to all ads with advertiser ID: $advertiserId');
                                              context.push(
                                                  '/all_ad_car_sales/$advertiserId');
                                            },
                                            child: Text(
                                              s.see_all_ads,
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: borderColor,
                                                  color: borderColor,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 175,
                                      width: double.infinity,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: min(ads.length, 20),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.w),
                                        itemBuilder: (context, index) {
                                          final ad = ads[index];
                                          final imageUrl =
                                              ad.mainImageUrl.isNotEmpty
                                                  ? ad.mainImageUrl
                                                  : '';
                                          final priceText =
                                              (ad.price).toString();
                                          final titleText =
                                              (ad.productName.isNotEmpty
                                                  ? ad.productName
                                                  : ad.title);
                                          final locationText = [
                                            ad.emirate,
                                            ad.district
                                          ]
                                              .where((p) => p.isNotEmpty)
                                              .join(' ');
                                          return Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                end: index == ads.length - 1
                                                    ? 0
                                                    : 4.w),
                                            child: Container(
                                              width: 145,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.15),
                                                      blurRadius: 5.r,
                                                      offset: Offset(0, 2.h))
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.r),
                                                        child: imageUrl
                                                                .isNotEmpty
                                                            ? CachedNetworkImage(
                                                                imageUrl: ImageUrlHelper
                                                                    .getFullImageUrl(
                                                                        imageUrl),
                                                                height: 94.h,
                                                                width: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        Container(
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  child:
                                                                      const Center(
                                                                    child: CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2),
                                                                  ),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  height: 94.h,
                                                                  width: double
                                                                      .infinity,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  child: Icon(
                                                                      Icons
                                                                          .image_not_supported,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 28
                                                                          .sp),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: 94.h,
                                                                width: double
                                                                    .infinity,
                                                                color: Colors
                                                                    .grey
                                                                    .shade200,
                                                                child: Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    color: Colors
                                                                        .grey,
                                                                    size:
                                                                        28.sp),
                                                              ),
                                                      ),
                                                      Positioned(
                                                          top: 8,
                                                          right: 8,
                                                          child: Icon(
                                                              Icons
                                                                  .favorite_border,
                                                              color: Colors.grey
                                                                  .shade300)),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 6.w),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Text(
                                                              "${NumberFormatter.formatPrice(priceText)}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      11.5.sp)),
                                                          Text(
                                                            titleText,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    11.5.sp,
                                                                color:
                                                                    KTextColor),
                                                          ),
                                                          Text(
                                                            locationText,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    11.5.sp,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                    165,
                                                                    164,
                                                                    162,
                                                                    1),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 16.h),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
