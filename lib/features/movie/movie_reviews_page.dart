import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/widgets/review_card.dart';
import 'package:letterboxd/features/review/models/review.dart';
import 'package:letterboxd/routes/app_routes.dart';

class MovieReviewsPage extends StatelessWidget {
  final Movie movie;
  final List<Map<String, dynamic>> reviews;

  const MovieReviewsPage({
    super.key,
    required this.movie,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reviews for ${movie.title}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: reviews.isEmpty
          ? const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final authorDetails = review['author_details'] ?? {};
                final avatarPath = authorDetails['avatar_path']?.toString();
                
                String? avatarUrl;
                if (avatarPath != null && avatarPath.isNotEmpty) {
                  if (avatarPath.startsWith('/http') || avatarPath.startsWith('http')) {
                    avatarUrl = avatarPath.startsWith('/') ? avatarPath.substring(1) : avatarPath;
                  } else {
                    avatarUrl = 'https://image.tmdb.org/t/p/w185$avatarPath';
                  }
                } else {
                  avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(review['author'] ?? 'Anonymous')}&background=random';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ReviewCard(
                    authorName: review['author'] ?? 'Anonymous',
                    avatarUrl: avatarUrl,
                    rating: (authorDetails['rating'] ?? 0.0) / 2,
                    content: review['content'] ?? 'No content',
                    commentCount: 0,
                    movieTitle: movie.title,
                    movieYear: movie.releaseDate.split('-')[0],
                    moviePosterUrl: movie.posterUrl,
                    isDetailPage: true,
                    onTap: () {
                      final reviewObj = Review(
                        id: review['id'].toString(),
                        userId: authorDetails['id']?.toString() ?? 'unknown',
                        username: review['author'] ?? 'Anonymous',
                        userAvatarUrl: avatarPath ?? '',
                        movieId: movie.id.toString(),
                        movieTitle: movie.title,
                        movieYear: movie.releaseDate.split('-')[0],
                        moviePosterUrl: movie.posterUrl,
                        rating: (authorDetails['rating'] ?? 0.0) / 2,
                        content: review['content'] ?? 'No content',
                        watchedDate: DateTime.parse(review['created_at'] ?? DateTime.now().toIso8601String()),
                        likes: 0,
                        isLiked: false,
                      );
                      Get.toNamed(AppRoutes.review, arguments: reviewObj);
                    },
                  ),
                );
              },
            ),
    );
  }
} 