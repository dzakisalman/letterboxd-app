import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class LikesController extends GetxController {
  final authController = Get.find<AuthController>();
  bool isLoading = false;
  List<Movie> likedMovies = [];

  @override
  void onInit() {
    super.onInit();
    refreshLikedMovies();
  }

  Future<void> refreshLikedMovies() async {
    if (!authController.isLoggedIn) return;
    
    isLoading = true;
    update();
    
    try {
      final movies = await TMDBService.getFavoriteMovies(authController.sessionId!);
      likedMovies = movies;
    } catch (e) {
      print('Error fetching liked movies: $e');
      Get.snackbar(
        'Error',
        'Failed to load liked movies: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (!authController.isLoggedIn) {
      Get.snackbar(
        'Error',
        'Please login to manage favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final isFavorite = likedMovies.any((m) => m.id == movie.id);
      final success = await TMDBService.markAsFavorite(
        authController.sessionId!,
        movie.id,
        !isFavorite,
      );

      if (success) {
        if (isFavorite) {
          likedMovies.removeWhere((m) => m.id == movie.id);
          Get.snackbar(
            'Success',
            'Removed from favorites',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          likedMovies.add(movie);
          Get.snackbar(
            'Success',
            'Added to favorites',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        update();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 