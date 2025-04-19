import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/routes/app_routes.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Drawer(
      child: Container(
        color: const Color(0xFF1B2228),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF00E054),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    final user = authController.currentUser;
                    return Text(
                      user?.username ?? 'Guest',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () => Get.offAllNamed(AppRoutes.home),
            ),
            _DrawerItem(
              icon: Icons.movie,
              title: 'Films',
              onTap: () {
                Get.back();
                // TODO: Navigate to films
              },
            ),
            _DrawerItem(
              icon: Icons.calendar_today,
              title: 'Diary',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.diary);
              },
            ),
            _DrawerItem(
              icon: Icons.rate_review,
              title: 'Reviews',
              onTap: () {
                Get.back();
                // TODO: Navigate to reviews
              },
            ),
            _DrawerItem(
              icon: Icons.bookmark,
              title: 'Watchlist',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.watchlist);
              },
            ),
            _DrawerItem(
              icon: Icons.list,
              title: 'Lists',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.lists);
              },
            ),
            _DrawerItem(
              icon: Icons.favorite,
              title: 'Likes',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.likes);
              },
            ),
            const Divider(color: Colors.grey),
            _DrawerItem(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.profile);
              },
            ),
            _DrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Get.back();
                // TODO: Navigate to settings
              },
            ),
            _DrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await authController.logout();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
} 