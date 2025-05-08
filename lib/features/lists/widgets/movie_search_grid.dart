import 'package:flutter/material.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/lists/widgets/movie_grid_item.dart';

class MovieSearchGrid extends StatelessWidget {
  final List<Movie> movies;
  final Set<Movie> selectedMovies;
  final Function(Movie) onMovieTap;
  final bool isLoading;
  final bool showRemoveButton;
  final Function(Movie)? onRemove;

  const MovieSearchGrid({
    Key? key,
    required this.movies,
    required this.selectedMovies,
    required this.onMovieTap,
    this.isLoading = false,
    this.showRemoveButton = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No movies found'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final isSelected = selectedMovies.contains(movie);
        return MovieGridItem(
          movie: movie,
          isSelected: isSelected,
          onTap: () => onMovieTap(movie),
          showRemoveButton: showRemoveButton,
          onRemove: onRemove != null ? () => onRemove!(movie) : null,
        );
      },
    );
  }
} 