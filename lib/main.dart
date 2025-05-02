import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:letterboxd/core/theme/app_theme.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:letterboxd/features/onboarding/onboarding_page.dart';
import 'package:letterboxd/features/movie/controllers/movie_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Check if user has seen onboarding and is logged in
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final isLoggedIn = prefs.getString('user') != null && prefs.getString('session_id') != null;

  // Only show onboarding if user has never seen it
  final shouldShowOnboarding = !hasSeenOnboarding;

  runApp(MyApp(
    hasSeenOnboarding: !shouldShowOnboarding,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const MyApp({
    super.key, 
    required this.hasSeenOnboarding,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(MovieController());

    return GetMaterialApp(
      title: 'Letterboxd',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }

  String _getInitialRoute() {
    if (!hasSeenOnboarding) {
      return AppRoutes.onboarding;
    }
    if (isLoggedIn) {
      return AppRoutes.home;
    }
    return AppRoutes.login;
  }
}
