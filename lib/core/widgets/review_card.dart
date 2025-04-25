import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewCard extends StatelessWidget {
  final String authorName;
  final String? avatarUrl;
  final double rating;
  final String content;
  final int commentCount;
  final String movieTitle;
  final String movieYear;
  final String moviePosterUrl;
  final bool isDetailPage;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.authorName,
    this.avatarUrl,
    required this.rating,
    required this.content,
    required this.commentCount,
    required this.movieTitle,
    required this.movieYear,
    required this.moviePosterUrl,
    this.isDetailPage = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9A6A6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo
          CircleAvatar(
            radius: isDetailPage ? 20 : 24,
            backgroundColor: Colors.grey[800],
            child: avatarUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Text(
                        authorName[0].toUpperCase(),
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: isDetailPage ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Text(
                    authorName[0].toUpperCase(),
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: isDetailPage ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // Review content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie title and year
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      movieTitle,
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: isDetailPage ? 12 : 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' $movieYear',
                      style: GoogleFonts.openSans(
                        color: Colors.grey[400],
                        fontSize: isDetailPage ? 11 : 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Reviewed by
                Row(
                  children: [
                    Text(
                      'Review by ',
                      style: GoogleFonts.openSans(
                        color: Colors.grey[400],
                        fontSize: isDetailPage ? 12 : 9,
                      ),
                    ),
                    Text(
                      authorName,
                      style: GoogleFonts.openSans(
                        color: const Color(0xFFE9A6A6),
                        fontSize: isDetailPage ? 12 : 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating stars and comments
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          'assets/icons/star.svg',
                          colorFilter: ColorFilter.mode(
                            index < rating ? const Color(0xFFEC2626) : Colors.grey[600]!,
                            BlendMode.srcIn,
                          ),
                          width: isDetailPage ? 14 : 12,
                          height: isDetailPage ? 14 : 12,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey[400],
                      size: isDetailPage ? 14 : 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      commentCount.toString(),
                      style: GoogleFonts.openSans(
                        color: Colors.grey[400],
                        fontSize: isDetailPage ? 10 : 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Review text
                Text(
                  content,
                  style: GoogleFonts.openSans(
                    color: Colors.grey[300],
                    fontSize: 7,
                    height: 1.4,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Read more
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Read more >',
                    style: GoogleFonts.openSans(
                      color: const Color(0xFF9C4FD6),
                      fontSize: isDetailPage ? 12 : 7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Movie Poster
          if (!isDetailPage)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: moviePosterUrl,
                width: 90,
                height: 135,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 