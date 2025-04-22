import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/api_service.dart';

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static final String _apiKey = ApiService.apiKey;
  static const Duration _timeout = Duration(seconds: 10);
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // Cache for API responses
  static final Map<String, _CacheEntry> _cache = {};
  
  // Rate limiting
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 200);

  static String getImageUrl(String path, {String size = 'w500'}) {
    return '${ApiService.imageBaseUrl}/$size$path';
  }

  static Future<T> _makeRequest<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> data) parser,
    bool useCache = true,
  }) async {
    print('\n[TMDB API] Request started: $endpoint');
    print('[TMDB API] Cache enabled: $useCache');

    // Rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        print('[TMDB API] Rate limiting applied. Waiting ${_minRequestInterval - timeSinceLastRequest}');
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }
    _lastRequestTime = DateTime.now();

    // Check cache
    if (useCache && _cache.containsKey(endpoint)) {
      final cacheEntry = _cache[endpoint]!;
      if (DateTime.now().difference(cacheEntry.timestamp) < _cacheDuration) {
        print('[TMDB API] Cache hit: $endpoint');
        print('[TMDB API] Cache age: ${DateTime.now().difference(cacheEntry.timestamp)}');
        return cacheEntry.data as T;
      }
      print('[TMDB API] Cache expired: $endpoint');
    }

    try {
      print('[TMDB API] Sending request to: $_baseUrl$endpoint');
      final startTime = DateTime.now();
      
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
      ).timeout(_timeout);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('[TMDB API] Response received in ${duration.inMilliseconds}ms');
      print('[TMDB API] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = parser(data);
        
        // Cache the result
        if (useCache) {
          _cache[endpoint] = _CacheEntry(result, DateTime.now());
          print('[TMDB API] Response cached');
        }
        
        print('[TMDB API] Request completed successfully\n');
        return result;
      } else {
        print('[TMDB API] Request failed with status ${response.statusCode}');
        print('[TMDB API] Error response: ${response.body}\n');
        throw Exception('API request failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('[TMDB API] Error occurred: ${e.toString()}');
      
      // If request fails and we have cached data, return it
      if (useCache && _cache.containsKey(endpoint)) {
        print('[TMDB API] Returning cached data due to error');
        return _cache[endpoint]!.data as T;
      }
      
      print('[TMDB API] Request failed with error: ${e.toString()}\n');
      rethrow;
    }
  }

  static Future<List<Movie>> getPopularMovies() async {
    return _makeRequest<List<Movie>>(
      endpoint: '/movie/popular?api_key=$_apiKey&language=en-US&page=1',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
    );
  }

  static Future<Movie> getMovieDetails(int movieId) async {
    return _makeRequest<Movie>(
      endpoint: '/movie/$movieId?api_key=$_apiKey&language=en-US',
      parser: (data) => Movie.fromJson(data),
    );
  }

  static Future<List<Movie>> getSimilarMovies(int movieId) async {
    return _makeRequest<List<Movie>>(
      endpoint: '/movie/$movieId/similar?api_key=$_apiKey&language=en-US',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
    );
  }

  static Future<List<Movie>> getRecommendedMovies(int movieId) async {
    return _makeRequest<List<Movie>>(
      endpoint: '/movie/$movieId/recommendations?api_key=$_apiKey&language=en-US',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
    );
  }

  static Future<List<Map<String, dynamic>>> getMovieCredits(int movieId) async {
    return _makeRequest<List<Map<String, dynamic>>>(
      endpoint: '/movie/$movieId/credits?api_key=$_apiKey&language=en-US',
      parser: (data) => List<Map<String, dynamic>>.from(data['cast']),
    );
  }

  static Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    return _makeRequest<List<Movie>>(
      endpoint: '/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=1',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
      useCache: false, // Don't cache search results
    );
  }

  static Future<List<Movie>> getTrendingMovies() async {
    return _makeRequest<List<Movie>>(
      endpoint: '/trending/movie/week?api_key=$_apiKey&language=en-US',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
    );
  }

  static Future<List<Map<String, dynamic>>> getMovieReviews(int movieId) async {
    return _makeRequest<List<Map<String, dynamic>>>(
      endpoint: '/movie/$movieId/reviews?api_key=$_apiKey&language=en-US&page=1',
      parser: (data) => List<Map<String, dynamic>>.from(data['results']),
    );
  }

  static Future<List<Movie>> getAccountWatchlist(int accountId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/account/$accountId/watchlist/movies?api_key=$_apiKey&language=en-US&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();
    } else {
      throw Exception('Failed to load watchlist');
    }
  }

  static Future<bool> addToWatchlist(int accountId, int movieId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/account/$accountId/watchlist'),
      body: json.encode({
        'media_type': 'movie',
        'media_id': movieId,
        'watchlist': true,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to add to watchlist');
    }
  }

  static Future<bool> removeFromWatchlist(int accountId, int movieId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/account/$accountId/watchlist'),
      body: json.encode({
        'media_type': 'movie',
        'media_id': movieId,
        'watchlist': false,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to remove from watchlist');
    }
  }

  static Future<bool> getMovieWatchlistStatus(int movieId, int accountId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/account_states?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['watchlist'] ?? false;
    } else {
      throw Exception('Failed to get watchlist status');
    }
  }

  static Future<bool> rateMovie(int movieId, double rating) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/movie/$movieId/rating'),
      body: json.encode({
        'value': rating,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to rate movie');
    }
  }

  static Future<bool> deleteRating(int movieId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/movie/$movieId/rating'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete rating');
    }
  }

  static Future<List<Map<String, dynamic>>> getMovieGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['genres']);
    } else {
      throw Exception('Failed to load movie genres');
    }
  }

  static Future<List<Movie>> discoverMoviesByGenre(int genreId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&language=en-US&with_genres=$genreId&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();
    } else {
      throw Exception('Failed to discover movies by genre');
    }
  }

  static Future<List<Map<String, dynamic>>> getPopularCollections() async {
    print('[TMDB API] Getting popular movies...');
    return _makeRequest<List<Map<String, dynamic>>>(
      endpoint: '/movie/popular?api_key=$_apiKey&language=en-US&page=1',
      parser: (data) {
        print('[TMDB API] Parsing ${(data['results'] as List).length} movies');
        final movies = data['results'] as List;
        return movies.take(10).map((movie) => {
          'title': movie['title'],
          'author': 'Rating: ${(movie['vote_average'] as num).toStringAsFixed(1)}/10',
          'poster_path': movie['poster_path'],
          'id': movie['id'],
          'overview': movie['overview'],
          'vote_average': movie['vote_average'],
          'release_date': movie['release_date'],
        }).toList();
      },
    );
  }

  // Clear cache
  static void clearCache() {
    _cache.clear();
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry(this.data, this.timestamp);
} 