import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/features/home/controllers/home_controller.dart';
import 'package:letterboxd/features/review/models/review.dart';
import 'package:letterboxd/features/sidebar/drawer_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letterboxd/core/widgets/custom_bottom_nav.dart';
import 'package:letterboxd/core/widgets/review_card.dart';
import 'package:letterboxd/features/home/widgets/popular_lists_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      drawer: const DrawerMenu(),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.refreshData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/sidebar.svg',
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                          ),
                          const Spacer(),
                          // IconButton(
                          //   icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          //   onPressed: () {
                          //     // TODO: Implement notifications
                          //   },
                          // ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.profile);
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: authController.currentUser?.profileImage != null
                                ? NetworkImage(authController.currentUser!.profileImage!)
                                : null,
                              child: authController.currentUser?.profileImage == null
                                ? Text(
                                    (authController.currentUser?.name.isNotEmpty == true
                                      ? authController.currentUser!.name[0].toUpperCase()
                                      : 'G'),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Welcome Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final textStyle = GoogleFonts.openSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              );
                              
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Hello, ',
                                      style: textStyle,
                                    ),
                                    TextSpan(
                                      text: '${authController.currentUser?.name ?? 'Guest'}',
                                      style: textStyle.copyWith(color: const Color(0xFFE9A6A6)),
                                    ),
                                    TextSpan(
                                      text: '!',
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Review or track film you\'ve watched...',
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Popular Films Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Popular Films This Month',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 141,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: controller.popularMovies.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _MovieCard(movie: controller.popularMovies[index]),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Popular Lists Section
                    PopularListsSection(),

                    const SizedBox(height: 32),

                    // Recent Friends' Review Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Recent Reviews',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.recentReviews.length,
                        itemBuilder: (context, index) {
                          final review = controller.recentReviews[index];
                          return ReviewCard(
                            authorName: review['author'],
                            avatarUrl: review['avatarUrl'],
                            rating: review['rating'],
                            content: review['content'],
                            commentCount: 8,
                            movieTitle: review['movieTitle'],
                            movieYear: '2019',
                            moviePosterUrl: review['posterPath'],
                            onTap: () {
                              final reviewObj = Review(
                                id: review['movieId']?.toString() ?? 'unknown',
                                userId: 'user_123', // TODO: Get actual user ID
                                username: review['author'] ?? 'Anonymous',
                                userAvatarUrl: review['avatarUrl'] ?? 'https://via.placeholder.com/150',
                                movieId: review['movieId']?.toString() ?? 'unknown',
                                movieTitle: review['movieTitle'] ?? 'Untitled Movie',
                                movieYear: review['createdAt']?.substring(0, 4) ?? '2024',
                                moviePosterUrl: review['posterPath'] ?? '',
                                rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                                content: review['content'] ?? 'No review content available',
                                watchedDate: DateTime.tryParse(review['createdAt'] ?? '') ?? DateTime.now(),
                                likes: 0,
                                isLiked: false,
                              );
                              Get.toNamed(AppRoutes.review, arguments: reviewObj);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.movieDetailPath(movie.id.toString()));
      },
      child: SizedBox(
        width: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 100,
            height: 141,
            child: CachedNetworkImage(
              imageUrl: movie.posterUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 