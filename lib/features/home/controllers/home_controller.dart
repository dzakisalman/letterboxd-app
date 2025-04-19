import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class HomeController extends GetxController {
  final RxList<Movie> popularMovies = <Movie>[].obs;
  final RxList<Movie> trendingMovies = <Movie>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      isLoading.value = true;
      
      // Load popular movies
      popularMovies.value = await TMDBService.getPopularMovies();

      // Load trending movies
      trendingMovies.value = await TMDBService.getTrendingMovies();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load movies: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    
    try {
      return await TMDBService.searchMovies(query);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search movies: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }
} 