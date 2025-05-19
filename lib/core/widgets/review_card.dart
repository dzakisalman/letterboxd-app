import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint('[ReviewCard] Building card for author: $authorName');
    debugPrint('[ReviewCard] Avatar URL: $avatarUrl');

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9A6A6).withAlpha(13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo
          ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    width: isDetailPage ? 32 : 36,
                    height: isDetailPage ? 32 : 36,
                    fit: BoxFit.cover,
                    memCacheWidth: isDetailPage ? 64 : 72,
                    memCacheHeight: isDetailPage ? 64 : 72,
                    maxWidthDiskCache: isDetailPage ? 64 : 72,
                    maxHeightDiskCache: isDetailPage ? 64 : 72,
                    placeholder: (context, url) {
                      debugPrint('[ReviewCard] Loading avatar for $authorName from: $url');
                      return Container(
                        width: isDetailPage ? 32 : 36,
                        height: isDetailPage ? 32 : 36,
                        color: Colors.grey[800],
                        child: Center(
                          child: Text(
                            authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: isDetailPage ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      debugPrint('[ReviewCard] Error loading avatar for $authorName: $error, URL: $url');
                      if (error is Error) {
                        debugPrint('[ReviewCard] Error stack trace: ${error.stackTrace}');
                      }
                      return Container(
                        width: isDetailPage ? 32 : 36,
                        height: isDetailPage ? 32 : 36,
                        color: Colors.grey[800],
                        child: Center(
                          child: Text(
                            authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: isDetailPage ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) {
                      debugPrint('[ReviewCard] Successfully loaded avatar for $authorName');
                      return Container(
                        width: isDetailPage ? 32 : 36,
                        height: isDetailPage ? 32 : 36,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    width: isDetailPage ? 32 : 36,
                    height: isDetailPage ? 32 : 36,
                    color: Colors.grey[800],
                    child: Center(
                      child: Text(
                        authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: isDetailPage ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          // Review content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDetailPage) ...[
                  // Movie title and year
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          movieTitle,
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Text(
                        ' $movieYear',
                        style: GoogleFonts.openSans(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
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
                    ...List.generate(rating.ceil(), (index) {
                      final fullStars = rating.floor();
                      final hasHalfStar = rating - fullStars >= 0.5;
                      
                      if (index < fullStars) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: SvgPicture.asset(
                            'assets/icons/star.svg',
                            colorFilter: ColorFilter.mode(
                              const Color(0xFFEC2626),
                              BlendMode.srcIn,
                            ),
                            width: isDetailPage ? 14 : 12,
                            height: isDetailPage ? 14 : 12,
                          ),
                        );
                      } else if (index == fullStars && hasHalfStar) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: SvgPicture.asset(
                            'assets/icons/halfstar.svg',
                            colorFilter: ColorFilter.mode(
                              const Color(0xFFEC2626),
                              BlendMode.srcIn,
                            ),
                            width: isDetailPage ? 14 : 12,
                            height: isDetailPage ? 14 : 12,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(width: 4),
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
                    fontSize: 9,
                    height: 1.4,
                  ),
                  maxLines: 3,
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