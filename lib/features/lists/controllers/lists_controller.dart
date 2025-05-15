import 'package:get/get.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class ListsController extends GetxController {
  List<Map<String, dynamic>> _lists = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get lists => _lists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void onInit() {
    super.onInit();
    fetchLists();
  }

  Future<void> fetchLists() async {
    try {
      _isLoading = true;
      _error = null;
      update();

      final authController = Get.find<AuthController>();
      final sessionId = authController.sessionId;

      if (sessionId == null) {
        throw Exception('User not logged in');
      }

      final lists = await TMDBService.getLists(sessionId);
      _lists = lists;
    } catch (e) {
      print('[ListsController] Error fetching lists: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  void refreshLists() {
    fetchLists();
  }
} 