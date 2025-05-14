import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class HomeController extends GetxController {
  List<Movie> popularMovies = [];
  List<Movie> trendingMovies = [];
  List<Map<String, dynamic>> popularLists = [];
  List<Map<String, dynamic>> recentReviews = [];
  bool isLoading = false;
  bool isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> refreshData() async {
    try {
      isLoading = true;
      update();
      
      // Clear existing data
      popularMovies.clear();
      trendingMovies.clear();
      popularLists.clear();
      recentReviews.clear();
      
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
        'Failed to refresh data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _initializeData() async {
    try {
      isLoading = true;
      update();
      
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
      isLoading = false;
      update();
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
      
      popularMovies = results[0];
      trendingMovies = results[1];
      update();
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
      
      popularLists = movies.map((movie) {
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
      update();
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
      isLoadingMore = true;
      update();
      
      print('[Home] Loading reviews for ${popularMovies.length} movies');
      
      // Get reviews for first 3 popular movies in parallel
      final reviews = await Future.wait(
        popularMovies.take(3).map((movie) => TMDBService.getMovieReviews(movie.id))
      );
      
      print('[Home] Received ${reviews.length} review sets');
      
      final List<Map<String, dynamic>> allReviews = [];
      
      for (var i = 0; i < reviews.length; i++) {
        print('[Home] Processing review set $i');
        if (reviews[i].isNotEmpty) {
          final movie = popularMovies[i];
          final review = reviews[i][0];
          final authorDetails = review['author_details'] as Map<String, dynamic>? ?? {};
          
          print('[Home] Movie data: ${movie.toJson()}');
          print('[Home] Review data: $review');
          
          // Process avatar URL
          final avatarPath = authorDetails['avatar_path']?.toString();
          String avatarUrl;
          
          if (avatarPath != null && avatarPath.isNotEmpty) {
            // If it's already a full URL (starts with http or https)
            if (avatarPath.startsWith('/http') || avatarPath.startsWith('http')) {
              avatarUrl = avatarPath.startsWith('/') ? avatarPath.substring(1) : avatarPath;
            } else {
              // If it's a TMDB path
              avatarUrl = 'https://image.tmdb.org/t/p/w185$avatarPath';
            }
          } else {
            // Fallback to ui-avatars
            avatarUrl = 'https://ui-avatars.com/api/?name=${(review['author']?.toString() ?? 'Anonymous').replaceAll(' ', '+')}&background=random';
          }
          
          final reviewData = {
            'movieTitle': movie.title ?? 'Untitled Movie',
            'movieId': movie.id ?? '',
            'posterPath': movie.posterUrl ?? '',
            'author': authorDetails['name']?.toString() ?? review['author']?.toString() ?? 'Anonymous',
            'avatarUrl': avatarUrl,
            'rating': (authorDetails['rating'] ?? 0) / 2,
            'content': review['content']?.toString() ?? 'No review content available',
            'createdAt': review['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          };
          
          print('[Home] Processed review data: $reviewData');
          allReviews.add(reviewData);
        } else {
          print('[Home] No reviews found for movie $i');
        }
      }
      
      print('[Home] Total reviews processed: ${allReviews.length}');
      recentReviews = allReviews;
      update();
    } catch (e, stackTrace) {
      print('[Home] Error in loadReviews: $e');
      print('[Home] Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load reviews: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore = false;
      update();
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