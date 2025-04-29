import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';

class ExploreController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<Movie> searchResults = <Movie>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasSearched = false.obs;
  final RxList<String> searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load search history from storage
    loadSearchHistory();
  }

  void loadSearchHistory() {
    // TODO: Implement loading from storage
    // For now, using a mock list
    searchHistory.value = [];
  }

  void saveSearchHistory() {
    // TODO: Implement saving to storage
  }

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;
    
    // Remove if already exists
    searchHistory.remove(query);
    // Add to beginning of list
    searchHistory.insert(0, query);
    // Keep only last 10 searches
    if (searchHistory.length > 10) {
      searchHistory.removeLast();
    }
    saveSearchHistory();
  }

  void removeFromHistory(String query) {
    searchHistory.remove(query);
    saveSearchHistory();
  }

  void clearHistory() {
    searchHistory.clear();
    saveSearchHistory();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    hasSearched.value = false;
    hasError.value = false;
    errorMessage.value = '';
  }

  Future<void> performSearch() async {
    if (searchQuery.value.isEmpty) return;
    
    try {
      isLoading.value = true;
      hasError.value = false;
      hasSearched.value = true;
      
      final results = await TMDBService.searchMovies(searchQuery.value);
      searchResults.value = results;
      
      // Add to history after successful search
      addToHistory(searchQuery.value);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to search movies: ${e.toString()}';
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }
} 