import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/core/services/api_service.dart';

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
  final RxBool isWatched = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isInList = false.obs;

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

      // Check movie status
      await checkMovieStatus(movieIdInt);

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

  Future<void> checkMovieStatus(int movieId) async {
    try {
      const accountId = 1; // TODO: Get from auth
      
      // Check if movie is rated
      final accountStates = await TMDBService.getAccountStates(movieId);
      isWatched.value = accountStates['rated'] != null; // Only show watched for rated movies
      isFavorite.value = accountStates['favorite'] == true;
      isInList.value = accountStates['watchlist'] == true;
      userRating.value = accountStates['rated'] != null ? (accountStates['rated']['value'] as num).toDouble() / 2 : 0.0;
    } catch (e) {
      print('Error checking movie status: $e');
    }
  }

  void navigateToReviewForm() {
    final authController = Get.find<AuthController>();
    if (authController.currentUser != null && movie.value != null) {
      final movieData = movie.value!;
      final posterUrl = movieData.posterPath != null 
          ? '${ApiService.imageBaseUrl}/w500${movieData.posterPath}'
          : 'https://via.placeholder.com/500x750?text=No+Poster';
      
      Get.toNamed(AppRoutes.reviewFormPath(
        movieData.id.toString(),
        movieData.title,
        movieData.releaseDate.substring(0, 4),
        posterUrl,
      ));
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
          // Refresh movie status after removing from watchlist
          await checkMovieStatus(movieId);
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
          // Refresh movie status after adding to watchlist
          await checkMovieStatus(movieId);
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
        // Refresh movie status after rating
        await checkMovieStatus(movie.value!.id);
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
        // Refresh movie status after deleting rating
        await checkMovieStatus(movie.value!.id);
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

  Future<void> toggleFavorite() async {
    try {
      if (movie.value == null) return;

      final movieId = movie.value!.id;

      if (isFavorite.value) {
        final success = await TMDBService.removeFromFavorites(movieId);
        if (success) {
          isFavorite.value = false;
          // Refresh movie status after removing from favorites
          await checkMovieStatus(movieId);
          Get.snackbar(
            'Success',
            'Removed from favorites',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        final success = await TMDBService.addToFavorites(movieId);
        if (success) {
          isFavorite.value = true;
          // Refresh movie status after adding to favorites
          await checkMovieStatus(movieId);
          Get.snackbar(
            'Success',
            'Added to favorites',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
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