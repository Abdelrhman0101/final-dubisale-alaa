import 'package:advertising_app/constant/string.dart';
import 'package:advertising_app/data/electronic_dummy_data.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AllAddsElectronic extends StatefulWidget {
  const AllAddsElectronic({super.key});

  @override
  State<AllAddsElectronic> createState() => _AllAddsElectronicState();
}

class _AllAddsElectronicState extends State<AllAddsElectronic> {
  String? _selectedPrice;
  String? _selectedSection;
  String? _selectedProduct;

  // --- ✅ (تم الإصلاح) تم نقل dropdownButtonProps لمكانها الصحيح ---
Widget _buildFilterChipDropdown({
  required String hint,
  required List<String> items,
  required String? value,
  required ValueChanged<String?> onChanged,
}) {
  final s = S.of(context);
  const borderColor = Color(0xFF08C2C9);

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
        cursorColor: KTextColor,
        style: TextStyle(color: KTextColor, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: s.search,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: KTextColor, width: 2),
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
    
    // ✅ (تم التعديل) تم تبسيط الـ builder ليحتوي على النص فقط
    dropdownBuilder: (context, selectedItem) {
      return Text(
        selectedItem ?? hint,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: 10.5.sp, // حجم خط مناسب
          color: KTextColor,
          fontWeight: FontWeight.w500,
        ),
      );
    },
    
