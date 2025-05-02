import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class MovieController extends GetxController {
  final RxList<Movie> _ratedMovies = <Movie>[].obs;
  final _isLoading = false.obs;

  List<Movie> get ratedMovies => _ratedMovies;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    print('[MovieController] Initializing...');
    _loadRatedMovies();
  }

  Future<void> _loadRatedMovies() async {
    try {
      print('[MovieController] Loading rated movies...');
      _isLoading.value = true;
      
      final authController = Get.find<AuthController>();
      print('[MovieController] Auth state - isLoggedIn: ${authController.isLoggedIn}, sessionId: ${authController.sessionId != null}');
      
      if (authController.isLoggedIn && authController.sessionId != null) {
        print('[MovieController] User is logged in, fetching rated movies...');
        // Load rated movies from TMDB API
        final movies = await TMDBService.getRatedMovies(authController.sessionId!);
        print('[MovieController] Received ${movies.length} rated movies');
        _ratedMovies.assignAll(movies);
        print('[MovieController] Updated rated movies list');
      } else {
        print('[MovieController] User is not logged in or session ID is null');
      }
    } catch (e, stackTrace) {
      print('[MovieController] Error loading rated movies: $e');
      print('[MovieController] Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load rated movies: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
      print('[MovieController] Loading state set to false');
    }
  }

  void addRatedMovie(Movie movie) {
    print('[MovieController] Adding rated movie: ${movie.title}');
    if (!_ratedMovies.any((m) => m.id == movie.id)) {
      _ratedMovies.add(movie);
      print('[MovieController] Movie added successfully');
    } else {
      print('[MovieController] Movie already exists in rated list');
    }
  }

  void removeRatedMovie(int movieId) {
    print('[MovieController] Removing movie with ID: $movieId');
    _ratedMovies.removeWhere((movie) => movie.id == movieId);
    print('[MovieController] Movie removed successfully');
  }

  bool isMovieRated(int movieId) {
    final isRated = _ratedMovies.any((movie) => movie.id == movieId);
    print('[MovieController] Checking if movie $movieId is rated: $isRated');
    return isRated;
  }

  // Method to manually refresh rated movies
  Future<void> refreshRatedMovies() async {
    print('[MovieController] Manually refreshing rated movies...');
    await _loadRatedMovies();
  }
} 