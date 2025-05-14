import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final authController = Get.find<AuthController>();
  
  List<Movie> favoriteMovies = [];
  List<Movie> recentlyWatched = [];
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    if (!authController.isLoggedIn) return;

    try {
      isLoading = true;
      update();
      
      // Load data in parallel
      final results = await Future.wait([
        TMDBService.getFavoriteMovies(authController.sessionId!),
        TMDBService.getRatedMovies(authController.sessionId!),
      ]);

      favoriteMovies = results[0];
      recentlyWatched = results[1];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> toggleFavorite(int movieId) async {
    if (!authController.isLoggedIn) return;

    try {
      final isFavorite = favoriteMovies.any((movie) => movie.id == movieId);
      await TMDBService.markAsFavorite(
        authController.sessionId!,
        movieId,
        !isFavorite,
      );

      // Reload favorite movies
      final updatedFavorites = await TMDBService.getFavoriteMovies(authController.sessionId!);
      favoriteMovies = updatedFavorites;
      update();

      Get.snackbar(
        'Success',
        isFavorite ? 'Removed from favorites' : 'Added to favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorite: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 