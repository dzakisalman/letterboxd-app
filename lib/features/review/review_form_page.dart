import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';

class ReviewFormPage extends StatefulWidget {
  final String movieId;
  final String movieTitle;
  final String movieYear;
  final String posterPath;
  final double? existingRating; // Rating in 5-star scale
  final bool? isFavorite;

  const ReviewFormPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.movieYear,
    required this.posterPath,
    this.existingRating,
    this.isFavorite,
  });

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  double _rating = 0; // Changed from int to double to support half stars
  bool _isFavorite = false;
  DateTime _watchedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    if (widget.existingRating != null) {
      _rating = widget.existingRating!;
    }
    if (widget.isFavorite != null) {
      _isFavorite = widget.isFavorite!;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.openSansTextTheme();
    
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Write Your Review',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.movieTitle} ${widget.movieYear}',
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Specify the date you watched it',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _watchedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _watchedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D3B54),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/diary.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_watchedDate.day} ${_getMonth(_watchedDate.month)} ${_watchedDate.year}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Change',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFFE9A6A6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Give your rating',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      final starValue = index + 1;
                                      final isHalfStar = _rating == starValue - 0.5;
                                      final isFullStar = _rating >= starValue;
                                      
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isFullStar) {
                                              // If clicking a full star, change to half star
                                              _rating = starValue - 0.5;
                                            } else if (isHalfStar) {
                                              // If clicking a half star, change to empty star
                                              _rating = starValue - 1;
                                            } else {
                                              // If clicking an empty star, change to full star
                                              _rating = starValue.toDouble();
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: isHalfStar
                                              ? Stack(
                                                  alignment: Alignment.centerLeft,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/icons/star.svg',
                                                      width: 24,
                                                      height: 24,
                                                      colorFilter: const ColorFilter.mode(
                                                        Color(0xFF3D3B54),
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                    SvgPicture.asset(
                                                      'assets/icons/halfstar.svg',
                                                      width: 24,
                                                      height: 24,
                                                      colorFilter: const ColorFilter.mode(
                                                        Colors.red,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : SvgPicture.asset(
                                                  'assets/icons/star.svg',
                                                  width: 24,
                                                  height: 24,
                                                  colorFilter: ColorFilter.mode(
                                                    isFullStar ? Colors.red : const Color(0xFF3D3B54),
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isFavorite = !_isFavorite;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                      'assets/icons/fav.svg',
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        _isFavorite ? Colors.red : const Color(0xFF3D3B54),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.posterPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _reviewController,
                  maxLines: null,
                  minLines: 10,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write down your review...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF3D3B54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 96,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8B3B3),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Publish',
                        style: textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F1D36),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _submitReview() async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn) {
        print('[ReviewForm] Error: User not logged in');
        Get.snackbar(
          'Error',
          'Please login to submit rating and mark as favorite',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Submit rating if rating is greater than 0
      if (_rating > 0) {
        final ratingValue = _rating * 2.0; // Convert 5-star scale to 10-point scale
        print('[ReviewForm] Submitting rating: $_rating (converted to $ratingValue) for movie ${widget.movieId}');
        await TMDBService.rateMovie(int.parse(widget.movieId), ratingValue);
        print('[ReviewForm] Rating submitted successfully');
      }

      // Mark as favorite if selected
      if (_isFavorite) {
        print('[ReviewForm] Marking movie ${widget.movieId} as favorite');
        await TMDBService.markAsFavorite(
          authController.sessionId!,
          int.parse(widget.movieId),
          true,
        );
        print('[ReviewForm] Movie marked as favorite successfully');
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Rating and favorite status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      print('[ReviewForm] Error submitting review:');
      print('[ReviewForm] Error message: $e');
      print('[ReviewForm] Stack trace: $stackTrace');
      print('[ReviewForm] Movie ID: ${widget.movieId}');
      print('[ReviewForm] Rating: $_rating');
      print('[ReviewForm] Is Favorite: $_isFavorite');
      
      Get.snackbar(
        'Error',
        'Failed to submit rating and favorite status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 