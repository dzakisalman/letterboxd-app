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
    _loadRatedMovies();
  }

  Future<void> _loadRatedMovies() async {
    try {
      _isLoading.value = true;
      
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn && authController.sessionId != null) {
        // Load rated movies from TMDB API
        final movies = await TMDBService.getRatedMovies(authController.sessionId!);
        _ratedMovies.assignAll(movies);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load rated movies: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void addRatedMovie(Movie movie) {
    if (!_ratedMovies.any((m) => m.id == movie.id)) {
      _ratedMovies.add(movie);
    }
  }

  void removeRatedMovie(int movieId) {
    _ratedMovies.removeWhere((movie) => movie.id == movieId);
  }

  bool isMovieRated(int movieId) {
    return _ratedMovies.any((movie) => movie.id == movieId);
  }
} 