import 'package:get/get.dart';
import 'package:letterboxd/features/authentication/login/login_page.dart';
import 'package:letterboxd/features/authentication/signup/signup_page.dart';
import 'package:letterboxd/features/home/home_page.dart';
import 'package:letterboxd/features/onboarding/onboarding_page.dart';
import 'package:letterboxd/features/profile/profile_page.dart';
import 'package:letterboxd/features/movie/movie_detail_page.dart';
import 'package:letterboxd/features/review/review_form_page.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String movieDetail = '/movie/:id';
  static const String reviewForm = '/review/:movieId';
  static const String watchlist = '/watchlist';
  static const String diary = '/diary';
  static const String lists = '/lists';
  static const String likes = '/likes';

  static String movieDetailPath(String id) => '/movie/$id';
  static String reviewFormPath(String movieId) => '/review/$movieId';

  static final pages = [
    GetPage(
      name: onboarding,
      page: () => const OnboardingPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: signup,
      page: () => SignupPage(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: movieDetail,
      page: () => MovieDetailPage(
        movieId: Get.parameters['id'] ?? '',
      ),
    ),
    GetPage(
      name: reviewForm,
      page: () => ReviewFormPage(
        movieId: Get.parameters['movieId'] ?? '',
      ),
    ),
  ];
} 