import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      backgroundColor: const Color(0xFF1F1D36),
      width: screenWidth * 0.75,
      child: SafeArea(
        child: Column(
          children: [
            // Close Button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/sidebar.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            // User Profile Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: authController.currentUser?.profileImage != null
                      ? NetworkImage(authController.currentUser!.profileImage!)
                      : null,
                    child: Obx(() {
                      final user = authController.currentUser;
                      if (user?.profileImage == null) {
                        return Text(
                          user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'G',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final user = authController.currentUser;
                          return Text(
                            user?.name ?? 'Guest',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          );
                        }),
                        Text(
                          '@${authController.currentUser?.username ?? ''}',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Follower Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _FollowerStat(
                    count: '0',
                    label: 'Followers',
                  ),
                  const Spacer(),
                  _FollowerStat(
                    count: '0',
                    label: 'Followings',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    iconPath: 'assets/icons/home.svg',
                    title: 'Home',
                    isSelected: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.offAllNamed(AppRoutes.home);
                    },
                  ),
                  _DrawerItem(
                    iconPath: 'assets/icons/films.svg',
                    title: 'Films',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.toNamed(AppRoutes.films);
                    },
                  ),
                  _DrawerItem(
                    iconPath: 'assets/icons/diary.svg',
                    title: 'Diary',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.toNamed(AppRoutes.diary);
                    },
                  ),
                  _DrawerItem(
                    iconPath: 'assets/icons/reviews.svg',
                    title: 'Reviews',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to reviews
                    },
                  ),
                  _DrawerItem(
                    iconPath: 'assets/icons/watchlists.svg',
                    title: 'Watchlist',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.toNamed(AppRoutes.watchlist);
                    },
                  ),
                  _DrawerItem(
                    iconPath: 'assets/icons/lists.svg',
                    title: 'Lists',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.toNamed(AppRoutes.lists);
                    },
                  ),
                  _DrawerItem(
                    iconPath: 'assets/icons/likes.svg',
                    title: 'Likes',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.toNamed(AppRoutes.likes);
                    },
                  ),
                ],
              ),
            ),
            // Logout Button
            _DrawerItem(
              iconPath: 'assets/icons/logout.svg',
              title: 'Logout',
              isSmall: true,
              onTap: () async {
                await authController.logout();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isSmall;

  const _DrawerItem({
    required this.iconPath,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFE9A6A6);
    final Color inactiveColor = Colors.white.withOpacity(0.85);
    final Color backgroundColor = const Color(0xFF1F1D36);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Material(
        color: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setState) {
            bool isPressed = false;

            return InkWell(
              onTap: onTap,
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) => setState(() => isPressed = false),
              onTapCancel: () => setState(() => isPressed = false),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: isPressed 
                      ? activeColor 
                      : (isSelected ? activeColor : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isSmall ? 4 : 8,
                  ),
                  minLeadingWidth: 20,
                  horizontalTitleGap: 8,
                  leading: SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(
                      isPressed || isSelected ? backgroundColor : inactiveColor,
                      BlendMode.srcIn,
                    ),
                    width: isSmall ? 20 : 24,
                    height: isSmall ? 20 : 24,
                  ),
                  title: Text(
                    title,
                    style: GoogleFonts.openSans(
                      color: isPressed || isSelected
                          ? backgroundColor 
                          : inactiveColor,
                      fontSize: isSmall ? 13 : 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

class _FollowerStat extends StatelessWidget {
  final String count;
  final String label;

  const _FollowerStat({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to followers/following page
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF9C4A8B),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.openSans(
                color: Colors.grey[400],
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 