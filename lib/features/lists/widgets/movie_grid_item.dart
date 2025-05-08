import 'package:flutter/material.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieGridItem extends StatelessWidget {
  final Movie movie;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showRemoveButton;
  final VoidCallback? onRemove;

  const MovieGridItem({
    Key? key,
    required this.movie,
    this.isSelected = false,
    this.onTap,
    this.showRemoveButton = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: movie.posterPath != null
                  ? TMDBService.getImageUrl(movie.posterPath!)
                  : 'https://image.tmdb.org/t/p/w500/wwemzKWzjKYJFfCeiB57q3r4Bcm.png',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.movie,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          if (showRemoveButton)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
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
  }
} 