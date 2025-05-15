import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class ListDetailsController extends GetxController {
  final String listId;
  bool _isLoading = false;
  String? _error;
  List<Movie> _movies = [];

  ListDetailsController({required this.listId});

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void onInit() {
    super.onInit();
    fetchListDetails();
  }

  Future<void> fetchListDetails() async {
    try {
      _isLoading = true;
      _error = null;
      update();

      final result = await TMDBService.getListDetails(listId);
      if (result['success']) {
        _movies = result['movies'];
      } else {
        throw Exception('Failed to load list details');
      }
    } catch (e) {
      print('[ListDetailsController] Error fetching list details: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  void refreshList() {
    fetchListDetails();
  }
} 