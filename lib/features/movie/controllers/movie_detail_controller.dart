import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class MovieDetailController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<Movie?> movie = Rx<Movie?>(null);
  final RxList<Map<String, dynamic>> cast = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxList<Movie> similarMovies = <Movie>[].obs;
  final RxList<Movie> recommendedMovies = <Movie>[].obs;
  final RxBool isInWatchlist = false.obs;
  final RxDouble userRating = 0.0.obs;

  Future<void> loadMovieDetails(String movieId) async {
    try {
      isLoading.value = true;
      
      // Load movie details
      movie.value = await TMDBService.getMovieDetails(int.parse(movieId));

      // Load cast
      final credits = await TMDBService.getMovieCredits(int.parse(movieId));
      cast.value = credits
          .take(5)
          .map((actor) => {
                'name': actor['name'],
                'character': actor['character'],
                'profile_path': actor['profile_path'],
              })
          .toList();

      // Load reviews
      final reviewsList = await TMDBService.getMovieReviews(int.parse(movieId));
      reviews.value = reviewsList
          .take(3)
          .map((review) => {
                'author': review['author'],
                'content': review['content'],
                'rating': review['author_details']['rating'],
                'created_at': review['created_at'],
              })
          .toList();

      // Load similar movies
      similarMovies.value = await TMDBService.getSimilarMovies(int.parse(movieId));

      // Load recommended movies
      recommendedMovies.value = await TMDBService.getRecommendedMovies(int.parse(movieId));

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

  void navigateToReviewForm() {
    if (movie.value != null) {
      Get.toNamed(
        '/review/${movie.value!.id}',
        arguments: movie.value,
      );
    }
  }
} 