import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/lists/controllers/list_details_controller.dart';
import 'package:letterboxd/features/lists/pages/edit_list_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:letterboxd/features/authentication/controllers/auth_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letterboxd/core/widgets/star_rating.dart';
import 'sort_list_page.dart';

class ListDetailsPage extends StatefulWidget {
  final Map<String, dynamic> list;

  const ListDetailsPage({
    super.key,
    required this.list,
  });

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> {
  String _sortBy = 'vote_average.desc';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ListDetailsController(listId: widget.list['id'].toString()));
    final createdAt = widget.list['created_at'] != null 
        ? DateTime.parse(widget.list['created_at'])
        : DateTime.now();
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final authController = Get.find<AuthController>();
    final String displayName = authController.currentUser?.name ?? 'Unknown';
    final String? avatarUrl = authController.currentUser?.profileImage;

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D36),
        elevation: 0,
        title: Text('List', style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () async {
              final selected = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (context) => SortListPage(selected: _sortBy),
                ),
              );
              if (selected != null && selected != _sortBy) {
                setState(() {
                  _sortBy = selected;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final result = await Get.to(() => EditListPage(
                    list: widget.list,
                    movies: controller.movies,
                  ));
              if (result == true) {
                controller.refreshList();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              // TODO: Implement delete functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refreshList(),
        color: const Color(0xFFE9A6A6),
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading movies', style: GoogleFonts.openSans(color: Colors.white)),
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
          // Sorting logic
          List<Movie> sortedMovies = List.from(controller.movies);
          sortedMovies.sort((a, b) => _compareMovies(a, b, _sortBy));
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // HEADER
              Container(
                color: const Color(0xFF1F1D36),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: (avatarUrl == null || avatarUrl.isEmpty)
                              ? Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          displayName,
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.list['name'] ?? 'Untitled List',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.list['description'] ?? 'No description',
                      style: GoogleFonts.openSans(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              // MOVIE LIST
              ...List.generate(sortedMovies.length, (index) {
                final movie = sortedMovies[index];
                return Column(
                  children: [
                    MovieListItem(
                      rank: index + 1,
                      movie: movie,
                    ),
                    if (index != sortedMovies.length - 1)
                      Divider(color: Colors.grey[800], thickness: 1, height: 0),
                  ],
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  int _compareMovies(Movie a, Movie b, String sortBy) {
    final parts = sortBy.split('.');
    final field = parts[0];
    final order = parts[1];
    int result = 0;
    switch (field) {
      case 'release_date':
        result = a.releaseDate.compareTo(b.releaseDate);
        break;
      case 'vote_average':
        result = (a.voteAverage ?? 0).compareTo(b.voteAverage ?? 0);
        break;
      case 'vote_count':
        result = (a.voteCount ?? 0).compareTo(b.voteCount ?? 0);
        break;
      case 'title':
        result = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        break;
      case 'length':
        result = (a.runtime ?? 0).compareTo(b.runtime ?? 0);
        break;
      default:
        result = 0;
    }
    return order == 'desc' ? -result : result;
  }
}

class MovieListItem extends StatelessWidget {
  final int rank;
  final Movie movie;

  const MovieListItem({super.key, required this.rank, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF353542),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              movie.posterPath != null
                  ? 'https://image.tmdb.org/t/p/w92${movie.posterPath}'
                  : 'https://via.placeholder.com/92x138?text=No+Image',
              width: 48,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      movie.releaseDate?.substring(0, 4) ?? '',
                      style: GoogleFonts.openSans(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (movie.voteAverage != null)
                      StarRating(rating: movie.voteAverage!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 