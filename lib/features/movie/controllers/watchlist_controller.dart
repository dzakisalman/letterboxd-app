import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class WatchlistController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  List<Movie> _watchlist = [];
  bool _isLoading = false;

  List<Movie> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    refreshWatchlist();
  }

  Future<void> refreshWatchlist() async {
    if (!_authController.isLoggedIn) return;

    _isLoading = true;
    update();
    
    try {
      final movies = await TMDBService.getWatchlist(_authController.sessionId!);
      _watchlist = movies;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load watchlist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> addToWatchlist(Movie movie) async {
    if (!_authController.isLoggedIn) {
      Get.snackbar(
        'Error',
        'Please login to manage watchlist',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (_authController.sessionId == null) {
        throw Exception('No session ID available');
      }

      final success = await TMDBService.markAsWatchlist(
        _authController.sessionId!,
        movie.id,
        true,
      );

      if (success) {
        _watchlist.add(movie);
        update();
        Get.snackbar(
          'Success',
          'Added to watchlist',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add to watchlist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    if (!_authController.isLoggedIn) {
      Get.snackbar(
        'Error',
        'Please login to manage watchlist',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (_authController.sessionId == null) {
        throw Exception('No session ID available');
      }

      final success = await TMDBService.markAsWatchlist(
        _authController.sessionId!,
        movieId,
        false,
      );

      if (success) {
        _watchlist.removeWhere((movie) => movie.id == movieId);
        update();
        Get.snackbar(
          'Success',
          'Removed from watchlist',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from watchlist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool isInWatchlist(int movieId) {
    return _watchlist.any((movie) => movie.id == movieId);
  }
} 