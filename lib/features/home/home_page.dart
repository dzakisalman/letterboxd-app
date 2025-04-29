import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/features/home/controllers/home_controller.dart';
import 'package:letterboxd/features/sidebar/drawer_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letterboxd/core/widgets/custom_bottom_nav.dart';
import 'package:letterboxd/core/widgets/review_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      drawer: const DrawerMenu(),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await homeController.refreshData();
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
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hello, ',
                                style: GoogleFonts.openSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: '${authController.currentUser?.name ?? 'Guest'}!',
                                style: GoogleFonts.openSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE9A6A6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review or track film you\'ve watched...',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey[400],
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
                      itemCount: homeController.popularMovies.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _MovieCard(movie: homeController.popularMovies[index]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // // Popular Lists Section
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 24),
                  //   child: Text(
                  //     'Popular Lists This Month',
                  //     style: GoogleFonts.openSans(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 16),
                  // SizedBox(
                  //   height: 200,
                  //   child: Obx(() => ListView.builder(
                  //     scrollDirection: Axis.horizontal,
                  //     padding: const EdgeInsets.symmetric(horizontal: 24),
                  //     itemCount: homeController.popularLists.length,
                  //     itemBuilder: (context, index) {
                  //       final list = homeController.popularLists[index];
                  //       return _ListCard(
                  //         title: list['title'],
                  //         author: list['author'],
                  //         posterPath: list['posterPath'],
                  //       );
                  //     },
                  //   )),
                  // ),

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
                    child: Obx(() => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homeController.recentReviews.length,
                      itemBuilder: (context, index) {
                        final review = homeController.recentReviews[index];
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
                            // TODO: Navigate to review detail
                          },
                        );
                      },
                    )),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
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

class _ListCard extends StatelessWidget {
  final String title;
  final String author;
  final String posterPath;

  const _ListCard({
    required this.title,
    required this.author,
    required this.posterPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 82,
              child: CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
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
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'by $author',
            style: GoogleFonts.openSans(
              color: Colors.grey[400],
              fontSize: 8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 