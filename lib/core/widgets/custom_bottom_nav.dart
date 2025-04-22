import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _handleNavigation(int index) {
    if (index == currentIndex) return;
    
    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.home);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.explore);
        break;
      case 2:
        Get.offAllNamed(AppRoutes.activity);
        break;
      case 3:
        Get.offAllNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1D36),
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _handleNavigation,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFE9A6A6),
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/home.svg',
              colorFilter: ColorFilter.mode(
                currentIndex == 0 ? const Color(0xFFE9A6A6) : Colors.grey[600]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Stack(
              children: [
                SvgPicture.asset(
                  'assets/icons/home.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFE9A6A6),
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9A6A6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/explore.svg',
              colorFilter: ColorFilter.mode(
                currentIndex == 1 ? const Color(0xFFE9A6A6) : Colors.grey[600]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Stack(
              children: [
                SvgPicture.asset(
                  'assets/icons/explore.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFE9A6A6),
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9A6A6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/notification.svg',
              colorFilter: ColorFilter.mode(
                currentIndex == 2 ? const Color(0xFFE9A6A6) : Colors.grey[600]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Stack(
              children: [
                SvgPicture.asset(
                  'assets/icons/notification.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFE9A6A6),
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9A6A6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/user.svg',
              colorFilter: ColorFilter.mode(
                currentIndex == 3 ? const Color(0xFFE9A6A6) : Colors.grey[600]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Stack(
              children: [
                SvgPicture.asset(
                  'assets/icons/user.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFE9A6A6),
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9A6A6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
        ],
      ),
    );
  }
} 