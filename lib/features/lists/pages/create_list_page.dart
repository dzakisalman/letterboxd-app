import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final _isLoading = false.obs;
  final _isSearching = false.obs;
  final _searchResults = <Movie>[].obs;
  final _selectedMovies = <Movie>{}.obs;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      return;
    }

    _isSearching.value = true;
    try {
      final results = await TMDBService.searchMovies(query);
      _searchResults.value = results;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search movies',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) return;
    _isLoading.value = true;

    print('\n[CreateList] ===== Starting List Creation =====');
    print('[CreateList] Title: ${_titleController.text}');
    print('[CreateList] Description: ${_descriptionController.text}');
    print('[CreateList] Selected Movies: ${_selectedMovies.length}');
    _selectedMovies.forEach((movie) {
      print('[CreateList] - ${movie.title} (ID: ${movie.id})');
    });

    try {
      final result = await TMDBService.createList(
        name: _titleController.text,
        description: _descriptionController.text,
        items: _selectedMovies.toList(),
      );

      print('[CreateList] API Response: $result');

      if (result['success']) {
        print('[CreateList] List created successfully');
        Get.back();
        Get.snackbar(
          'Success',
          'List created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('[CreateList] Failed to create list: ${result['error_message']}');
        Get.snackbar(
          'Error',
          result['error_message'] ?? 'Failed to create list',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('[CreateList] Exception occurred: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      print('[CreateList] ===== End List Creation Process =====\n');
    }
  }

  void _toggleMovieSelection(Movie movie) {
    print('\n[CreateList] Toggling movie selection');
    print('[CreateList] Movie: ${movie.title} (ID: ${movie.id})');
    
    if (_selectedMovies.contains(movie)) {
      print('[CreateList] Removing movie from selection');
      _selectedMovies.remove(movie);
    } else {
      print('[CreateList] Adding movie to selection');
      _selectedMovies.add(movie);
    }
    
    print('[CreateList] Current selection count: ${_selectedMovies.length}');
    // Force UI update
    _selectedMovies.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D36),
        elevation: 0,
        title: Text(
          'Create New List',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFE9A6A6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFE9A6A6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search Movies Section
                    Text(
                      'Add Movies',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _searchController,
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search movies...',
                        hintStyle: GoogleFonts.openSans(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFE9A6A6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length >= 2) {
                          _searchMovies(value);
                        } else {
                          _searchResults.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selected Movies
                    Obx(() {
                      if (_selectedMovies.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Movies (${_selectedMovies.length})',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedMovies.length,
                              itemBuilder: (context, index) {
                                final movie = _selectedMovies.elementAt(index);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: movie.posterPath != null
                                              ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                                              : 'https://image.tmdb.org/t/p/w500/wwemzKWzjKYJFfCeiB57q3r4Bcm.png',
                                          height: 120,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.movie,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _toggleMovieSelection(movie),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // Search Results
                    Obx(() {
                      if (_isSearching.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9A6A6)),
                          ),
                        );
                      }

                      if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
                        return Center(
                          child: Text(
                            'No movies found',
                            style: GoogleFonts.openSans(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (_searchResults.isNotEmpty) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            return Obx(() {
                              final isSelected = _selectedMovies.contains(movie);
                              return GestureDetector(
                                onTap: () => _toggleMovieSelection(movie),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xFF3D3B54),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: movie.posterPath != null
                                                    ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                                                    : 'https://image.tmdb.org/t/p/w500/wwemzKWzjKYJFfCeiB57q3r4Bcm.png',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorWidget: (context, url, error) => Container(
                                                  color: Colors.grey[800],
                                                  child: const Icon(
                                                    Icons.movie,
                                                    color: Colors.white,
                                                    size: 32,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  movie.title,
                                                  style: GoogleFonts.openSans(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      movie.voteAverage?.toStringAsFixed(1) ?? 'N/A',
                                                      style: GoogleFonts.openSans(
                                                        color: Colors.grey[400],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black54,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Color(0xFFE9A6A6),
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            });
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9A6A6)),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading.value ? null : _createList,
        backgroundColor: const Color(0xFFE9A6A6),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          'Create List',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 