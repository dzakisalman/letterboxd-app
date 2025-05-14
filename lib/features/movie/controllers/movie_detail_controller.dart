import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/core/services/api_service.dart';

class MovieDetailController extends GetxController {
  bool isLoading = true;
  Movie? movie;
  List<Map<String, dynamic>> cast = [];
  List<Map<String, dynamic>> crew = [];
  List<Map<String, dynamic>> reviews = [];
  List<Movie> similarMovies = [];
  List<Movie> recommendedMovies = [];
  bool isInWatchlist = false;
  double userRating = 0.0;
  String movieDirector = '';
  bool isWatched = false;
  bool isFavorite = false;
  bool isInList = false;

  Future<void> loadMovieDetails(String movieId) async {
    try {
      isLoading = true;
      update();
      
      final movieIdInt = int.parse(movieId);
      
      // Load movie details
      final movieData = await TMDBService.getMovieDetails(movieIdInt);
      movie = movieData;

      // Load credits
      final creditsData = await TMDBService.getMovieCredits(movieIdInt);
      final castData = creditsData['cast'] as List;
      final crewData = creditsData['crew'] as List;
      
      cast = castData.map((item) => item as Map<String, dynamic>).toList();
      crew = crewData.map((item) => item as Map<String, dynamic>).toList();

      // Find director
      final director = crew.firstWhere(
        (person) => person['job'] == 'Director',
        orElse: () => {'name': 'Unknown'},
      );
      movieDirector = director['name'];

      // Load reviews
      final reviewsData = await TMDBService.getMovieReviews(movieIdInt);
      reviews = reviewsData;

      // Load similar movies
      final similarData = await TMDBService.getSimilarMovies(movieIdInt);
      similarMovies = similarData;

      // Load recommended movies
      final recommendedData = await TMDBService.getRecommendedMovies(movieIdInt);
      recommendedMovies = recommendedData;

      // Check movie status
      await checkMovieStatus(movieIdInt);

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load movie details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> checkMovieStatus(int movieId) async {
    try {
      const accountId = 1; // TODO: Get from auth
      
      // Check if movie is rated
      final accountStates = await TMDBService.getAccountStates(movieId);
      isWatched = accountStates['rated'] != null; // Only show watched for rated movies
      isFavorite = accountStates['favorite'] == true;
      isInList = accountStates['watchlist'] == true;
      userRating = accountStates['rated'] != null ? (accountStates['rated']['value'] as num).toDouble() / 2 : 0.0;
      update();
    } catch (e) {
      print('Error checking movie status: $e');
    }
  }

  void navigateToReviewForm() {
    final authController = Get.find<AuthController>();
    if (authController.currentUser != null && movie != null) {
      final movieData = movie!;
      final posterUrl = movieData.posterPath != null 
          ? '${ApiService.imageBaseUrl}/w500${movieData.posterPath}'
          : 'https://via.placeholder.com/500x750?text=No+Poster';
      
      Get.toNamed(AppRoutes.reviewFormPath(
        movieData.id.toString(),
        movieData.title,
        movieData.releaseDate.substring(0, 4),
        posterUrl,
      ), arguments: {
        'existingRating': userRating,
        'isFavorite': isFavorite,
      });
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
      if (movie == null) return;

      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn) {
        Get.snackbar(
          'Error',
          'Please login to manage watchlist',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final accountDetails = await TMDBService.getAccountDetails(authController.sessionId!);
      final accountId = accountDetails['id'];
      final movieId = movie!.id;

      if (isInWatchlist) {
        final response = await TMDBService.markAsWatchlist(
          authController.sessionId!,
          movieId,
          false,
        );
        if (response) {
          isInWatchlist = false;
          // Refresh movie status after removing from watchlist
          await checkMovieStatus(movieId);
          Get.snackbar(
            'Success',
            'Removed from watchlist',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        final response = await TMDBService.markAsWatchlist(
          authController.sessionId!,
          movieId,
          true,
        );
        if (response) {
          isInWatchlist = true;
          // Refresh movie status after adding to watchlist
          await checkMovieStatus(movieId);
          Get.snackbar(
            'Success',
            'Added to watchlist',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
      update();
    } catch (e) {
      print('[MovieDetail] Error toggling watchlist: $e');
      Get.snackbar(
        'Error',
        'Failed to update watchlist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rateMovie(double rating) async {
    try {
      if (movie == null) return;

      final success = await TMDBService.rateMovie(movie!.id, rating * 2); // Convert 5-star to 10-point scale
      if (success) {
        userRating = rating;
        // Refresh movie status after rating
        await checkMovieStatus(movie!.id);
        Get.snackbar(
          'Success',
          'Rating submitted',
          snackPosition: SnackPosition.BOTTOM,
        );
        update();
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
      if (movie == null) return;

      final success = await TMDBService.deleteRating(movie!.id);
      if (success) {
        userRating = 0.0;
        // Refresh movie status after deleting rating
        await checkMovieStatus(movie!.id);
        Get.snackbar(
          'Success',
          'Rating deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
        update();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete rating: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleFavorite() async {
    try {
      if (movie == null) return;

      final movieId = movie!.id;

      if (isFavorite) {
        final success = await TMDBService.removeFromFavorites(movieId);
        if (success) {
          isFavorite = false;
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
          isFavorite = true;
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