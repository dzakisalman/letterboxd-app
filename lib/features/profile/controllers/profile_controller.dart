import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final authController = Get.find<AuthController>();
  
  final RxList<Movie> favoriteMovies = <Movie>[].obs;
  final RxList<Movie> recentlyWatched = <Movie>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    if (!authController.isLoggedIn) return;

    try {
      isLoading.value = true;
      
      // Load data in parallel
      final results = await Future.wait([
        TMDBService.getFavoriteMovies(authController.sessionId!),
        TMDBService.getRatedMovies(authController.sessionId!),
      ]);

      favoriteMovies.value = results[0];
      recentlyWatched.value = results[1];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
      favoriteMovies.value = updatedFavorites;

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