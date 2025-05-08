import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/lists/controllers/list_details_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListDetailsPage extends StatelessWidget {
  final Map<String, dynamic> list;

  const ListDetailsPage({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ListDetailsController(listId: list['id'].toString()));
    final createdAt = list['created_at'] != null 
        ? DateTime.parse(list['created_at'])
        : DateTime.now();
    final formattedDate = DateFormat('MMM d, y').format(createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D36),
        elevation: 0,
        title: Text(
          list['name'] ?? 'Untitled List',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refreshList(),
        color: const Color(0xFFE9A6A6),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF3D3B54),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list['name'] ?? 'Untitled List',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      list['description'] ?? 'No description',
                      style: GoogleFonts.openSans(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${list['item_count'] ?? 0} movies',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created $formattedDate',
                          style: GoogleFonts.openSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Movies Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Movies',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9A6A6)),
                          ),
                        );
                      }

                      if (controller.error != null) {
                        return Center(
                          child: Column(
                            children: [
                              Text(
                                'Error loading movies',
                                style: GoogleFonts.openSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: controller.refreshList,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE9A6A6),
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.movies.isEmpty) {
                        return Center(
                          child: Text(
                            'No movies in this list yet',
                            style: GoogleFonts.openSans(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: controller.movies.length,
                        itemBuilder: (context, index) {
                          final movie = controller.movies[index];
                          return MovieCard(movie: movie);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to movie details
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF3D3B54),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: movie.posterPath != null
                      ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                      : 'https://via.placeholder.com/500x750?text=No+Image',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9A6A6)),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage?.toStringAsFixed(1) ?? 'N/A',
                        style: GoogleFonts.openSans(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 