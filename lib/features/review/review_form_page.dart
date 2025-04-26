import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewFormPage extends StatefulWidget {
  final String movieId;
  final String movieTitle;
  final String movieYear;
  final String posterPath;

  const ReviewFormPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.movieYear,
    required this.posterPath,
  });

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 0;
  bool _isFavorite = false;
  DateTime _watchedDate = DateTime.now();

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
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _rating = index + 1;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: SvgPicture.asset(
                                            'assets/icons/star.svg',
                                            width: 24,
                                            height: 24,
                                            colorFilter: ColorFilter.mode(
                                              index < _rating ? Colors.red : const Color(0xFF3D3B54),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please write a review';
                    }
                    return null;
                  },
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

  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement review submission
      Get.back();
      Get.snackbar(
        'Success',
        'Review submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 