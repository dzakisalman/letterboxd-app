import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:letterboxd/features/profile/controllers/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:letterboxd/routes/app_routes.dart';
import 'package:letterboxd/core/widgets/custom_bottom_nav.dart';

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
                    Text(
                      '${profileController.authController.currentUser?.followers ?? 0} Followers',
                      style: GoogleFonts.openSans(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${profileController.authController.currentUser?.following ?? 0} Following',
                      style: GoogleFonts.openSans(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // Stats Grid
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        '${profileController.authController.currentUser?.watchedMovies ?? 0}',
                        'Total Films',
                        Colors.pink[200]!
                      ),
                      _buildStatItem(
                        '${profileController.recentlyWatched.length}',
                        'Film This Year',
                        Colors.purple[300]!
                      ),
                      _buildStatItem(
                        '${profileController.favoriteMovies.length}',
                        'Lists',
                        Colors.red[300]!
                      ),
                      _buildStatItem(
                        '${profileController.recentlyWatched.where((m) => m.voteAverage > 0).length}',
                        'Review',
                        Colors.purple[400]!
                      ),
                    ],
                  ),
                ),
                // Favorite Films Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${profileController.authController.currentUser?.name ?? 'User'}'s Favorite Films",
          style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
            color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: profileController.favoriteMovies.length,
                          itemBuilder: (context, index) {
                            final movie = profileController.favoriteMovies[index];
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
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
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            );
                          },
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
                            "Recent Watched",
                            style: GoogleFonts.openSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                    child: Text(
                              'See All',
                              style: GoogleFonts.openSans(
                                color: Colors.grey[400],
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
                            final movie = profileController.recentlyWatched[index];
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
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
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < ((movie.userRating ?? 0) / 2).floor() ? Icons.star : Icons.star_border,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Read Review',
                                    style: GoogleFonts.openSans(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                              "Recent Reviewed",
                          style: GoogleFonts.openSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                            color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: GoogleFonts.openSans(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Review Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Avatar
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: profileController.authController.currentUser?.profileImage != null
                                  ? NetworkImage(profileController.authController.currentUser!.profileImage!)
                                  : null,
                                backgroundColor: Colors.grey[800],
                                child: profileController.authController.currentUser?.profileImage == null
                                  ? const Icon(Icons.person, color: Colors.white70)
                                  : null,
                              ),
                              const SizedBox(width: 12),
                              // Review Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          profileController.recentlyWatched[0].title,
                                          style: GoogleFonts.openSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'by ${profileController.authController.currentUser?.name ?? "User"}',
                                          style: GoogleFonts.openSans(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                        ),
                        const SizedBox(height: 4),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < (profileController.recentlyWatched[0].voteAverage / 2).floor()
                                            ? Icons.star
                                            : i < (profileController.recentlyWatched[0].voteAverage / 2)
                                              ? Icons.star_half
                                              : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                        Text(
                                      profileController.recentlyWatched[0].overview,
                          style: GoogleFonts.openSans(
                                        color: Colors.grey[300],
                            fontSize: 14,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Movie Poster
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: profileController.recentlyWatched[0].posterUrl,
                                  width: 60,
                                  height: 90,
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
                            ],
                          ),
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