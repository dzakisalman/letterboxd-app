import 'package:get/get.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class ListsController extends GetxController {
  final _lists = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;
  final _error = RxnString();

  List<Map<String, dynamic>> get lists => _lists;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    fetchLists();
  }

  Future<void> fetchLists() async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final authController = Get.find<AuthController>();
      final sessionId = authController.sessionId;

      if (sessionId == null) {
        throw Exception('User not logged in');
      }

      final lists = await TMDBService.getLists(sessionId);
      _lists.value = lists;
    } catch (e) {
      print('[ListsController] Error fetching lists: $e');
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshLists() {
    fetchLists();
  }
} 