import 'dart:ui';

import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/presentation/screen/all_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:advertising_app/presentation/providers/auth_repository.dart';
import 'package:advertising_app/presentation/widget/custom_text_field.dart';
import 'package:advertising_app/data/web_services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_app/constant/string.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({required this.currentIndex});

  @override
  _CustomBottomNavState createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  int? _pendingNavIndex;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    // Validate passwords
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال كلمة المرور'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تأكيد كلمة المرور'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور وتأكيدها غير متطابقين'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Password strength validation
    final password = _passwordController.text;
    if (password.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور يجب أن تكون 7 أحرف على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get userId from storage
      final userIdStr = await _storage.read(key: 'user_id');
      if (userIdStr == null) {
        throw Exception('User ID not found');
      }

      final userId = int.parse(userIdStr);

      // Get auth token
      final authToken = await _storage.read(key: 'auth_token');

      // Make API call
      final response = await _apiService.post(
        '/api/set-password',
        data: {
          'userId': userId,
          'password': password,
          'password_confirmation': _confirmPasswordController.text,
        },
        token: authToken,
      );

      // Success - Update user_type in cache to advertiser
      await _storage.write(key: 'user_type', value: 'advertiser');
      
      // حفظ التوكن الجديد إذا كان موجوداً في الاستجابة
      if (response['token'] != null) {
        await _storage.write(key: 'auth_token', value: response['token']);
      }
      
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعيين كلمة المرور بنجاح وتم ترقية حسابك إلى معلن'),
          backgroundColor: Colors.green,
        ),
      );

      // تحديث حالة AuthProvider من التخزين لضمان قراءة userType الجديد فوراً
      await context.read<AuthProvider>().checkStoredSession();

      // فتح الصفحة المقصودة مباشرة إذا كانت مُحددة
      if (_pendingNavIndex == 2) {
        context.push('/postad');
      } else if (_pendingNavIndex == 3) {
        context.push('/manage');
      }
      _pendingNavIndex = null;

      // Clear controllers
      _passwordController.clear();
      _confirmPasswordController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تعيين كلمة المرور: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showNonAdvertiserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'Secure Your Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B365D),
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Before upgrading to an Advertiser account, please set a password to safeguard your account and confirm the update.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Password field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Enter Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                    const SizedBox(height: 15),
                    
                    // Confirm password field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.of(context).pop();
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(1, 84, 126, 1),
                         
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            
                           // side: const BorderSide(color: Color(0xFF1B365D)),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _setPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(1, 84, 126, 1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Set Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor:Colors.white, 
      currentIndex: widget.currentIndex,
      showUnselectedLabels: true, 
      selectedItemColor: Color(0xFF01547E),
      unselectedItemColor:Color.fromRGBO( 5, 194, 201,1),
      onTap: (index) {
        switch (index) {
          case 0:
            context.push('/home');
            break;
          case 1:
            context.push('/favorite');
            break;
          case 2: {
            final auth = context.read<AuthProvider>();
            final userType = auth.userType?.toLowerCase();

            if (userType == 'advertiser') {
              context.push('/postad');
            } else {
              _pendingNavIndex = 2;
              _showNonAdvertiserDialog();
            }
            break;
          }
          case 3: {
            final auth = context.read<AuthProvider>();
            final userType = auth.userType?.toLowerCase();

            if (userType == 'advertiser') {
              context.push('/manage');
            } else {
              _pendingNavIndex = 3;
              _showNonAdvertiserDialog();
            }
            break;
          }
           

          case 4:
            context.push('/setting');
            break;
        }
      },
       items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            "assets/icons/home.svg",
               width: 26.w,
              height: 26,
              color: widget.currentIndex == 0
        ? const Color(0xFF01547E) // لون المختار
        : const Color.fromRGBO(5, 194, 201, 1), // لون غير المختار
  
                 ),
        label:S.of(context).home,
        ),
         BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.heart),
          label:S.of(context).favorites,
        ),

       
        BottomNavigationBarItem(
          icon: Center(
            child: Container(
              height: 30,
              width: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                 gradient: LinearGradient(
            colors: [
              const Color(0xFFC9F8FE),
              const Color(0xFF08C2C9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
                    ),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.red, // لون الزائد
                  size: 18,
                ),
              ),
            ),
          ),
          label: S.of(context).post,
        ),

         BottomNavigationBarItem(
          icon: SvgPicture.asset(
            "assets/icons/folder_edit_icon.svg",
               width: 26,
              height: 26,
              color: widget.currentIndex == 3
        ? const Color(0xFF01547E)
        : const Color.fromRGBO(5, 194, 201, 1),
  
                 ),
                 label:S.of(context).manage,
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.gear),
          label:S.of(context).srtting,
        ),
      ],
    );
  }
}
