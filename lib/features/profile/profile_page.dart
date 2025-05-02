import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/features/profile/controllers/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letterboxd/features/review/models/review.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/core/widgets/custom_bottom_nav.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letterboxd/core/widgets/review_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      body: WillPopScope(
        onWillPop: () async {
          // Kembali ke tab sebelumnya (misal Home/tab 0)
          Get.offAllNamed(AppRoutes.home);
          return false;
        },
        child: Obx(() {
          if (profileController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with banner and profile info
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner Image
                    SizedBox(
                      width: double.infinity,
                      height: 160,
                      child: Image.asset(
                        'assets/images/banner.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Foto profil menumpuk di atas banner
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 110,
                      child: Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: profileController.authController.currentUser?.profileImage != null
                            ? NetworkImage(profileController.authController.currentUser!.profileImage!)
                              : null,
                          backgroundColor: Colors.grey[800],
                          child: profileController.authController.currentUser?.profileImage == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white70)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Jarak agar konten tidak tertutup avatar
                // Name
                Text(
                  profileController.authController.currentUser?.name ?? 'Name',
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Followers and Following
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${profileController.authController.currentUser?.followers ?? 0} Followers',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 50,
                          height: 2,
                          color: Color(0xFFE9A6A6),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(
                          '${profileController.authController.currentUser?.following ?? 0} Following',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 50,
                          height: 2,
                          color: Color(0xFFE9A6A6),
                        ),
                      ],
                    ),
                  ],
                ),
                // Stats Grid
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '${profileController.recentlyWatched.length}',
                          'Total Films',
                          Color(0xFFE9A6A6)!,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '${profileController.recentlyWatched.length}',
                          'Film This Year',
                          Color(0xFF9C4A8B)!,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '0', // TODO: Ganti dengan jumlah list dari TMDB jika sudah ada endpoint
                          'Lists',
                          Color(0xFFE9A6A6)!,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '${profileController.authController.currentUser?.reviews ?? 0}',
                          'Review',
                          Color(0xFF9C4A8B)!,
                        ),
                      ),
                    ],
                  ),
                ),
                // Favorite Films Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${profileController.authController.currentUser?.name ?? 'User'}'s Favorite Films",
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: Center(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: profileController.favoriteMovies.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final movie =
                                  profileController.favoriteMovies[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(AppRoutes.movieDetailPath(
                                      movie.id.toString()));
                                },
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[800],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
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
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Recent Watched Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${profileController.authController.currentUser?.name ?? 'User'}'s Recent Watched",
                            style: GoogleFonts.openSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See All',
                              style: GoogleFonts.openSans(
                                color: Color(0xFFE9A6A6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: profileController.recentlyWatched.length,
                          itemBuilder: (context, index) {
                            final movie =
                                profileController.recentlyWatched[index];
                            return GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.movieDetailPath(
                                    movie.id.toString()));
                              },
                              child: Container(
                                width: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: movie.posterUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[800],
                                            child: const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          final rating =
                                              (movie.userRating ?? 0) / 2;
                                          final fullStars = rating.floor();
                                          final hasHalfStar =
                                              rating - fullStars >= 0.5;

                                          if (index < fullStars) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 1),
                                              child: SvgPicture.asset(
                                                'assets/icons/star.svg',
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Color(0xFFE53935),
                                                  BlendMode.srcIn,
                                                ),
                                                width: 12,
                                                height: 12,
                                              ),
                                            );
                                          } else if (index == fullStars &&
                                              hasHalfStar) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 1),
                                              child: SvgPicture.asset(
                                                'assets/icons/halfstar.svg',
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Color(0xFFE53935),
                                                  BlendMode.srcIn,
                                                ),
                                                width: 12,
                                                height: 12,
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 1),
                                              child: SvgPicture.asset(
                                                'assets/icons/star.svg',
                                                colorFilter: ColorFilter.mode(
                                                  Color(0xFFE53935).withOpacity(0),
                                                  BlendMode.srcIn,
                                                ),
                                                width: 12,
                                                height: 12,
                                              ),
                                            );
                                          }
                                        }),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Read Review',
                                          style: GoogleFonts.openSans(
                                            color: Color(0xFF9C4A8B),
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        // Arrow icon
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: SizedBox(
                                            width: 9,
                                            height: 9,
                                            child: SvgPicture.asset(
                                              'assets/icons/arrow.svg',
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                      Color(0xFF9C4A8B),
                                                      BlendMode.srcIn),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Recent Reviews Section
                if (profileController.recentlyWatched.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${profileController.authController.currentUser?.name ?? 'User'}'s Recent Reviewed",
                              style: GoogleFonts.openSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: GoogleFonts.openSans(
                                  color: Color(0xFFE9A6A6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Review Card
                        ReviewCard(
                          authorName: profileController
                                  .authController.currentUser?.name ??
                              'User',
                          avatarUrl: profileController
                              .authController.currentUser?.profileImage,
                          rating: (profileController
                                      .recentlyWatched[0].userRating ??
                                  0) /
                              2,
                          content:
                              profileController.recentlyWatched[0].overview,
                          commentCount: 0,
                          movieTitle:
                              profileController.recentlyWatched[0].title,
                          movieYear: profileController
                              .recentlyWatched[0].releaseDate
                              .split('-')[0],
                          moviePosterUrl:
                              profileController.recentlyWatched[0].posterUrl,
                          onTap: () {
                            final movie = profileController.recentlyWatched[0];
                            final reviewObj = Review(
                              id: 'review_${movie.id}',
                              userId: profileController
                                      .authController.currentUser?.id ??
                                  'unknown',
                              username: profileController
                                      .authController.currentUser?.name ??
                                  'User',
                              userAvatarUrl: profileController.authController
                                      .currentUser?.profileImage ??
                                  '',
                              movieId: movie.id.toString(),
                              movieTitle: movie.title,
                              movieYear: movie.releaseDate.split('-')[0],
                              moviePosterUrl: movie.posterUrl,
                              rating: (movie.userRating ?? 0) / 2,
                              content: movie.overview,
                              watchedDate:
                                  DateTime.now(), // TODO: Get actual watch date
                              likes: 0,
                              isLiked: false,
                            );
                            Get.toNamed(AppRoutes.review, arguments: reviewObj);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.openSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.openSans(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
