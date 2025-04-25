import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class MovieDetailController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<Movie?> movie = Rx<Movie?>(null);
  final RxList<Map<String, dynamic>> cast = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> crew = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxList<Movie> similarMovies = <Movie>[].obs;
  final RxList<Movie> recommendedMovies = <Movie>[].obs;
  final RxBool isInWatchlist = false.obs;
  final RxDouble userRating = 0.0.obs;
  final RxString movieDirector = ''.obs;

  Future<void> loadMovieDetails(String movieId) async {
    try {
      isLoading.value = true;
      final movieIdInt = int.parse(movieId);
      
      // Load movie details
      final movieData = await TMDBService.getMovieDetails(movieIdInt);
      movie.value = movieData;

      // Load credits
      final creditsData = await TMDBService.getMovieCredits(movieIdInt);
      final castData = creditsData['cast'] as List;
      final crewData = creditsData['crew'] as List;
      
      cast.value = castData.map((item) => item as Map<String, dynamic>).toList();
      crew.value = crewData.map((item) => item as Map<String, dynamic>).toList();

      // Find director
      final director = crew.firstWhere(
        (person) => person['job'] == 'Director',
        orElse: () => {'name': 'Unknown'},
      );
      movieDirector.value = director['name'];

      // Load reviews
      final reviewsData = await TMDBService.getMovieReviews(movieIdInt);
      reviews.value = reviewsData;

      // Load similar movies
      final similarData = await TMDBService.getSimilarMovies(movieIdInt);
      similarMovies.value = similarData;

      // Load recommended movies
      final recommendedData = await TMDBService.getRecommendedMovies(movieIdInt);
      recommendedMovies.value = recommendedData;

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load movie details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToReviewForm() {
    final authController = Get.find<AuthController>();
    if (authController.currentUser != null) {
      Get.toNamed(AppRoutes.reviewFormPath(movie.value!.id.toString()));
    } else {
      Get.snackbar(
        'Error',
        'Please login to write a review',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleWatchlist() async {
    try {
      if (movie.value == null) return;

      const accountId = 1; // TODO: Get from auth
      final movieId = movie.value!.id;

      if (isInWatchlist.value) {
        final success = await TMDBService.removeFromWatchlist(accountId, movieId);
        if (success) {
          isInWatchlist.value = false;
          Get.snackbar(
            'Success',
            'Removed from watchlist',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        final success = await TMDBService.addToWatchlist(accountId, movieId);
        if (success) {
          isInWatchlist.value = true;
          Get.snackbar(
            'Success',
            'Added to watchlist',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update watchlist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rateMovie(double rating) async {
    try {
      if (movie.value == null) return;

      final success = await TMDBService.rateMovie(movie.value!.id, rating * 2); // Convert 5-star to 10-point scale
      if (success) {
        userRating.value = rating;
        Get.snackbar(
          'Success',
          'Rating submitted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to rate movie: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteRating() async {
    try {
      if (movie.value == null) return;

      final success = await TMDBService.deleteRating(movie.value!.id);
      if (success) {
        userRating.value = 0;
        Get.snackbar(
          'Success',
          'Rating removed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove rating: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 