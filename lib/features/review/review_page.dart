import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:letterboxd/features/review/controllers/review_controller.dart';
import 'package:letterboxd/features/review/models/review.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

class ReviewPage extends StatelessWidget {
  final Review review;

  const ReviewPage({
    Key? key,
    required this.review,
  }) : super(key: key);

  String _getAvatarUrl(String username) {
    print('[ReviewPage] Getting avatar URL for user: $username');
    
    // Get the original avatar URL from the review
    final originalAvatarUrl = review.userAvatarUrl;
    print('[ReviewPage] Original avatar URL: $originalAvatarUrl');
    
    if (originalAvatarUrl.isEmpty) {
      final generatedUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=random';
      print('[ReviewPage] Using generated avatar: $generatedUrl');
      return generatedUrl;
    }

    // Handle Gravatar URLs
    if (originalAvatarUrl.startsWith('https://secure.gravatar.com')) {
      print('[ReviewPage] Using Gravatar URL directly: $originalAvatarUrl');
      return originalAvatarUrl;
    }

    // Handle TMDB URLs
    if (originalAvatarUrl.startsWith('https://image.tmdb.org')) {
      print('[ReviewPage] Using TMDB URL directly: $originalAvatarUrl');
      return originalAvatarUrl;
    }

    // Handle TMDB paths
    if (originalAvatarUrl.startsWith('/')) {
      final tmdbUrl = 'https://image.tmdb.org/t/p/w185$originalAvatarUrl';
      print('[ReviewPage] Using TMDB path: $tmdbUrl');
      return tmdbUrl;
    }

    // Handle other direct URLs
    if (originalAvatarUrl.startsWith('http')) {
      print('[ReviewPage] Using direct URL: $originalAvatarUrl');
      return originalAvatarUrl;
    }

    // Handle relative paths
    final tmdbUrl = 'https://image.tmdb.org/t/p/w185/$originalAvatarUrl';
    print('[ReviewPage] Using relative path with TMDB base: $tmdbUrl');
    return tmdbUrl;
  }

  @override
  Widget build(BuildContext context) {
    print('[ReviewPage] Building review page for user: ${review.username}');
    print('[ReviewPage] Review ID: ${review.id}');
    print('[ReviewPage] Movie: ${review.movieTitle} (${review.movieYear})');

    final controller = Get.put(ReviewController());
    controller.likeCount.value = review.likes;
    controller.isLiked.value = review.isLiked;

    final avatarUrl = _getAvatarUrl(review.username);
    print('[ReviewPage] Final avatar URL to be used: $avatarUrl');

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${review.username}\'s Review',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1F1D36),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share, color: Colors.white),
                      title: const Text(
                        'Share',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // TODO: Implement share functionality
                        Navigator.pop(context);
                      },
                    ),
                    if (review.userId == 'current_user_id') // Replace with actual user check
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text(
                          'Delete Review',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          controller.deleteReview(review.id);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'REVIEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'COMMENT',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        color: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Review Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[800],
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: avatarUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              memCacheWidth: 80,
                              memCacheHeight: 80,
                              maxWidthDiskCache: 80,
                              maxHeightDiskCache: 80,
                              placeholder: (context, url) {
                                print('[ReviewPage] Loading avatar placeholder for: $url');
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white38,
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                print('[ReviewPage] Error loading avatar: $error');
                                print('[ReviewPage] Failed URL: $url');
                                if (error is Error) {
                                  print('[ReviewPage] Error stack trace: ${error.stackTrace}');
                                }
                                return Text(
                                  review.username[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                              imageBuilder: (context, imageProvider) {
                                print('[ReviewPage] Successfully loaded avatar for: ${review.username}');
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          review.username,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Movie Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.movieTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review.movieYear,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Rating Stars
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    if (index < review.rating) {
                                      return const Icon(Icons.star, color: Colors.green, size: 16);
                                    }
                                    return const Icon(Icons.star_border, color: Colors.green, size: 16);
                                  }),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.favorite, color: Colors.orange, size: 16),
                                ],
                              ),
                              const SizedBox(height: 9),
                              // Watch Date
                              Text(
                                'Watched ${DateFormat('d MMMM y').format(review.watchedDate)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Movie Poster
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            review.moviePosterUrl,
                            height: 150,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Review Text
                    Text(
                      review.content,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 