import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class HomeController extends GetxController {
  final RxList<Movie> popularMovies = <Movie>[].obs;
  final RxList<Movie> trendingMovies = <Movie>[].obs;
  final RxList<Map<String, dynamic>> popularLists = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentReviews = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      
      // Load all data in parallel
      await Future.wait([
        loadMovies(),
        loadLists(),
      ]);
      
      // Load reviews after movies are loaded
      await loadReviews();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMovies() async {
    try {
      // Load popular and trending movies in parallel
      final results = await Future.wait([
        TMDBService.getPopularMovies(),
        TMDBService.getTrendingMovies(),
      ]);
      
      print('[Home] Popular movies type: ${results[0].runtimeType}');
      print('[Home] Popular movies length: ${results[0].length}');
      print('[Home] First popular movie type: ${results[0].isNotEmpty ? results[0][0].runtimeType : 'empty'}');
      
      print('[Home] Trending movies type: ${results[1].runtimeType}');
      print('[Home] Trending movies length: ${results[1].length}');
      print('[Home] First trending movie type: ${results[1].isNotEmpty ? results[1][0].runtimeType : 'empty'}');
      
      popularMovies.value = results[0];
      trendingMovies.value = results[1];
    } catch (e, stackTrace) {
      print('[Home] Error loading movies: $e');
      print('[Home] Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load movies: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadLists() async {
    try {
      print('[Home] Loading top rated movies...');
      final movies = await TMDBService.getPopularCollections();
      print('[Home] Received ${movies.length} top rated movies');
      
      popularLists.value = movies.map((movie) {
        return {
          'title': movie['title'] ?? 'Untitled Movie',
          'author': 'Rating: ${(movie['vote_average'] as num).toStringAsFixed(1)}/10',
          'posterPath': movie['poster_path'] ?? '',
          'id': movie['id'],
          'overview': movie['overview'] ?? '',
          'releaseDate': movie['release_date'] ?? '',
        };
      }).toList();
      
      print('[Home] Top rated movies loaded successfully');
    } catch (e) {
      print('[Home] Failed to load top rated movies: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load top rated movies: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadReviews() async {
    if (popularMovies.isEmpty) return;
    
    try {
      isLoadingMore.value = true;
      
      // Get reviews for first 3 popular movies in parallel
      final reviews = await Future.wait(
        popularMovies.take(3).map((movie) => TMDBService.getMovieReviews(movie.id))
      );
      
      final List<Map<String, dynamic>> allReviews = [];
      
      for (var i = 0; i < reviews.length; i++) {
        if (reviews[i].isNotEmpty) {
          final movie = popularMovies[i];
          final review = reviews[i][0];
          final avatarPath = review['author_details']?['avatar_path'];
          String? avatarUrl;
          
          if (avatarPath != null) {
            // Check if it's a full URL (starts with http)
            if (avatarPath.startsWith('/http')) {
              avatarUrl = avatarPath.substring(1); // Remove leading slash
            } else {
              avatarUrl = 'https://image.tmdb.org/t/p/w185$avatarPath';
            }
          }
          
          allReviews.add({
            'movieTitle': movie.title,
            'movieId': movie.id,
            'posterPath': movie.posterUrl,
            'author': review['author'] ?? 'Anonymous',
            'avatarUrl': avatarUrl,
            'rating': (review['author_details']?['rating'] ?? 0) / 2,
            'content': review['content'] ?? '',
            'createdAt': review['created_at'] ?? '',
          });
        }
      }
      
      recentReviews.value = allReviews;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reviews: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
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