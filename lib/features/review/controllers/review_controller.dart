import 'package:get/get.dart';
import 'package:letterboxd/features/review/models/review.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class ReviewController extends GetxController {
  final Rx<Review?> currentReview = Rx<Review?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  final authController = Get.find<AuthController>();

  Future<void> loadReviewDetails(String reviewId) async {
    try {
      isLoading.value = true;
      
      // TODO: Replace with actual API call when available
      // For now, we'll simulate loading a review
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulated review data
      final reviewData = {
        'id': reviewId,
        'user_id': authController.currentUser?.id ?? '',
        'username': authController.currentUser?.username ?? '',
        'user_avatar_url': authController.currentUser?.profileImage ?? '',
        'movie_id': '123', // This should come from the movie being reviewed
        'movie_title': 'Sample Movie',
        'movie_year': '2024',
        'movie_poster_url': '',
        'rating': 4.5,
        'content': 'This is a sample review content.',
        'watched_date': DateTime.now().toIso8601String(),
        'likes': 0,
        'is_liked': false,
      };

      currentReview.value = Review.fromJson(reviewData);
      isLiked.value = currentReview.value?.isLiked ?? false;
      likeCount.value = currentReview.value?.likes ?? 0;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load review details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike() async {
    if (currentReview.value == null) return;

    try {
      isLiked.value = !isLiked.value;
      if (isLiked.value) {
        likeCount.value++;
      } else {
        likeCount.value--;
      }

      // Update the review object
      currentReview.value = currentReview.value?.copyWith(
        isLiked: isLiked.value,
        likes: likeCount.value,
      );

      // TODO: Implement API call to update like status
      // await TMDBService.updateReviewLike(currentReview.value!.id, isLiked.value);
    } catch (e) {
      // Revert changes if API call fails
      isLiked.value = !isLiked.value;
      if (isLiked.value) {
        likeCount.value++;
      } else {
        likeCount.value--;
      }

      Get.snackbar(
        'Error',
        'Failed to update like status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      isLoading.value = true;
      
      // TODO: Implement API call to delete review
      // await TMDBService.deleteReview(reviewId);
      
      Get.back(); // Return to previous screen
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createReview({
    required String movieId,
    required String movieTitle,
    required String movieYear,
    required String moviePosterUrl,
    required double rating,
    required String content,
    required DateTime watchedDate,
  }) async {
    try {
      isLoading.value = true;

      if (!authController.isLoggedIn) {
        throw Exception('User must be logged in to create a review');
      }

      // TODO: Implement API call to create review
      // final reviewData = await TMDBService.createReview(
      //   movieId: movieId,
      //   rating: rating,
      //   content: content,
      //   watchedDate: watchedDate,
      // );

      // Simulated review data
      final reviewData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': authController.currentUser?.id ?? '',
        'username': authController.currentUser?.username ?? '',
        'user_avatar_url': authController.currentUser?.profileImage ?? '',
        'movie_id': movieId,
        'movie_title': movieTitle,
        'movie_year': movieYear,
        'movie_poster_url': moviePosterUrl,
        'rating': rating,
        'content': content,
        'watched_date': watchedDate.toIso8601String(),
        'likes': 0,
        'is_liked': false,
      };

      currentReview.value = Review.fromJson(reviewData);
      Get.back(); // Return to previous screen
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create review: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 