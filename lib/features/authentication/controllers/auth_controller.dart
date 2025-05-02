import 'package:get/get.dart';
import 'package:letterboxd/core/models/user.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthController extends GetxController {
  final Rx<User?> _currentUser = Rx<User?>(null);
  final _isLoading = false.obs;
  late SharedPreferences _prefs;
  String? _sessionId;

  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;
  String? get sessionId => _sessionId;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userJson = _prefs.getString('user');
      final sessionId = _prefs.getString('session_id');
      
      if (userJson != null && sessionId != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser.value = User.fromJson(userMap);
        _sessionId = sessionId;
      }
    } catch (e) {
      // If there's an error loading the user, clear the stored data
      await _clearStoredData();
      Get.snackbar(
        'Error',
        'Failed to load user data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _clearStoredData() async {
    await _prefs.remove('user');
    await _prefs.remove('session_id');
    await _prefs.remove('has_seen_onboarding'); // Clear onboarding status
    _currentUser.value = null;
    _sessionId = null;
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
      final tmdbAvatar = accountDetails['avatar']?['tmdb']?['avatar_path'];
      final gravatarHash = accountDetails['avatar']?['gravatar']?['hash'];
      String? profileImageUrl;
      if (tmdbAvatar != null && tmdbAvatar is String && tmdbAvatar.isNotEmpty) {
        profileImageUrl = tmdbAvatar.startsWith('/')
          ? 'https://image.tmdb.org/t/p/w185$tmdbAvatar'
          : tmdbAvatar;
      } else if (gravatarHash != null && gravatarHash is String && gravatarHash.isNotEmpty) {
        profileImageUrl = 'https://www.gravatar.com/avatar/$gravatarHash';
      }
      final user = User(
        id: accountDetails['id'].toString(),
        name: accountDetails['name'] ?? '',
        username: accountDetails['username'],
        email: accountDetails['email'] ?? '',
        profileImage: profileImageUrl,
        watchedMovies: accountDetails['movie_count'] ?? 0,
        reviews: accountDetails['review_count'] ?? 0,
        followers: accountDetails['followers_count'] ?? 0,
        following: accountDetails['following_count'] ?? 0,
      );

      _currentUser.value = user;

      // Save user data and session ID
      await _prefs.setString('user', json.encode(user.toJson()));
      await _prefs.setString('session_id', _sessionId!);

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
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
      
      await _clearStoredData();
      Get.offAllNamed('/onboarding'); // Navigate to onboarding instead of login
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