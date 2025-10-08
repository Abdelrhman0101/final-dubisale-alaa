// ملف: login2.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:advertising_app/constant/string.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/presentation/widget/custom_button.dart';
import 'package:advertising_app/presentation/widget/custom_elevated_button.dart';
import 'package:advertising_app/presentation/widget/custom_phone_field.dart';
import 'package:advertising_app/presentation/providers/auth_repository.dart';
import 'package:advertising_app/router/local_notifier.dart';

class Login2 extends StatefulWidget {
  final LocaleChangeNotifier notifier;
  // تم حذف المعامل الثاني لأنه لم يكن مستخدماً، ولكن تم الإبقاء على notifier
  // لأنه مستخدم في تغيير لغة الواجهة
  const Login2({super.key, required this.notifier});

  @override
  State<Login2> createState() => _Login2State();
}

class _Login2State extends State<Login2> {
  final _phoneController = TextEditingController();
  String _fullPhoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // دالة للتعامل مع تسجيل الدخول
  Future<void> _handleLogin() async {
    if (_fullPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الهاتف'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.login(phone: _fullPhoneNumber);
    
    if (success) {
      if (!mounted) return;
      final String userType = (authProvider.userType ?? authProvider.user?.userType ?? '').toLowerCase();
      if (userType == 'advertiser') {
        context.push('/phonecode');
      } else {
        context.go('/');
      }
    } else {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'حدث خطأ في تسجيل الدخول'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.notifier.locale;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: ListView(
          children: [
            SizedBox(height: 24.h),
            Align(
              alignment: locale.languageCode == 'ar'
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: GestureDetector(
               onTap: () {
                  // تم الإبقاء على هذا لأنه تغيير في حالة الـ UI المحلية فقط
                  final currentLocale = widget.notifier.locale;
                  final newLocale = currentLocale.languageCode == 'en'
                      ? const Locale('ar')
                      : const Locale('en');
                  widget.notifier.changeLocale(newLocale);
                },
                child: Text(
                  locale.languageCode == 'ar'
                      ? S.of(context).arabic
                      : S.of(context).english,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: KTextColor),
                ),
              ),
            ),
             SizedBox(height: 50.h),
            Image.asset('assets/images/logo.png',
                fit: BoxFit.contain, height: 115.h, width: 135.w),
           // SizedBox(height: 3.h),
             Text("Enjoy Free Ads",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: KTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 10.h),
            Text(S.of(context).login,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: KTextColor,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 10.h),
            Text(S.of(context).phone,
                style: TextStyle(
                    color: KTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp)),
            
            // حقل الهاتف مع callback لحفظ الرقم الكامل
            CustomPhoneField(
              controller: _phoneController,
              onPhoneNumberChanged: (fullNumber) {
                _fullPhoneNumber = fullNumber;
              },
            ),
            
            SizedBox(height:8.h),
            
            // ---------------------------------------------------
            // تم حذف حقل كلمة المرور واستبدال الـ Checkbox بجملة عادية
            // ---------------------------------------------------
            
            SizedBox(height: 5.h),
            
            // جملة الموافقة على الشروط والأحكام
           

            // زر تسجيل الدخول مع منطق كامل
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CustomButton(
                  ontap: authProvider.isLoading ? null : _handleLogin,
                  text: authProvider.isLoading 
                    ? 'جاري تسجيل الدخول...' 
                    : S.of(context).login,
                );
              },
            ),
            
             Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'By Continue I agree to the',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: KTextColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                       Text(
                        ' Terms and Conditions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: KTextColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ],
                  ),
                
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                       crossAxisAlignment: CrossAxisAlignment.center ,
                                                          children: [
                                                             Text(
                                                              'and',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: KTextColor,
                                                                fontSize: 14.sp,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                             Text(
                                                              ' Privacy Policy',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: KTextColor,
                                                                fontSize: 14.sp,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                    ),
                
                
                ],
              ),
            ),

            SizedBox(height: 20.h),
            
            // SizedBox(height: 14.h),
            // Row(
            //   children: [
            //     const Expanded(
            //         child: Divider(color: KTextColor, thickness: 2)),
            //     Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 10.w),
            //         child: Text(S.of(context).or,
            //             style: TextStyle(
            //                 color: KTextColor,
            //                 fontWeight: FontWeight.w500,
            //                 fontSize: 16.sp))),
            //     const Expanded(
            //         child: Divider(color: KTextColor, thickness: 2)),
            //   ],
            // ),
            // SizedBox(height: 16.h),
            // Row(
            //   children: [
            //     Expanded(
            //         child: CustomElevatedButton(
            //             onpress: () {
            //                // UI Only - No Logic
            //             },
            //             text: S.of(context).emailLogin)),
            //     SizedBox(width: 16.w),
            //     Expanded(
            //         child: CustomElevatedButton(
            //             onpress: () {
            //                // UI Only - No Logic
            //             },
            //             text: S.of(context).guestLogin)),
            //   ],
            // ),
            // SizedBox(height: 16.h),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(S.of(context).dontHaveAccount,
            //         style: TextStyle(color: KTextColor, fontSize: 13.sp)),
            //     SizedBox(width: 4.w),
            //     GestureDetector(
            //       onTap: () {
            //          // UI Only - No Logic
            //       },
            //       child: Text(S.of(context).createAccount,
            //           style: TextStyle(
            //               decoration: TextDecoration.underline,
            //               decorationColor: KTextColor,
            //               decorationThickness: 1.5,
            //               color: KTextColor,
            //               fontWeight: FontWeight.w500,
            //               fontSize: 13.sp)),
            //     ),
            //   ],
            // ),
            
          
          ],
        ),
      ),
    );
  }
}