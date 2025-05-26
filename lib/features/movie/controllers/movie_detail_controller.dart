import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/core/services/api_service.dart';
import 'package:letterboxd/features/review/models/review.dart';

class MovieDetailController extends GetxController {
  bool _isLoading = false;
  Movie? movie;
  List<Map<String, dynamic>> cast = [];
  List<Map<String, dynamic>> crew = [];
  List<Review> reviews = [];
  List<Map<String, dynamic>> videos = [];
  List<Movie> similarMovies = [];
  List<Movie> recommendedMovies = [];
  bool isInWatchlist = false;
  double userRating = 0.0;
  String movieDirector = '';
  bool isWatched = false;
  bool isFavorite = false;
  bool isInList = false;

  bool get isLoading => _isLoading;

  Future<void> loadMovieDetails(String movieId) async {
    try {
      _isLoading = true;
      update();
      
      final movieIdInt = int.parse(movieId);
      
      // Load movie details
      movie = await TMDBService.getMovieDetails(movieIdInt);
      
      // Load credits
      final credits = await TMDBService.getMovieCredits(movieIdInt);
      cast = List<Map<String, dynamic>>.from(credits['cast'] ?? []);
      crew = List<Map<String, dynamic>>.from(credits['crew'] ?? []);
      
      // Find director
      movieDirector = crew
          .firstWhere(
            (person) => person['job'] == 'Director',
            orElse: () => {'name': 'Unknown'},
          )['name']
          .toString();

      // Load videos
      videos = await TMDBService.getMovieVideos(movieIdInt);
      
      // Load reviews
      final reviewsData = await TMDBService.getMovieReviews(movieIdInt);
      reviews = reviewsData.map((reviewData) {
        final authorDetails = reviewData['author_details'] as Map<String, dynamic>? ?? {};
        final avatarPath = authorDetails['avatar_path']?.toString();
        String? avatarUrl;
        
        if (avatarPath != null && avatarPath.isNotEmpty) {
          if (avatarPath.startsWith('/http') || avatarPath.startsWith('http')) {
            avatarUrl = avatarPath.startsWith('/') ? avatarPath.substring(1) : avatarPath;
          } else {
            avatarUrl = 'https://image.tmdb.org/t/p/w185$avatarPath';
          }
        } else {
          avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(reviewData['author'] ?? 'Anonymous')}&background=random';
        }

        return Review.fromJson({
          'id': reviewData['id']?.toString() ?? '',
          'user_id': authorDetails['id']?.toString() ?? '',
          'username': authorDetails['username']?.toString() ?? reviewData['author']?.toString() ?? 'Anonymous',
          'user_avatar_url': avatarUrl ?? '',
          'movie_id': movieId,
          'movie_title': movie?.title ?? '',
          'movie_year': movie?.releaseDate.substring(0, 4) ?? '',
          'movie_poster_url': movie?.posterUrl ?? '',
          'rating': authorDetails['rating'] != null ? (authorDetails['rating'] as num).toDouble() : 0.0,
          'content': reviewData['content']?.toString() ?? '',
          'watched_date': reviewData['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          'likes': 0,
          'is_liked': false,
        });
      }).toList();

      // Load similar movies
      final similarData = await TMDBService.getSimilarMovies(movieIdInt);
      similarMovies = similarData;

      // Load recommended movies
      final recommendedData = await TMDBService.getRecommendedMovies(movieIdInt);
      recommendedMovies = recommendedData;

      // Check movie status
      await checkMovieStatus(movieIdInt);
      
      update();
    } catch (e) {
      print('[MovieDetail] Error loading movie details: $e');
      Get.snackbar(
        'Error',
        'Failed to load movie details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading = false;
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
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 