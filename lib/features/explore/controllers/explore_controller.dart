import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class ExploreController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<Movie> searchResults = <Movie>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasSearched = false.obs;
  final RxList<String> searchHistory = <String>[].obs;
  final RxList<Map<String, dynamic>> selectedGenres = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> availableGenres = <Map<String, dynamic>>[].obs;
  
  Timer? _debounce;
  static const String _searchHistoryKey = 'search_history';
  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    _loadGenres();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadSearchHistory();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await TMDBService.getMovieGenres();
      availableGenres.value = genres;
    } catch (e) {
      print('Error loading genres: $e');
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void loadSearchHistory() {
    final List<String>? history = _prefs.getStringList(_searchHistoryKey);
    if (history != null) {
      searchHistory.value = history;
    }
  }

  void saveSearchHistory() {
    _prefs.setStringList(_searchHistoryKey, searchHistory);
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
    
    // Cancel any existing timer
    _debounce?.cancel();
    
    // If query is empty, clear results
    if (query.isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      return;
    }
    
    // Set up a new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      performSearch();
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    hasSearched.value = false;
    hasError.value = false;
    errorMessage.value = '';
  }

  void toggleGenre(Map<String, dynamic> genre) {
    if (selectedGenres.contains(genre)) {
      selectedGenres.remove(genre);
    } else {
      selectedGenres.add(genre);
    }
    performSearch();
  }

  void clearGenres() {
    selectedGenres.clear();
    performSearch();
  }

  Future<void> performSearch() async {
    if (searchQuery.value.isEmpty && selectedGenres.isEmpty) return;
    
    try {
      isLoading.value = true;
      hasError.value = false;
      hasSearched.value = true;
      
      List<Movie> results = [];
      
      if (searchQuery.value.isNotEmpty) {
        // If there's a search query, use the search endpoint
        results = await TMDBService.searchMovies(searchQuery.value);
        
        // If genres are selected, filter the results
        if (selectedGenres.isNotEmpty) {
          final genreIds = selectedGenres.map((g) => g['id'] as int).toList();
          results = results.where((movie) {
            return movie.genreIds.any((id) => genreIds.contains(id));
          }).toList();
        }
      } else if (selectedGenres.isNotEmpty) {
        // If only genres are selected, use discover endpoint
        final genreIds = selectedGenres.map((g) => g['id'] as int).toList();
        results = await TMDBService.discoverMoviesByGenre(genreIds.first);
        
        // If multiple genres are selected, filter the results
        if (genreIds.length > 1) {
          results = results.where((movie) {
            return movie.genreIds.any((id) => genreIds.contains(id));
          }).toList();
        }
      }
      
      searchResults.value = results;
      
      // Add to history after successful search if there was a query
      if (searchQuery.value.isNotEmpty) {
        addToHistory(searchQuery.value);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to search movies: ${e.toString()}';
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }
} 