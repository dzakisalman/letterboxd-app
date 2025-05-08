import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:letterboxd/features/review/review_page.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/features/authentication/login/login_page.dart';
import 'package:letterboxd/features/authentication/signup/signup_page.dart';
import 'package:letterboxd/features/home/home_page.dart';
import 'package:letterboxd/features/onboarding/onboarding_page.dart';
import 'package:letterboxd/features/profile/profile_page.dart';
import 'package:letterboxd/features/movie/movie_detail_page.dart';
import 'package:letterboxd/features/review/review_form_page.dart';
import 'package:letterboxd/features/explore/explore_page.dart';
import 'package:letterboxd/features/movie/pages/films_page.dart';
import 'package:letterboxd/features/diary/pages/diary_page.dart';
import 'package:letterboxd/features/movie/pages/watchlist_page.dart';
import 'package:letterboxd/features/movie/pages/likes_page.dart';
import 'package:letterboxd/features/lists/pages/lists_page.dart';
import 'package:letterboxd/features/lists/pages/create_list_page.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => SignupPage(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: AppRoutes.movieDetail,
      page: () => MovieDetailPage(movieId: Get.parameters['id'] ?? ''),
    ),
    GetPage(
      name: AppRoutes.reviewForm,
      page: () => ReviewFormPage(
        movieId: Get.parameters['movieId'] ?? '',
        movieTitle: Uri.decodeComponent(Get.parameters['title'] ?? ''),
        movieYear: Uri.decodeComponent(Get.parameters['year'] ?? ''),
        posterPath: Uri.decodeComponent(Get.parameters['poster'] ?? ''),
        existingRating: Get.arguments?['existingRating'] as double?,
        isFavorite: Get.arguments?['isFavorite'] as bool?,
      ),
    ),
    GetPage(
      name: AppRoutes.explore,
      page: () => const ExplorePage(),
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => ReviewPage(review: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.films,
      page: () => const FilmsPage(),
    ),
    GetPage(
      name: AppRoutes.diary,
      page: () => const DiaryPage(),
    ),
    GetPage(
      name: AppRoutes.watchlist,
      page: () => const WatchlistPage(),
      middlewares: [
        RouteGuard(),
      ],
    ),
    GetPage(
      name: AppRoutes.likes,
      page: () => const LikesPage(),
      middlewares: [
        RouteGuard(),
      ],
    ),
    GetPage(
      name: AppRoutes.lists,
      page: () => const ListsPage(),
      middlewares: [
        RouteGuard(),
      ],
    ),
    GetPage(
      name: AppRoutes.createList,
      page: () => CreateListPage(),
      middlewares: [
        RouteGuard(),
      ],
    ),
  ];
}

class RouteGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    return authController.isLoggedIn ? null : const RouteSettings(name: AppRoutes.login);
  }
} 