import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/features/movie/controllers/movie_controller.dart';
import 'package:letterboxd/features/movie/widgets/movie_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilmsPage extends StatefulWidget {
  const FilmsPage({super.key});

  @override
  State<FilmsPage> createState() => _FilmsPageState();
}

class _FilmsPageState extends State<FilmsPage> {
  bool _isGridView = false;
  late MovieController _movieController;

  @override
  void initState() {
    super.initState();
    print('[FilmsPage] Initializing...');
    _movieController = Get.find<MovieController>();
    // Explicitly refresh rated movies when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[FilmsPage] Post frame callback - refreshing movies...');
      _movieController.refreshRatedMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[FilmsPage] Building UI...');

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D36),
        title: Text(
          'Films',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              _isGridView ? 'assets/icons/list.svg' : 'assets/icons/grid.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        print('[FilmsPage] Rebuilding with Obx...');
        print('[FilmsPage] Loading state: ${_movieController.isLoading}');
        print('[FilmsPage] Rated movies count: ${_movieController.ratedMovies.length}');

        if (_movieController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final ratedMovies = _movieController.ratedMovies;
        
        if (ratedMovies.isEmpty) {
          print('[FilmsPage] No rated movies found');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No rated movies yet',
                  style: GoogleFonts.openSans(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rate movies to see them here',
                  style: GoogleFonts.openSans(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        print('[FilmsPage] Displaying ${ratedMovies.length} rated movies');

        if (_isGridView) {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.625,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: ratedMovies.length,
            itemBuilder: (context, index) {
              final movie = ratedMovies[index];
              return MovieCard(
                movie: movie,
              );
            },
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ratedMovies.length,
            itemBuilder: (context, index) {
              final movie = ratedMovies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: movie.posterUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                            memCacheWidth: 200,
                            memCacheHeight: 300,
                            placeholder: (context, url) => _buildPlaceholder(),
                            errorWidget: (context, url, error) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (movie.releaseDate.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              movie.releaseDate.split('-')[0],
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                          if (movie.userRating != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  final rating = movie.userRating! / 2; // Convert to 5-star scale
                                  final fullStars = rating.floor();
                                  final hasHalfStar = rating - fullStars >= 0.5;

                                  if (index < fullStars) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: SvgPicture.asset(
                                        'assets/icons/star.svg',
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFE53935),
                                          BlendMode.srcIn,
                                        ),
                                        width: 14,
                                        height: 14,
                                      ),
                                    );
                                  } else if (index == fullStars && hasHalfStar) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: SvgPicture.asset(
                                        'assets/icons/halfstar.svg',
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFE53935),
                                          BlendMode.srcIn,
                                        ),
                                        width: 14,
                                        height: 14,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      }),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 150,
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.movie,
          color: Colors.white54,
          size: 32,
        ),
      ),
    );
  }
} 