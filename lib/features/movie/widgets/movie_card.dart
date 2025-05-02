import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.movieDetailPath(movie.id.toString()));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: movie.posterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 300,
                        memCacheHeight: 450,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (movie.userRating != null) ...[
              Row(
                children: [
                  ...List.generate(5, (index) {
                    final rating = movie.userRating! / 2; // Convert to 5-star scale
                    final fullStars = rating.floor();
                    final hasHalfStar = rating - fullStars >= 0.5;

                    if (index < fullStars) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          'assets/icons/star.svg',
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFE53935),
                            BlendMode.srcIn,
                          ),
                          width: 12,
                          height: 12,
                        ),
                      );
                    } else if (index == fullStars && hasHalfStar) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          'assets/icons/halfstar.svg',
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFE53935),
                            BlendMode.srcIn,
                          ),
                          width: 12,
                          height: 12,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (movie.releaseDate.isNotEmpty)
              Text(
                movie.releaseDate.split('-')[0],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.movie,
          color: Colors.white54,
          size: 32,
        ),
      ),
    );
  }
} 