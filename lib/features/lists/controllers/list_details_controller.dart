import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class ListDetailsController extends GetxController {
  final String listId;
  final _isLoading = false.obs;
  final _error = RxnString();
  final _movies = <Movie>[].obs;

  ListDetailsController({required this.listId});

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    fetchListDetails();
  }

  Future<void> fetchListDetails() async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await TMDBService.getListDetails(listId);
      if (result['success']) {
        _movies.value = result['movies'];
      } else {
        throw Exception('Failed to load list details');
      }
    } catch (e) {
      print('[ListDetailsController] Error fetching list details: $e');
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshList() {
    fetchListDetails();
  }
} 