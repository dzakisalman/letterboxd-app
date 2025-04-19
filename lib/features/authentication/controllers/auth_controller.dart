import 'package:get/get.dart';
import 'package:letterboxd/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthController extends GetxController {
  final Rx<User?> _currentUser = Rx<User?>(null);
  final _isLoading = false.obs;
  final _prefs = SharedPreferences.getInstance();

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
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser.value = User.fromJson(userMap);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to load user data: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      // TODO: Implement actual API call
      // For now, we'll use dummy data
      await Future.delayed(const Duration(seconds: 2));
      
      final user = User(
        id: '1',
        username: 'testuser',
        email: email,
      );
      
      _currentUser.value = user;
      final prefs = await _prefs;
      await prefs.setString('user', json.encode(user.toJson()));
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

  Future<bool> signup(String username, String email, String password) async {
    try {
      _isLoading.value = true;
      // TODO: Implement actual API call
      // For now, we'll use dummy data
      await Future.delayed(const Duration(seconds: 2));
      
      final user = User(
        id: '1',
        username: username,
        email: email,
      );
      
      _currentUser.value = user;
      final prefs = await _prefs;
      await prefs.setString('user', json.encode(user.toJson()));
      return true;
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

  Future<void> logout() async {
    _currentUser.value = null;
    final prefs = await _prefs;
    await prefs.remove('user');
  }
} 