import 'dart:ui';

import 'package:advertising_app/generated/l10n.dart';
import 'package:advertising_app/presentation/screen/all_add_car_sales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:advertising_app/presentation/providers/auth_repository.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {

    
      

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor:Colors.white, 
      currentIndex: currentIndex,
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
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: const Text('تنبيه'),
                    content: const Text(
                      'لا يمكنك إضافة إعلان إلا بعد تفعيل رقم هاتفك.\n\nرجاءً فعّل رقمك من صفحة البروفايل.',
                     style: TextStyle(color: KTextColor),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.push('/editprofile');
                        },
                        child: const Text('تفعيل الآن'),
                      ),
                    ],
                  );
                },
              );
            }
            break;
          }
          case 3:
            context.push('/manage');
            break;
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
              color: currentIndex == 0
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
              color: currentIndex == 3
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
