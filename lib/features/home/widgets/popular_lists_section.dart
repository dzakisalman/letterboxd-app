import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterboxd/features/lists/controllers/lists_controller.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PopularListsSection extends StatelessWidget {
  const PopularListsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Popular Lists This Month',
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: GetBuilder<ListsController>(
            init: ListsController(),
            builder: (controller) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.lists.isEmpty) {
                return Center(
                  child: Text(
                    'No lists yet',
                    style: GoogleFonts.openSans(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: controller.lists.length,
                itemBuilder: (context, index) {
                  final list = controller.lists[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _ListCard(
                      list: list,
                      userName: authController.currentUser?.name ?? 'Guest',
                      userAvatar: authController.currentUser?.profileImage,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final Map<String, dynamic> list;
  final String userName;
  final String? userAvatar;

  const _ListCard({required this.list, required this.userName, required this.userAvatar});

  @override
  Widget build(BuildContext context) {
    final List movies = list['movies'] ?? [];
    final List<String> posterUrls = movies
        .where((movie) =>
            (movie is Map && movie['poster_path'] != null) ||
            (movie is dynamic && movie.posterUrl != null && movie.posterUrl != ''))
        .map<String>((movie) {
          if (movie is Map && movie['poster_path'] != null) {
            return 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';
          } else if (movie is dynamic && movie.posterUrl != null) {
            return movie.posterUrl;
          }
          return '';
        })
        .where((url) => url.isNotEmpty)
        .toList();
    return Container(
      width: 180,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster stack
            posterUrls.isNotEmpty
                ? MovieStackList(posterUrls: posterUrls)
                : Center(
                    child: Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.white, size: 32),
                    ),
                  ),
            const SizedBox(height: 16),
            Text(
              list['name'] ?? 'Untitled List',
              style: GoogleFonts.openSans(
                color: const Color(0xFFE9A6A6),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: userAvatar != null ? NetworkImage(userAvatar!) : null,
                  child: userAvatar == null
                      ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'G', style: const TextStyle(color: Color(0xFFE9A6A6), fontSize: 11, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    userName,
                    style: GoogleFonts.openSans(color: const Color(0xFFE9A6A6), fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 14),
                const SizedBox(width: 2),
                Text('500', style: TextStyle(color: Color(0xFFE9A6A6), fontSize: 11)),
                const SizedBox(width: 6),
                const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 14),
                const SizedBox(width: 2),
                Text('79', style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MovieStackList extends StatelessWidget {
  final List<String> posterUrls;
  const MovieStackList({super.key, required this.posterUrls});

  @override
  Widget build(BuildContext context) {
    final limitedPosters = posterUrls.length > 4 ? posterUrls.sublist(0, 4) : posterUrls;
    return SizedBox(
      height: 90,
      child: Stack(
        children: limitedPosters.asMap().entries.map((entry) {
          int index = entry.key;
          String posterUrl = entry.value;
          return Positioned(
            left: index * 28.0,
            child: Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(posterUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}