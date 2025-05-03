import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/diary_entry.dart';
import '../../../core/services/tmdb_service.dart';
import '../../../routes/app_routes.dart';

class DiaryEntryItem extends StatelessWidget {
  final DiaryEntry entry;
  final int dayNumber;

  const DiaryEntryItem({
    super.key,
    required this.entry,
    required this.dayNumber,
  });

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to movie detail page
        Get.toNamed(
          AppRoutes.movieDetailPath(entry.tmdbId),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day number
            SizedBox(
              width: 40,
              child: Text(
                dayNumber.toString(),
                style: GoogleFonts.openSans(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            // Movie poster
            FutureBuilder<String?>(
              future: TMDBService.getMoviePoster(entry.tmdbId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data!,
                      width: 45,
                      height: 65,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 45,
                        height: 65,
                        color: Colors.grey[800],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFE9A6A6),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 45,
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.movie, color: Colors.white30),
                      ),
                    ),
                  );
                }
                return Container(
                  width: 45,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.movie, color: Colors.white30),
                );
              },
            ),
            const SizedBox(width: 12),
            // Movie details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.releaseDate.year.toString(),
                    style: GoogleFonts.openSans(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRatingStars(entry.userRating / 2), // Convert 10-point scale to 5-point scale
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 