import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/lists/widgets/movie_search_grid.dart';
import 'package:letterboxd/features/lists/widgets/selected_movies_list.dart';

class EditListPage extends StatefulWidget {
  final Map<String, dynamic> list;
  final List<Movie> movies;

  const EditListPage({
    Key? key,
    required this.list,
    required this.movies,
  }) : super(key: key);

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Movie> _searchResults = [];
  Set<Movie> _selectedMovies = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.list['name'];
    _descriptionController.text = widget.list['description'];
    _selectedMovies = Set.from(widget.movies);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await TMDBService.searchMovies(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('[EditList] Error searching movies: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _toggleMovieSelection(Movie movie) {
    print('[EditList] Toggling movie selection');
    print('[EditList] Movie: ${movie.title} (ID: ${movie.id})');

    setState(() {
      if (_selectedMovies.contains(movie)) {
        print('[EditList] Removing movie from selection');
        _selectedMovies.remove(movie);
      } else {
        print('[EditList] Adding movie to selection');
        _selectedMovies.add(movie);
      }
      print('[EditList] Current selection count: ${_selectedMovies.length}');
    });
  }

  Future<void> _updateList() async {
    if (!_formKey.currentState!.validate()) return;

    print('\n[EditList] ===== Starting List Update =====');
    print('[EditList] Title: ${_titleController.text}');
    print('[EditList] Description: ${_descriptionController.text}');
    print('[EditList] Selected Movies: ${_selectedMovies.length}');
    _selectedMovies.forEach((movie) {
      print('[EditList] - ${movie.title} (ID: ${movie.id})');
    });

    setState(() {
      _isLoading = true;
    });

    try {
      // Update list details
      final updateResult = await TMDBService.updateList(
        listId: widget.list['id'].toString(),
        name: _titleController.text,
        description: _descriptionController.text,
      );

      if (!updateResult['success']) {
        throw Exception(updateResult['error_message']);
      }

      // Get current movies in the list
      final currentMovies = Set<Movie>.from(widget.movies);
      
      // Remove movies that are no longer selected
      for (final movie in currentMovies) {
        if (!_selectedMovies.contains(movie)) {
          final removeResult = await TMDBService.removeMovieFromList(
            widget.list['id'].toString(),
            movie.id,
          );
          if (!removeResult['success']) {
            print('[EditList] Warning: Failed to remove movie ${movie.title}: ${removeResult['error_message']}');
          }
        }
      }

      // Add newly selected movies
      for (final movie in _selectedMovies) {
        if (!currentMovies.contains(movie)) {
          final addResult = await TMDBService.addMoviesToList(
            widget.list['id'].toString(),
            [movie],
          );
          if (!addResult['success']) {
            print('[EditList] Warning: Failed to add movie ${movie.title}: ${addResult['error_message']}');
          }
        }
      }

      print('[EditList] List updated successfully');
      print('[EditList] ===== End List Update Process =====');

      Get.back(result: true);
      Get.snackbar(
        'Success',
        'List updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('[EditList] Error updating list: $e');
      Get.snackbar(
        'Error',
        'Failed to update list: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        title: Text(
          'Edit List',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1F1D36),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'List Title',
                      labelStyle: GoogleFonts.openSans(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE9A6A6)),
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
                  TextFormField(
                    controller: _descriptionController,
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.openSans(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE9A6A6)),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Selected Movies',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectedMoviesList(
                    selectedMovies: _selectedMovies,
                    onMovieTap: _toggleMovieSelection,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Search Movies',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _searchController,
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search movies...',
                      hintStyle: GoogleFonts.openSans(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[400]),
                              onPressed: () {
                                _searchController.clear();
                                _searchMovies('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE9A6A6)),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length >= 2) {
                        _searchMovies(value);
                      } else {
                        setState(() {
                          _searchResults = [];
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  MovieSearchGrid(
                    movies: _searchResults,
                    selectedMovies: _selectedMovies,
                    onMovieTap: _toggleMovieSelection,
                    isLoading: _isSearching,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
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
        onPressed: _isLoading ? null : _updateList,
        backgroundColor: const Color(0xFFE9A6A6),
        icon: const Icon(Icons.save),
        label: Text(
          'Save Changes',
          style: GoogleFonts.openSans(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 