import 'package:advertising_app/constant/string.dart';
import 'package:advertising_app/data/car_sales_data_dummy.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/presentation/screen/car_rent_ads_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

const Color KTextColor = Color.fromRGBO(0, 30, 91, 1);

class AllAdCarSales extends StatefulWidget {
  AllAdCarSales({super.key});

  @override
  State<AllAdCarSales> createState() => _AllAdCarSalesState();
}

class _AllAdCarSalesState extends State<AllAdCarSales> {
  String? selectedYear;
  String? selectedKm;
  String? selectedPrice;

  // --- ✅ (تم التعديل) تم تطبيق نفس هيكل Dropdown الموجود في HomeScreen ---
  Widget _buildFilterChipDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final s = S.of(context);
    const borderColor = Color(0xFF08C2C9); // اللون المحدد للبوردر

    return DropdownSearch<String>(
      filterFn: (item, filter) =>
          item.toLowerCase().contains(filter.toLowerCase()),
      popupProps: PopupProps.menu(
        menuProps: MenuProps(
          backgroundColor: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        itemBuilder: (context, item, isSelected) => Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Text(
            item,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: KTextColor,
            ),
          ),
        ),
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          cursorColor: KPrimaryColor,
          style: TextStyle(
            color: KTextColor,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            hintText: s.search,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: KPrimaryColor, width: 2),
            ),
          ),
        ),
        emptyBuilder: (context, searchEntry) => Center(
          child: Text(
            s.noResultsFound,
            style: TextStyle(fontSize: 14.sp, color: KTextColor),
          ),
        ),
      ),
      items: items,
      selectedItem: value,
      // --- ✅ (تم التعديل) استخدام dropdownDecoratorProps بدلاً من dropdownBuilder ---
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: KTextColor,
          fontSize: 10.5.sp,
        ),
        dropdownSearchDecoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 10.5.sp,
            color: KTextColor,
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: KPrimaryColor, width: 2),
          ),
          // التحكم في الحجم والمحاذاة
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSize = getCardSize(screenWidth);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),

                // Back Button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      Icon(Icons.arrow_back_ios, color: KTextColor, size: 17.sp),
                      Transform.translate(
                        offset: Offset(-3.w, 0),
                        child: Text(
                          S.of(context).back,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: KTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 7.h),

                // Title
                Center(
                  child: Text(
                    "ALL Ads",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: KTextColor,
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // Filter Row
                // Padding(
                //   padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                //   child: IntrinsicHeight(
                //     child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.stretch,
                //       children: [
                //         SvgPicture.asset(
                //           'assets/icons/filter.svg',
                //           width: 25.w,
                //           height: 25.h,
                //         ),
                //         SizedBox(width: 12.w),
                //         Expanded(
                //           child: Row(
                //             children: [
                //               Expanded(
                //                 child: _buildFilterChipDropdown(
                //                   hint: S.of(context).year,
                //                   items: ["2020", "2021", "2022", "2023", "2024"],
                //                   value: selectedYear,
                //                   onChanged: (val) =>
                //                       setState(() => selectedYear = val),
                //                 ),
                //               ),
                //               SizedBox(width: 7.w),
                //               Expanded(
                //                 child: _buildFilterChipDropdown(
                //                   hint: S.of(context).km,
                //                   items: ["0 - 50k", "50k - 100k", "> 100k"],
                //                   value: selectedKm,
                //                   onChanged: (val) =>
                //                       setState(() => selectedKm = val),
                //                 ),
                //               ),
                //               SizedBox(width: 7.w),
                //               Expanded(
                //                 child: _buildFilterChipDropdown(
                //                   hint: S.of(context).price,
                //                   items: [
                //                     "< 50,000",
                //                     "50,000 - 100,000",
                //                     "> 100,000"
                //                   ],
                //                   value: selectedPrice,
                //                   onChanged: (val) =>
                //                       setState(() => selectedPrice = val),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // SizedBox(height: 6.h),

                // // Second Row
                // Padding(
                //   padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                //   child: Row(
                //     children: [
                //       Text(
                //         '${S.of(context).ad} 1000',
                //         style: TextStyle(
                //           fontSize: 12.sp,
                //           color: KTextColor,
                //           fontWeight: FontWeight.w400,
                //         ),
                //       ),
                //       SizedBox(width: 40.w),
                //       Expanded(
                //         child: Container(
                //           height: 37.h,
                //           padding:
                //               EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                //           decoration: BoxDecoration(
                //             border:
                //                 Border.all(color: const Color(0xFF08C2C9)),
                //             borderRadius: BorderRadius.circular(8.r),
                //           ),
                //           child: Row(
                //             children: [
                //               SvgPicture.asset(
                //                 'assets/icons/locationicon.svg',
                //                 width: 18.w,
                //                 height: 18.h,
                //               ),
                //               SizedBox(width: 12.w),
                //               Expanded(
                //                 child: Text(
                //                   S.of(context).sort,
                //                   overflow: TextOverflow.ellipsis,
                //                   style: TextStyle(
                //                     fontWeight: FontWeight.w600,
                //                     color: KTextColor,
                //                     fontSize: 12.sp,
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(
                //                 width: 35.w,
                //                 child: Transform.scale(
                //                   scale: 0.8,
                //                   child: Switch(
                //                     value: true,
                //                     onChanged: (val) {},
                //                     activeColor: Colors.white,
                //                     activeTrackColor:
                //                         const Color.fromRGBO(8, 194, 201, 1),
                //                     inactiveThumbColor: Colors.white,
                //                     inactiveTrackColor: Colors.grey[300],
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                SizedBox(height: 5.h),

                // Grid Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: CarSalesDummyData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 6,
                      childAspectRatio: .85,
                    ),
                    itemBuilder: (context, index) {
                      final car = CarSalesDummyData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          width: cardSize.width.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 5.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: Image.asset(
                                  car.image,
                                  height: (cardSize.height * 0.6).h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 6.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        car.price,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      Text(
                                        car.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          color: KTextColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "${car.year}",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: const Color.fromRGBO(
                                                  165, 164, 162, 1),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "${car.km} KM",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: const Color.fromRGBO(
                                                  165, 164, 162, 1),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        car.contact,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          color: KTextColor,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/Vector.svg',
                                            width: 10.5.w,
                                            height: 13.5.h,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              car.location,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Color.fromRGBO(
                                                    0, 30, 91, .75),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Size getCardSize(double screenWidth) {
  if (screenWidth <= 320) {
    return const Size(120, 140);
  } else if (screenWidth <= 375) {
    return const Size(135, 150);
  } else if (screenWidth <= 430) {
    return const Size(150, 160);
  } else {
    return const Size(165, 175);
  }
}