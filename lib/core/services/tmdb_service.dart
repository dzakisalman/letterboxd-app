import 'package:dio/dio.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/api_service.dart';

class TMDBService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiService.baseUrl,
    queryParameters: {'api_key': ApiService.apiKey},
  ));

  static String getImageUrl(String path, {String size = 'w500'}) {
    return '${ApiService.imageBaseUrl}/$size$path';
  }

  static Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await _dio.get('/movie/popular');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  static Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId');
      return Movie.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  static Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/similar');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load similar movies: $e');
    }
  }

  static Future<List<Movie>> getRecommendedMovies(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/recommendations');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load recommended movies: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMovieCredits(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/credits');
      return List<Map<String, dynamic>>.from(response.data['cast']);
    } catch (e) {
      throw Exception('Failed to load movie credits: $e');
    }
  }

  static Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'include_adult': false,
        },
      );
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  static Future<List<Movie>> getTrendingMovies({String timeWindow = 'week'}) async {
    try {
      final response = await _dio.get('/trending/movie/$timeWindow');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load trending movies: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMovieReviews(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/reviews');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } catch (e) {
      throw Exception('Failed to load movie reviews: $e');
    }
  }

  static Future<List<Movie>> getAccountWatchlist(int accountId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/account/$accountId/watchlist/movies',
        queryParameters: {'page': page},
      );
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load watchlist: $e');
    }
  }

  static Future<bool> addToWatchlist(int accountId, int movieId) async {
    try {
      final response = await _dio.post(
        '/account/$accountId/watchlist',
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'watchlist': true,
        },
      );
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to add to watchlist: $e');
    }
  }

  static Future<bool> removeFromWatchlist(int accountId, int movieId) async {
    try {
      final response = await _dio.post(
        '/account/$accountId/watchlist',
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'watchlist': false,
        },
      );
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  static Future<bool> getMovieWatchlistStatus(int movieId, int accountId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/account_states',
      );
      return response.data['watchlist'] ?? false;
    } catch (e) {
      throw Exception('Failed to get watchlist status: $e');
    }
  }

  static Future<bool> rateMovie(int movieId, double rating) async {
    try {
      final response = await _dio.post(
        '/movie/$movieId/rating',
        data: {
          'value': rating,
        },
      );
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to rate movie: $e');
    }
  }

  static Future<bool> deleteRating(int movieId) async {
    try {
      final response = await _dio.delete('/movie/$movieId/rating');
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to delete rating: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMovieGenres() async {
    try {
      final response = await _dio.get('/genre/movie/list');
      return List<Map<String, dynamic>>.from(response.data['genres']);
    } catch (e) {
      throw Exception('Failed to load movie genres: $e');
    }
  }

  static Future<List<Movie>> discoverMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': genreId,
          'page': page,
        },
      );
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to discover movies by genre: $e');
    }
  }
} 