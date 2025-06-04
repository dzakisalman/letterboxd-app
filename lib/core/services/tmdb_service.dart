import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/api_service.dart';
import 'package:get/get.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static final String _apiKey = ApiService.apiKey;
  static const Duration _timeout = Duration(seconds: 30);
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
        final cachedData = cacheEntry.data;
        if (cachedData is T) {
          return cachedData;
        } else {
          print('[TMDB API] Cache data type mismatch, clearing cache');
          _cache.remove(endpoint);
        }
      }
      print('[TMDB API] Cache expired: $endpoint');
    }

    try {
      print('[TMDB API] Sending request to: $_baseUrl$endpoint');
      final startTime = DateTime.now();
      
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
      ).timeout(_timeout);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('[TMDB API] Response received in ${duration.inMilliseconds}ms');
      print('[TMDB API] Status code: ${response.statusCode}');
      print('[TMDB API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is! Map<String, dynamic>) {
          throw FormatException('API response is not a Map<String, dynamic>');
        }
        
        final result = parser(data);
        if (result is! T) {
          throw FormatException('Parser returned wrong type: ${result.runtimeType}, expected: $T');
        }
        
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
        final cachedData = _cache[endpoint]!.data;
        if (cachedData is T) {
          print('[TMDB API] Returning cached data due to error');
          return cachedData;
        }
      }
      
      print('[TMDB API] Request failed with error: ${e.toString()}\n');
      rethrow;
    }
  }

  static Future<List<Movie>> getPopularMovies() async {
    print('\n[TMDB] ===== Getting Popular Movies =====');
    return _makeRequest<List<Movie>>(
      endpoint: '/movie/popular?api_key=$_apiKey&language=en-US&page=1',
      parser: (data) {
        try {
          final results = data['results'] as List;
          final movies = <Movie>[];
          
          for (var movieData in results) {
            if (movieData is! Map<String, dynamic>) {
              print('[TMDB] Invalid movie data format: ${movieData.runtimeType}');
              continue;
            }
            
            try {
              final movie = Movie.fromJson(movieData);
              movies.add(movie);
            } catch (e) {
              print('[TMDB] Error converting movie: $e');
              print('[TMDB] Movie data: $movieData');
            }
          }
          
          print('[TMDB] Successfully converted ${movies.length} movies');
          return movies;
        } catch (e) {
          print('[TMDB] Error parsing popular movies: $e');
          throw FormatException('Failed to parse popular movies: $e');
        }
      },
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

  static Future<Map<String, dynamic>> getMovieCredits(int movieId) async {
    return _makeRequest<Map<String, dynamic>>(
      endpoint: '/movie/$movieId/credits?api_key=$_apiKey&language=en-US',
      parser: (data) => data,
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
    print('\n[TMDB] ===== Getting Trending Movies =====');
    return _makeRequest<List<Movie>>(
      endpoint: '/trending/movie/week?api_key=$_apiKey&language=en-US',
      parser: (data) {
        try {
          final results = data['results'] as List;
          final movies = <Movie>[];
          
          for (var movieData in results) {
            if (movieData is! Map<String, dynamic>) {
              print('[TMDB] Invalid movie data format: ${movieData.runtimeType}');
              continue;
            }
            
            try {
              final movie = Movie.fromJson(movieData);
              movies.add(movie);
            } catch (e) {
              print('[TMDB] Error converting movie: $e');
              print('[TMDB] Movie data: $movieData');
            }
          }
          
          print('[TMDB] Successfully converted ${movies.length} movies');
          return movies;
        } catch (e) {
          print('[TMDB] Error parsing trending movies: $e');
          throw FormatException('Failed to parse trending movies: $e');
        }
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getMovieReviews(int movieId) async {
    return _makeRequest<List<Map<String, dynamic>>>(
      endpoint: '/movie/$movieId/reviews?api_key=$_apiKey&language=en-US&page=1',
      parser: (data) {
        try {
          final results = data['results'] as List? ?? [];
          print('[TMDB] Processing ${results.length} reviews');
          
          return results.map((review) {
            final authorDetails = review['author_details'] as Map<String, dynamic>? ?? {};
            final avatarPath = authorDetails['avatar_path']?.toString();
            String? avatarUrl;
            
            print('[TMDB] Processing review for author: ${review['author']}');
            print('[TMDB] Author details: $authorDetails');
            print('[TMDB] Original avatar_path: $avatarPath');
            
            if (avatarPath != null && avatarPath.isNotEmpty) {
              if (avatarPath.startsWith('/http') || avatarPath.startsWith('http')) {
                avatarUrl = avatarPath.startsWith('/') ? avatarPath.substring(1) : avatarPath;
                print('[TMDB] Using full URL avatar: $avatarUrl');
              } else {
                avatarUrl = 'https://image.tmdb.org/t/p/w185$avatarPath';
                print('[TMDB] Using TMDB path avatar: $avatarUrl');
              }
            } else {
              avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(review['author'] ?? 'Anonymous')}&background=random';
              print('[TMDB] Using generated avatar: $avatarUrl');
            }
            
            print('[TMDB] Final avatar URL for ${review['author']}: $avatarUrl');
            
            return {
              'id': review['id']?.toString() ?? '',
              'author': review['author']?.toString() ?? 'Anonymous',
              'content': review['content']?.toString() ?? 'No review content available',
              'created_at': review['created_at']?.toString() ?? DateTime.now().toIso8601String(),
              'author_details': {
                'name': authorDetails['name']?.toString() ?? review['author']?.toString() ?? 'Anonymous',
                'username': authorDetails['username']?.toString() ?? 'anonymous',
                'avatar_path': avatarUrl,
                'rating': authorDetails['rating'] != null ? (authorDetails['rating'] as num).toDouble() : null,
              },
            };
          }).toList();
        } catch (e) {
          print('[TMDB] Error parsing reviews: $e');
          return [];
        }
      },
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
    final authController = Get.find<AuthController>();
    final sessionId = authController.sessionId;
    
    if (sessionId == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/movie/$movieId/rating?api_key=$_apiKey&session_id=$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.accessToken}',
      },
      body: json.encode({
        'value': rating,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('[TMDB] Successfully rated movie. Status code: ${response.statusCode}');
      print('[TMDB] Response body: ${response.body}');
      return true;
    } else {
      print('[TMDB] Failed to rate movie. Status code: ${response.statusCode}');
      print('[TMDB] Response body: ${response.body}');
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

  static Future<List<Movie>> discoverMoviesByGenres(List<int> genreIds, {int page = 1}) async {
    if (genreIds.isEmpty) return [];

    final genreParam = genreIds.join(',');

    return _makeRequest<List<Movie>>(
      endpoint: '/discover/movie?api_key=$_apiKey&language=en-US&with_genres=$genreParam&page=$page',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
      useCache: false, // Don't cache discover results with multiple genres
    );
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

  static Future<Map<String, dynamic>> createRequestToken() async {
    return _makeRequest<Map<String, dynamic>>(
      endpoint: '/authentication/token/new?api_key=$_apiKey',
      parser: (data) => data,
      useCache: false,
    );
  }

  static Future<Map<String, dynamic>> validateRequestToken(String requestToken, String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/authentication/token/validate_with_login?api_key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'request_token': requestToken,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to validate request token');
    }
  }

  static Future<Map<String, dynamic>> createSession(String requestToken) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/authentication/session/new?api_key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'request_token': requestToken,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create session');
    }
  }

  static Future<Map<String, dynamic>> getAccountDetails(String sessionId) async {
    return _makeRequest<Map<String, dynamic>>(
      endpoint: '/account?api_key=$_apiKey&session_id=$sessionId',
      parser: (data) => data,
      useCache: false,
    );
  }

  static Future<void> deleteSession(String sessionId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/authentication/session?api_key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'session_id': sessionId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete session');
    }
  }

  static Future<List<Movie>> getFavoriteMovies(String sessionId) async {
    return _makeRequest<List<Movie>>(
      endpoint: '/account/account_id/favorite/movies?api_key=$_apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.desc&page=1',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
      useCache: false,
    );
  }

  static Future<List<Movie>> getRatedMovies(String sessionId) async {
    try {
      print('[TMDB] Getting rated movies...');
      
      // Get account details first to get the account ID
      final accountDetails = await getAccountDetails(sessionId);
      final accountId = accountDetails['id'];

      print('[TMDB] Got account ID: $accountId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/account/$accountId/rated/movies?api_key=$_apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.desc&page=1'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
      ).timeout(_timeout);

      print('[TMDB] Rated movies response status: ${response.statusCode}');
      print('[TMDB] Rated movies response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final movies = results.map((movie) => Movie.fromJson(movie)).toList();
        print('[TMDB] Successfully parsed ${movies.length} rated movies');
        return movies;
      } else {
        print('[TMDB] Failed to get rated movies. Status: ${response.statusCode}');
        throw Exception('Failed to get rated movies. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[TMDB] Error getting rated movies: $e');
      rethrow;
    }
  }

  static Future<bool> markAsFavorite(String sessionId, int movieId, bool favorite) async {
    try {
      final accountDetails = await getAccountDetails(sessionId);
      final accountId = accountDetails['id'];

      print('[TMDB] Marking movie $movieId as favorite: $favorite');
      print('[TMDB] Account ID: $accountId');
      print('[TMDB] Session ID: $sessionId');

      final response = await http.post(
        Uri.parse('$_baseUrl/account/$accountId/favorite?api_key=$_apiKey&session_id=$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
        body: json.encode({
          'media_type': 'movie',
          'media_id': movieId,
          'favorite': favorite,
        }),
      );

      print('[TMDB] Favorite response status: ${response.statusCode}');
      print('[TMDB] Favorite response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to mark movie as favorite. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('[TMDB] Error marking as favorite: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAccountStates(int movieId) async {
    final authController = Get.find<AuthController>();
    final sessionId = authController.sessionId;
    
    if (sessionId == null) {
      return {
        'rated': null,
        'watchlist': false,
        'favorite': false,
      };
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/account_states?api_key=$_apiKey&session_id=$sessionId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get account states');
    }
  }

  static Future<bool> addToFavorites(int movieId) async {
    const accountId = 1; // TODO: Get from auth
    final response = await http.post(
      Uri.parse('$_baseUrl/account/$accountId/favorite?api_key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'media_type': 'movie',
        'media_id': movieId,
        'favorite': true,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to add movie to favorites');
    }
  }

  static Future<bool> removeFromFavorites(int movieId) async {
    const accountId = 1; // TODO: Get from auth
    final response = await http.post(
      Uri.parse('$_baseUrl/account/$accountId/favorite?api_key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'media_type': 'movie',
        'media_id': movieId,
        'favorite': false,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to remove movie from favorites');
    }
  }

  static Future<bool> markAsWatchlist(String sessionId, int movieId, bool watchlist) async {
    try {
      final accountDetails = await getAccountDetails(sessionId);
      final accountId = accountDetails['id'];

      print('[TMDB] Marking movie $movieId as watchlist: $watchlist');
      print('[TMDB] Account ID: $accountId');
      print('[TMDB] Session ID: $sessionId');

      final response = await http.post(
        Uri.parse('$_baseUrl/account/$accountId/watchlist?api_key=$_apiKey&session_id=$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
        body: json.encode({
          'media_type': 'movie',
          'media_id': movieId,
          'watchlist': watchlist,
        }),
      );

      print('[TMDB] Watchlist response status: ${response.statusCode}');
      print('[TMDB] Watchlist response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to update watchlist. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('[TMDB] Error marking as watchlist: $e');
      rethrow;
    }
  }

  // Clear cache
  static void clearCache() {
    _cache.clear();
  }

  static Future<String?> getMoviePoster(String tmdbId) async {
    try {
      return _makeRequest<String?>(
        endpoint: '/movie/$tmdbId?api_key=$_apiKey&language=en-US',
        parser: (data) {
          final posterPath = data['poster_path'] as String?;
          if (posterPath != null) {
            return getImageUrl(posterPath, size: 'w300');
          }
          return null;
        },
      );
    } catch (e) {
      print('[TMDB API] Error getting movie poster: $e');
      return null;
    }
  }

  static Future<List<Movie>> getWatchlist(String sessionId) async {
    try {
      print('[TMDB] Getting watchlist...');
      
      // Get account details first to get the account ID
      final accountDetails = await getAccountDetails(sessionId);
      final accountId = accountDetails['id'];

      print('[TMDB] Got account ID: $accountId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/account/$accountId/watchlist/movies?api_key=$_apiKey&session_id=$sessionId&language=en-US&sort_by=created_at.desc&page=1'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
      ).timeout(_timeout);

      print('[TMDB] Watchlist response status: ${response.statusCode}');
      print('[TMDB] Watchlist response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final movies = results.map((movie) => Movie.fromJson(movie)).toList();
        print('[TMDB] Successfully parsed ${movies.length} watchlist movies');
        return movies;
      } else {
        print('[TMDB] Failed to get watchlist. Status: ${response.statusCode}');
        throw Exception('Failed to get watchlist. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[TMDB] Error getting watchlist: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addMoviesToList(String listId, List<Movie> movies) async {
    print('\n[TMDB] ===== Adding Movies to List =====');
    print('[TMDB] List ID: $listId');
    print('[TMDB] Number of movies to add: ${movies.length}');
    movies.forEach((movie) {
      print('[TMDB] - ${movie.title} (ID: ${movie.id})');
    });

    try {
      // Get session ID from auth controller
      final authController = Get.find<AuthController>();
      final sessionId = authController.sessionId;
      
      if (sessionId == null) {
        throw Exception('User not logged in');
      }

      print('[TMDB] Session ID: $sessionId');
      print('[TMDB] Sending request to add movies...');
      
      // Add movies one by one to avoid potential issues with bulk adding
      for (final movie in movies) {
        print('[TMDB] Adding movie: ${movie.title} (ID: ${movie.id})');
        
        final response = await http.post(
          Uri.parse('$_baseUrl/list/$listId/add_item?api_key=$_apiKey&session_id=$sessionId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiService.accessToken}',
          },
          body: jsonEncode({
            'media_id': movie.id,
            'media_type': 'movie',
          }),
        );

        print('[TMDB] Response status code: ${response.statusCode}');
        print('[TMDB] Response body: ${response.body}');

        if (response.statusCode != 201) {
          final responseData = jsonDecode(response.body);
          final errorMessage = responseData['status_message'] ?? 'Failed to add movie to list';
          print('[TMDB] Failed to add movie ${movie.title}. Error: $errorMessage');
          return {
            'success': false,
            'error_code': responseData['status_code'] ?? 500,
            'error_message': errorMessage,
          };
        }
      }

      print('[TMDB] All movies added successfully');
      return {
        'success': true,
        'message': 'Movies added successfully',
      };
    } catch (e) {
      print('[TMDB] Exception occurred while adding movies: $e');
      return {
        'success': false,
        'error_code': 500,
        'error_message': 'An unexpected error occurred. Please try again later.',
      };
    } finally {
      print('[TMDB] ===== End Add Movies Process =====\n');
    }
  }

  static Future<Map<String, dynamic>> createList({
    required String name,
    required String description,
    String language = 'id',
    List<Movie> items = const [],
  }) async {
    print('\n[TMDB] ===== Creating New List =====');
    print('[TMDB] List Name: $name');
    print('[TMDB] Description: $description');
    print('[TMDB] Language: $language');
    print('[TMDB] Number of items: ${items.length}');
    items.forEach((movie) {
      print('[TMDB] - ${movie.title} (ID: ${movie.id})');
    });

    try {
      // Get session ID from auth controller
      final authController = Get.find<AuthController>();
      final sessionId = authController.sessionId;
      
      if (sessionId == null) {
        throw Exception('User not logged in');
      }

      print('[TMDB] Session ID: $sessionId');
      print('[TMDB] Sending request to create list...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/list?api_key=$_apiKey&session_id=$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'language': language,
        }),
      );

      print('[TMDB] Response status code: ${response.statusCode}');
      print('[TMDB] Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final listId = responseData['list_id'].toString();
        print('[TMDB] List created successfully with ID: $listId');

        // Add movies to the list if there are any
        if (items.isNotEmpty) {
          final addResult = await addMoviesToList(listId, items);
          if (!addResult['success']) {
            print('[TMDB] Warning: Failed to add movies to list: ${addResult['error_message']}');
          }
        }

        return {
          'success': true,
          'list_id': listId,
          'message': 'List created successfully',
        };
      } else {
        // Handle error response
        final errorMessage = responseData['errors'] != null && (responseData['errors'] as List).isNotEmpty
            ? (responseData['errors'] as List).first.toString()
            : responseData['status_message'] ?? 'Failed to create list';
            
        print('[TMDB] Failed to create list. Error: $errorMessage');
        return {
          'success': false,
          'error_code': responseData['status_code'] ?? 500,
          'error_message': errorMessage,
        };
      }
    } catch (e) {
      print('[TMDB] Exception occurred while creating list: $e');
      return {
        'success': false,
        'error_code': 500,
        'error_message': 'An unexpected error occurred. Please try again later.',
      };
    } finally {
      print('[TMDB] ===== End Create List Process =====\n');
    }
  }

  static Future<List<Map<String, dynamic>>> getLists(String sessionId) async {
    print('\n[TMDB] ===== Getting User Lists =====');
    try {
      // Get account details first to get the account ID
      final accountDetails = await getAccountDetails(sessionId);
      final accountId = accountDetails['id'];

      print('[TMDB] Got account ID: $accountId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/account/$accountId/lists?api_key=$_apiKey&session_id=$sessionId&language=en-US&page=1'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
      ).timeout(_timeout);

      print('[TMDB] Lists response status: ${response.statusCode}');
      print('[TMDB] Lists response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final lists = results.map((list) => {
          'id': list['id'],
          'name': list['name'],
          'description': list['description'],
          'item_count': list['item_count'],
          'created_at': list['created_at'],
          'updated_at': list['updated_at'],
        }).toList();
        
        print('[TMDB] Successfully parsed ${lists.length} lists');
        return lists;
      } else {
        print('[TMDB] Failed to get lists. Status: ${response.statusCode}');
        throw Exception('Failed to get lists. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[TMDB] Error getting lists: $e');
      rethrow;
    } finally {
      print('[TMDB] ===== End Get Lists Process =====\n');
    }
  }

  static Future<Map<String, dynamic>> getListDetails(String listId) async {
    print('\n[TMDB] ===== Getting List Details =====');
    print('[TMDB] List ID: $listId');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/list/$listId?api_key=$_apiKey&language=en-US'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
      ).timeout(_timeout);

      print('[TMDB] Response status: ${response.statusCode}');
      print('[TMDB] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        final movies = items.map((movie) => Movie.fromJson(movie)).toList();
        
        print('[TMDB] Successfully parsed ${movies.length} movies');
        return {
          'success': true,
          'list': {
            'id': data['id'],
            'name': data['name'],
            'description': data['description'],
            'created_by': data['created_by'],
            'item_count': data['item_count'],
            'created_at': data['created_at'],
            'updated_at': data['updated_at'],
          },
          'movies': movies,
        };
      } else {
        print('[TMDB] Failed to get list details. Status: ${response.statusCode}');
        throw Exception('Failed to get list details. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[TMDB] Error getting list details: $e');
      rethrow;
    } finally {
      print('[TMDB] ===== End Get List Details Process =====\n');
    }
  }

  static Future<Map<String, dynamic>> updateList({
    required String listId,
    required String name,
    required String description,
    String language = 'id',
  }) async {
    print('\n[TMDB] ===== Updating List =====');
    print('[TMDB] List ID: $listId');
    print('[TMDB] New Name: $name');
    print('[TMDB] New Description: $description');
    print('[TMDB] Language: $language');

    try {
      final authController = Get.find<AuthController>();
      final sessionId = authController.sessionId;
      
      if (sessionId == null) {
        throw Exception('User not logged in');
      }

      print('[TMDB] Session ID: $sessionId');
      print('[TMDB] Sending request to update list...');

      // Pertama, cek apakah list ada
      final checkResponse = await http.get(
        Uri.parse('$_baseUrl/list/$listId?api_key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
      );

      print('[TMDB] Check list response status: ${checkResponse.statusCode}');
      print('[TMDB] Check list response body: ${checkResponse.body}');

      if (checkResponse.statusCode != 200) {
        throw Exception('List not found or not accessible');
      }
      
      // Update list menggunakan endpoint yang benar
      final response = await http.post(
        Uri.parse('$_baseUrl/list/$listId?api_key=$_apiKey&session_id=$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'language': language,
        }),
      );

      print('[TMDB] Update response status code: ${response.statusCode}');
      print('[TMDB] Update response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('[TMDB] List updated successfully');
        return {
          'success': true,
          'message': 'List updated successfully',
        };
      } else {
        final errorMessage = responseData['status_message'] ?? 'Failed to update list';
        print('[TMDB] Failed to update list. Error: $errorMessage');
        return {
          'success': false,
          'error_code': responseData['status_code'] ?? 500,
          'error_message': errorMessage,
        };
      }
    } catch (e) {
      print('[TMDB] Exception occurred while updating list: $e');
      return {
        'success': false,
        'error_code': 500,
        'error_message': 'An unexpected error occurred. Please try again later.',
      };
    } finally {
      print('[TMDB] ===== End Update List Process =====\n');
    }
  }

  static Future<Map<String, dynamic>> removeMovieFromList(String listId, int movieId) async {
    print('\n[TMDB] ===== Removing Movie from List =====');
    print('[TMDB] List ID: $listId');
    print('[TMDB] Movie ID: $movieId');

    try {
      final authController = Get.find<AuthController>();
      final sessionId = authController.sessionId;
      
      if (sessionId == null) {
        throw Exception('User not logged in');
      }

      print('[TMDB] Session ID: $sessionId');
      print('[TMDB] Sending request to remove movie...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/list/$listId/remove_item?api_key=$_apiKey&session_id=$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.accessToken}',
        },
        body: jsonEncode({
          'media_id': movieId,
          'media_type': 'movie',
        }),
      );

      print('[TMDB] Response status code: ${response.statusCode}');
      print('[TMDB] Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('[TMDB] Movie removed successfully');
        return {
          'success': true,
          'message': 'Movie removed successfully',
        };
      } else {
        final errorMessage = responseData['status_message'] ?? 'Failed to remove movie from list';
        print('[TMDB] Failed to remove movie. Error: $errorMessage');
        return {
          'success': false,
          'error_code': responseData['status_code'] ?? 500,
          'error_message': errorMessage,
        };
      }
    } catch (e) {
      print('[TMDB] Exception occurred while removing movie: $e');
      return {
        'success': false,
        'error_code': 500,
        'error_message': 'An unexpected error occurred. Please try again later.',
      };
    } finally {
      print('[TMDB] ===== End Remove Movie Process =====\n');
    }
  }

  static Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    return _makeRequest<List<Map<String, dynamic>>>(
      endpoint: '/movie/$movieId/videos?api_key=$_apiKey&language=en-US',
      parser: (data) {
        try {
          final results = data['results'] as List? ?? [];
          print('[TMDB] Processing ${results.length} videos');
          
          return results.map((video) => {
            'id': video['id']?.toString() ?? '',
            'key': video['key']?.toString() ?? '',
            'name': video['name']?.toString() ?? '',
            'site': video['site']?.toString() ?? '',
            'type': video['type']?.toString() ?? '',
            'size': video['size']?.toString() ?? '',
          }).toList();
        } catch (e) {
          print('[TMDB] Error parsing videos: $e');
          return [];
        }
      },
    );
  }

  static Future<List<Movie>> searchMoviesWithGenres(String query, List<int> genreIds) async {
    if (query.isEmpty && genreIds.isEmpty) return [];

    final genreParam = genreIds.isNotEmpty ? '&with_genres=${genreIds.join(',')}' : '';
    final queryParam = query.isNotEmpty ? '&query=${Uri.encodeComponent(query)}' : '';

    return _makeRequest<List<Movie>>(
      endpoint: '/discover/movie?api_key=$_apiKey&language=en-US$genreParam$queryParam&page=1',
      parser: (data) => (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
      useCache: false, // Don't cache search results
    );
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry(this.data, this.timestamp);
} 