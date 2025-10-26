import 'package:advertising_app/constant/string.dart';
import 'package:advertising_app/data/model/favorites_response_model.dart';
import 'package:advertising_app/data/repository/favorites_repository.dart';
import 'package:advertising_app/data/web_services/api_service.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/data/model/favorite_item_interface_model.dart';
import 'package:advertising_app/presentation/widget/custom_favorite_card.dart';
import 'package:advertising_app/presentation/widget/custom_category.dart';
import 'package:advertising_app/presentation/providers/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int selectedCategory = 0;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final FavoritesRepository _favoritesRepository;
  
  // قائمة تحتوي على بيانات كل التصنيفات من API
  List<List<FavoriteItemInterface>> allData = [];
  bool isLoading = true;
  String? errorMessage;
  bool isUnauthenticated = false;

  @override
  void initState() {
    super.initState();
    _favoritesRepository = FavoritesRepository(ApiService());
    _loadFavoritesData();
  }

  /// تحميل بيانات المفضلة من API
  Future<void> _loadFavoritesData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        isUnauthenticated = false;
      });

      // الحصول على user ID من AuthProvider
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;
      
      // التحقق من وجود user ID
      if (userId == null) {
        setState(() {
          isLoading = false;
          isUnauthenticated = true;
        });
        return;
      }
      
      // استدعاء API للحصول على المفضلة باستخدام user ID للمستخدمين المسجلين فقط
      final favoritesResponse = await _favoritesRepository.getFavorites(userId: userId);
      
      // طباعة تشخيصية لفهم البيانات المرجعة
      debugPrint('🔍 Favorites Response Status: ${favoritesResponse.status}');
      debugPrint('🔍 Car Rent items count: ${favoritesResponse.data.carRent.length}');
      debugPrint('🔍 Car Sales items count: ${favoritesResponse.data.carSales.length}');
      debugPrint('🔍 Restaurant items count: ${favoritesResponse.data.restaurant.length}');
      debugPrint('🔍 Electronics items count: ${favoritesResponse.data.electronics.length}');
      debugPrint('🔍 Jobs items count: ${favoritesResponse.data.jobs.length}');
      debugPrint('🔍 Real Estate items count: ${favoritesResponse.data.realEstate.length}');
      debugPrint('🔍 Car Services items count: ${favoritesResponse.data.carServices.length}');
      debugPrint('🔍 Other Services items count: ${favoritesResponse.data.otherServices.length}');
      
      // استخدام الطريقة المساعدة من FavoritesData للحصول على البيانات مرتبة حسب التصنيفات
      // هذا يضمن أن ترتيب البيانات يطابق ترتيب التصنيفات في categories
      final organizedData = favoritesResponse.data.getAllItemsByCategory();
      allData = organizedData.map((categoryList) => 
        categoryList.cast<FavoriteItemInterface>()
      ).toList();

      setState(() {
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        isLoading = false;
        // تحسين رسالة الخطأ بناءً على نوع الخطأ
        if (e.toString().contains('Unauthenticated') || e.toString().contains('401')) {
          errorMessage = null; // لا نعرض رسالة خطأ، بل رسالة ودية
          isUnauthenticated = true;
        } else {
          errorMessage = 'فشل في تحميل المفضلة: ${e.toString()}';
          isUnauthenticated = false;
        }
      });
      debugPrint('Error loading favorites: $e');
    }
  }

  /// حذف عنصر من المفضلة
  Future<void> _removeFromFavorites(int favoriteId, int categoryIndex, int itemIndex) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      await _favoritesRepository.removeFromFavorites(
        favoriteId: favoriteId,
        token: token,
      );
      
      // إزالة العنصر من القائمة المحلية
      setState(() {
        allData[categoryIndex].removeAt(itemIndex);
      });
      
      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العنصر من المفضلة'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف العنصر: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                color: KTextColor,
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
              onPressed: _loadFavoritesData,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // اختيار قائمة البيانات الصحيحة بناءً على التصنيف المحدد
    final selectedItems = allData.isNotEmpty && selectedCategory < allData.length 
        ? allData[selectedCategory] 
        : <FavoriteItemInterface>[];

    // إذا كان المستخدم غير مصادق عليه أو ضيف، عرض رسالة تسجيل الدخول
    if (isUnauthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'تسجيل الدخول مطلوب',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'يجب تسجيل الدخول أولاً لعرض المفضلة الخاصة بك',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.login_outlined,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push("/login"),
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // إذا كانت القائمة فارغة (ولكن المستخدم مصادق عليه)، عرض الرسالة العربية العادية
    if (selectedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد عناصر مفضلة في هذا القسم',
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
        
        // الحصول على favoriteId إذا كان العنصر من نوع FavoriteItem
        int? favoriteId;
        if (item is FavoriteItem) {
          favoriteId = item.favoriteId;
        }
        
        return FavoriteCard(
          item: item,
          categoryIndex: selectedCategory,
          onDelete: () {
            if (favoriteId != null) {
              _removeFromFavorites(favoriteId, selectedCategory, index);
            } else {
              // fallback للحذف المحلي فقط
              setState(() {
                allData[selectedCategory].removeAt(index);
              });
            }
          },
        );
      },
    );
  }
}
