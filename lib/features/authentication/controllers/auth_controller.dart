import 'package:get/get.dart';
import 'package:letterboxd/core/models/user.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthController extends GetxController {
  final Rx<User?> _currentUser = Rx<User?>(null);
  final _isLoading = false.obs;
  final _prefs = SharedPreferences.getInstance();
  String? _sessionId;

  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString('user');
    final sessionId = prefs.getString('session_id');
    
    if (userJson != null && sessionId != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser.value = User.fromJson(userMap);
        _sessionId = sessionId;
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to load user data: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading.value = true;

      // Step 1: Create request token
      final requestTokenResponse = await TMDBService.createRequestToken();
      final requestToken = requestTokenResponse['request_token'];

      // Step 2: Validate request token with login credentials
      final validateResponse = await TMDBService.validateRequestToken(
        requestToken,
        username,
        password,
      );

      if (!validateResponse['success']) {
        throw Exception('Invalid credentials');
      }

      // Step 3: Create session
      final sessionResponse = await TMDBService.createSession(requestToken);
      _sessionId = sessionResponse['session_id'];

      // Step 4: Get account details
      final accountDetails = await TMDBService.getAccountDetails(_sessionId!);

      // Create user object
      final user = User(
        id: accountDetails['id'].toString(),
        username: accountDetails['username'],
        email: accountDetails['email'] ?? '',
        profileImage: accountDetails['avatar']?['tmdb']?['avatar_path'],
        watchedMovies: accountDetails['movie_count'] ?? 0,
        reviews: accountDetails['review_count'] ?? 0,
        followers: accountDetails['followers_count'] ?? 0,
        following: accountDetails['following_count'] ?? 0,
      );

      _currentUser.value = user;

      // Save user data and session ID
      final prefs = await _prefs;
      await prefs.setString('user', json.encode(user.toJson()));
      await prefs.setString('session_id', _sessionId!);

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to login: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      if (_sessionId != null) {
        await TMDBService.deleteSession(_sessionId!);
      }
      
      _currentUser.value = null;
      _sessionId = null;
      
      final prefs = await _prefs;
      await prefs.remove('user');
      await prefs.remove('session_id');
      
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> signup(String username, String email, String password) async {
    try {
      _isLoading.value = true;
      
      // Note: TMDB does not provide a signup API endpoint.
      // Users need to create an account directly on the TMDB website.
      Get.snackbar(
        'Sign Up Not Available',
        'Please create an account on the TMDB website (https://www.themoviedb.org/signup)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to signup: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
} 