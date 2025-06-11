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
  final RxList<int> selectedYears = <int>[].obs;
  final RxList<int> availableYears = <int>[].obs;
  final RxString sortBy = ''.obs;
  
  Timer? _debounce;
  static const String _searchHistoryKey = 'search_history';
  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    _loadGenres();
    _initializeYears();
  }

  void _initializeYears() {
    // Generate years from current year down to 1900
    final currentYear = DateTime.now().year;
    availableYears.value = List.generate(
      currentYear - 1899,
      (index) => currentYear - index,
    );
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
      Get.snackbar(
        'Error',
        'Failed to load genres: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  void toggleYear(int year) {
    if (selectedYears.contains(year)) {
      selectedYears.remove(year);
    } else {
      selectedYears.add(year);
    }
    performSearch();
  }

  void clearYears() {
    selectedYears.clear();
    performSearch();
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    _sortResults();
  }

  void _sortResults() {
    if (sortBy.value.isEmpty) return;
    
    if (sortBy.value == 'highest') {
      searchResults.sort((a, b) {
        final ratingA = a.voteAverage ?? 0.0;
        final ratingB = b.voteAverage ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
    } else if (sortBy.value == 'lowest') {
      searchResults.sort((a, b) {
        final ratingA = a.voteAverage ?? 0.0;
        final ratingB = b.voteAverage ?? 0.0;
        return ratingA.compareTo(ratingB);
      });
    } else if (sortBy.value == 'newest') {
      searchResults.sort((a, b) {
        if (a.releaseDate.isEmpty) return 1;
        if (b.releaseDate.isEmpty) return -1;
        return b.releaseDate.compareTo(a.releaseDate);
      });
    } else if (sortBy.value == 'oldest') {
      searchResults.sort((a, b) {
        if (a.releaseDate.isEmpty) return 1;
        if (b.releaseDate.isEmpty) return -1;
        return a.releaseDate.compareTo(b.releaseDate);
      });
    }
  }

  Future<void> performSearch() async {
    if (searchQuery.value.isEmpty && selectedGenres.isEmpty && selectedYears.isEmpty) return;
    
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

        // If years are selected, filter the results
        if (selectedYears.isNotEmpty) {
          results = results.where((movie) {
            if (movie.releaseDate.isEmpty) return false;
            final movieYear = int.tryParse(movie.releaseDate.split('-')[0]);
            return movieYear != null && selectedYears.contains(movieYear);
          }).toList();
        }
      } else if (selectedGenres.isNotEmpty || selectedYears.isNotEmpty) {
        // If only filters are selected, use discover endpoint
        final genreIds = selectedGenres.map((g) => g['id'] as int).toList();
        final years = selectedYears.toList();
        
        // Use the discover endpoint with filters
        results = await TMDBService.discoverMovies(
          genreIds: genreIds,
          years: years,
        );
      }
      
      searchResults.value = results;
      
      // Apply sorting if sortBy is set
      if (sortBy.value.isNotEmpty) {
        _sortResults();
      }
      
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