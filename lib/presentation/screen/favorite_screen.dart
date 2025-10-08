import 'package:advertising_app/constant/string.dart';
import 'package:advertising_app/data/car_rent_dummy_data.dart';
import 'package:advertising_app/data/car_sales_data_dummy.dart';
import 'package:advertising_app/data/car_sevice_dummy_data.dart';
import 'package:advertising_app/data/electronic_dummy_data.dart';
import 'package:advertising_app/data/job_data_dummy.dart';
import 'package:advertising_app/data/other_service_dummy_data.dart';
import 'package:advertising_app/data/real_estate_dummy_data.dart';
import 'package:advertising_app/data/restaurant_data_dummy.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/data/model/favorite_item_interface_model.dart';
import 'package:advertising_app/presentation/widget/custom_favorite_card.dart';
import 'package:advertising_app/presentation/widget/custom_bottom_nav.dart';
import 'package:advertising_app/presentation/widget/custom_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// بيانات وهمية إضافية مؤقتًا للتجربة
// (يمكنك حذفها لاحقًا واستخدام بياناتك الحقيقية)
 late final List<List<FavoriteItemInterface>> allData;

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int selectedCategory = 0;

  // قائمة تحتوي على بيانات كل التصنيفات
  late final List<List<FavoriteItemInterface>> allData;

  @override
  void initState() {
    super.initState();
    // هنا نجمع كل البيانات في قائمة واحدة
    // يجب أن يكون ترتيب البيانات مطابقًا لترتيب التصنيفات
    allData = [
      // Index 0:  S.of(context).carsales
      CarSalesDummyData,    

      // Index 1:  S.of(context).realestate
      RealEstateDummyData,  

      // Index 2:  S.of(context).electronics
      ElectronicDummyData ,

      // Index 3:  S.of(context).jobs
      JobDataDummy,        

      // Index 4:  S.of(context).carrent
      CarRentDummyData,     

      // Index 5:  S.of(context).carservices
      CarServiceDataDummy ,

      // Index 6:  S.of(context).restaurants
       
      RestaurantDataDammy,
      // Index 7:  S.of(context).otherservices
      OtherServiceDammyData
    ];
  }


  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    // قائمة التصنيفات النصية
    final List<String> categories = [
      S.of(context).carsales,      // index 0
      S.of(context).realestate,   // index 1
      S.of(context).electronics,  // index 2
      S.of(context).jobs,         // index 3
      S.of(context).carrent,      // index 4
      S.of(context).carservices,  // index 5
      S.of(context).restaurants,  // index 6
      S.of(context).otherservices // index 7
    ];

    // اختيار قائمة البيانات الصحيحة بناءً على التصنيف المحدد
    final selectedItems = allData[selectedCategory];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
        backgroundColor: Colors.white,
       // bottomNavigationBar: CustomBottomNav(currentIndex: 1),
        // appBar: AppBar(
        //   title: 
        //   Text(
        //     S.of(context).favorites,
        //     style: TextStyle(
        //       color: KTextColor,
        //       fontWeight: FontWeight.w500,
        //       fontSize: 24,
        //     ),
        //   ),
        //   centerTitle: true,
        //   backgroundColor: Colors.white,
        //   elevation: 1,
        // ),
        body: Column(
          children: [
            SizedBox(height: 60,),
            Text(
            S.of(context).favorites,
            style: TextStyle(
              color: KTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),
          ),
           SizedBox(height: 10,),
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
            // قائمة العناصر المفضلة
            Expanded(
              child: selectedItems.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد عناصر في هذا القسم', // رسالة أوضح
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18.sp,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 5, bottom: 10),
                      itemCount: selectedItems.length,
                      itemExtent: 120.h, // تحديد ارتفاع ثابت للعناصر لتحسين الأداء
                      cacheExtent: 500.0, // تحسين التخزين المؤقت
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];
                        // تم تعديل هذا الجزء
                        return FavoriteCard(
                          item: item,
                          categoryIndex: selectedCategory, // ✅ *** السطر الأهم ***
                          onDelete: () {
                            setState(() {
                              // حذف العنصر من قائمة البيانات الرئيسية
                              allData[selectedCategory].removeAt(index);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

























// import 'package:advertising_app/constant/string.dart';
// import 'package:advertising_app/data/car_sales_data_dummy.dart';
// import 'package:advertising_app/generated/l10n.dart';
// import 'package:advertising_app/data/model/favorite_item_interface_model.dart';
// import 'package:advertising_app/presentation/widget/custom_bottom_nav.dart';
// import 'package:advertising_app/presentation/widget/custom_favorite_card.dart';
// import 'package:advertising_app/presentation/widget/custom_category.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class FavoriteScreen extends StatefulWidget {
//   const FavoriteScreen({super.key});

//   @override
//   State<FavoriteScreen> createState() => _FavoriteScreenState();
// }

// class _FavoriteScreenState extends State<FavoriteScreen> {
//   int selectedCategory = 0;

//   late final List<List<FavoriteItemInterface>> allData;

//   @override
//   void initState() {
//     super.initState();
//     allData = [
//       CarSalesDummyData,
//      // RealEstateDummyData,
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Localizations.localeOf(context);
//     final isArabic = locale.languageCode == 'ar';

//     final List<String> categories = [
//       S.of(context).carsales,
//       S.of(context).realestate,
//       S.of(context).electronics,
//       S.of(context).jobs,
//       S.of(context).carrent,
//       S.of(context).carservices,
//       S.of(context).restaurants,
//       S.of(context).otherservices
//     ];

//     final selectedItems = allData[selectedCategory];

//     return Directionality(
//       textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      // child: Scaffold(
      //   backgroundColor: Colors.white,
      //   bottomNavigationBar: CustomBottomNav(currentIndex: 1),
      //   appBar: AppBar(
      //     title: Text(
      //       S.of(context).favorites,
      //       style: TextStyle(
      //         color: KTextColor,
      //         fontWeight: FontWeight.w500,
      //         fontSize: 24,
      //       ),
      //     ),
      //     centerTitle: true,
      //     backgroundColor: Colors.white,
      //     elevation: 1,
      //   ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal:10 ),
//               child: CustomCategoryGrid(
//                 categories: categories,
//                 selectedIndex: selectedCategory,
//                 onTap: (index) {
//                   setState(() {
//                     selectedCategory = index;
//                   });
//                 },
//               ),
//             ),
//             Expanded(
//               child: selectedItems.isEmpty
//                   ? Center(
//                       child: Text(
//                         'No items found.',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 18.sp,
//                         ),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.only(bottom: 10),
//                       itemCount: selectedItems.length,
//                       itemBuilder: (context, index) {
//                         final item = selectedItems[index];
//                         return Directionality(
//                           textDirection: TextDirection.ltr,
//                           child: FavoriteCard(
//                             item: item,
//                             onDelete: () {
//                               setState(() {
//                                 selectedItems.removeAt(index);
//                               });
//                             },
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
