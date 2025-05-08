import 'package:flutter/material.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/lists/widgets/movie_grid_item.dart';

class SelectedMoviesList extends StatelessWidget {
  final Set<Movie> selectedMovies;
  final Function(Movie) onMovieTap;

  const SelectedMoviesList({
    Key? key,
    required this.selectedMovies,
    required this.onMovieTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedMovies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No movies selected'),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedMovies.length,
        itemBuilder: (context, index) {
          final movie = selectedMovies.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: MovieGridItem(
              movie: movie,
              onTap: () => onMovieTap(movie),
              showRemoveButton: true,
              onRemove: () => onMovieTap(movie),
            ),
          );
        },
      ),
    );
  }
} 