    // ✅ (تم التعديل) تم ضبط الحشو ليناسب السهم الافتراضي
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
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
          borderSide: BorderSide(color: KTextColor, width: 1.5),
        ),
        // تعديل الحشو لضمان ظهور النص بشكل جيد بجانب السهم
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
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
                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      // Back Button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Row(
                          children: [
                            const SizedBox(width: 18),
                            Icon(Icons.arrow_back_ios,
                                color: KTextColor, size: 17.sp),
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
                          "All Ads",
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
                      //   padding:
                      //       EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                      //   child: Container(
                      //     height: 35.h,
                      //     child: Row(
                      //       crossAxisAlignment: CrossAxisAlignment.center,
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
                      //                   hint: S.of(context).price,
                      //                   items: const [
                      //                     "< 500",
                      //                     "500 - 2000",
                      //                     "> 2000"
                      //                   ],
                      //                   value: _selectedPrice,
                      //                   onChanged: (val) => setState(
                      //                       () => _selectedPrice = val),
                      //                 ),
                      //               ),
                      //               SizedBox(width: 7.w),
                      //               Expanded(
                      //                 child: _buildFilterChipDropdown(
                      //                   hint: S.of(context).section,
                      //                   items: const [
                      //                     "هواتف",
                      //                     "شاشات",
                      //                     "أجهزة منزلية"
                      //                   ],
                      //                   value: _selectedSection,
                      //                   onChanged: (val) => setState(
                      //                       () => _selectedSection = val),
                      //                 ),
                      //               ),
                      //               SizedBox(width: 7.w),
                      //               Expanded(
                      //                 child: _buildFilterChipDropdown(
                      //                   hint: S.of(context).product,
                      //                   items: const ["جديد", "مستعمل"],
                      //                   value: _selectedProduct,
                      //                   onChanged: (val) => setState(
                      //                       () => _selectedProduct = val),
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
                      //   padding:
                      //       EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                      //   child: LayoutBuilder(
                      //     builder: (context, constraints) {
                      //       bool isSmallScreen =
                      //           MediaQuery.of(context).size.width <= 370;

                      //       if (isSmallScreen) {
                      //         return Row(
                      //           children: [
                      //             Text(
                      //               '${S.of(context).ad} 1000',
                      //               style: TextStyle(
                      //                 fontSize: 12.sp,
                      //                 color: KTextColor,
                      //                 fontWeight: FontWeight.w400,
                      //               ),
                      //             ),
                      //             SizedBox(width: 40.w),
                      //             Expanded(
                      //               child: Container(
                      //                 height: 37.h,
                      //                 padding: EdgeInsetsDirectional.symmetric(
                      //                     horizontal: 8.w),
                      //                 decoration: BoxDecoration(
                      //                   border: Border.all(
                      //                       color: const Color(0xFF08C2C9)),
                      //                   borderRadius:
                      //                       BorderRadius.circular(8.r),
                      //                 ),
                      //                 child: Row(
                      //                   children: [
                      //                     SvgPicture.asset(
                      //                       'assets/icons/locationicon.svg',
                      //                       width: 18.w,
                      //                       height: 18.h,
                      //                     ),
                      //                     SizedBox(width: 12.w),
                      //                     Expanded(
                      //                       child: Text(
                      //                         S.of(context).sort,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         style: TextStyle(
                      //                           fontWeight: FontWeight.w600,
                      //                           color: KTextColor,
                      //                           fontSize: 12.sp,
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     SizedBox(width: 1.w),
                      //                     SizedBox(
                      //                       width: 35.w,
                      //                       child: Transform.scale(
                      //                         scale: 0.8,
                      //                         child: Switch(
                      //                           value: true,
                      //                           onChanged: (val) {},
                      //                           activeColor: Colors.white,
                      //                           activeTrackColor:
                      //                               const Color.fromRGBO(
                      //                                   8, 194, 201, 1),
                      //                           inactiveThumbColor:
                      //                               Colors.white,
                      //                           inactiveTrackColor:
                      //                               Colors.grey[300],
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         );
                      //       } else {
                      //         return Row(
                      //           children: [
                      //             Text(
                      //               '${S.of(context).ad} 1000',
                      //               style: TextStyle(
                      //                 fontSize: 12.sp,
                      //                 color: KTextColor,
                      //                 fontWeight: FontWeight.w400,
                      //               ),
                      //             ),
                      //             SizedBox(width: 35.w),
                      //             Expanded(
                      //               child: Container(
                      //                 height: 37.h,
                      //                 padding: EdgeInsetsDirectional.symmetric(
                      //                     horizontal: 12.w),
                      //                 decoration: BoxDecoration(
                      //                   border: Border.all(
                      //                       color: const Color(0xFF08C2C9)),
                      //                   borderRadius:
                      //                       BorderRadius.circular(8.r),
                      //                 ),
                      //                 child: Row(
                      //                   children: [
                      //                     SvgPicture.asset(
                      //                       'assets/icons/locationicon.svg',
                      //                       width: 18.w,
                      //                       height: 18.h,
                      //                     ),
                      //                     SizedBox(width: 20.w),
                      //                     Expanded(
                      //                       child: Text(
                      //                         S.of(context).sort,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         style: TextStyle(
                      //                           fontWeight: FontWeight.w600,
                      //                           color: KTextColor,
                      //                           fontSize: 12.sp,
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     SizedBox(
                      //                       width: 32.w,
                      //                       child: Transform.scale(
                      //                         scale: .9,
                      //                         child: Switch(
                      //                           value: true,
                      //                           activeColor: Colors.white,
                      //                           activeTrackColor:
                      //                               const Color(0xFF08C2C9),
                      //                           inactiveThumbColor: Colors.grey,
                      //                           inactiveTrackColor:
                      //                               Colors.grey.shade300,
                      //                           onChanged: (val) {},
                      //                           materialTapTargetSize:
                      //                               MaterialTapTargetSize
                      //                                   .shrinkWrap,
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         );
                      //       }
                      //     },
                      //   ),
                      // ),
                      
                      
                      SizedBox(height: 5.h),
                    ],
                  ),

                  // Grid Section - Scrollable
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ElectronicDummyData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 6,
                        childAspectRatio: .9,
                      ),
                      itemBuilder: (context, index) {
                        final car = ElectronicDummyData[index];

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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: Image.asset(
                                      car.image,
                                      height: (cardSize.height * 0.6).h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(Icons.favorite_border,
                                        color: Colors.grey.shade300),
                                  ),
                                ]),
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
                                            SizedBox(width: 5),
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
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ));
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
