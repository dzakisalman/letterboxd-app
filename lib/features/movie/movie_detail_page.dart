import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/movie/controllers/movie_detail_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letterboxd/core/widgets/review_card.dart';
import 'package:letterboxd/features/review/models/review.dart';
import 'package:letterboxd/routes/app_routes.dart';

// Custom clipper for diagonal line
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from bottom-left
    path.moveTo(0, size.height);
    // Go to bottom-right
    path.lineTo(size.width, size.height);
    // Go to top-right
    path.lineTo(size.width, size.height * 0.3);
    // Create concave curve to bottom-left
    path.quadraticBezierTo(
      size.width * 0.5, // control point x
      size.height * 0.8, // control point y - pulls the curve down
      0, // end point x
      size.height, // end point y
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MovieTabWidget extends StatefulWidget {
  final List<dynamic> cast;
  final List<dynamic> crew;
  final Movie movie;

  const MovieTabWidget({
    super.key,
    required this.cast,
    required this.crew,
    required this.movie,
  });

  @override
  State<MovieTabWidget> createState() => _MovieTabWidgetState();
}

class _MovieTabWidgetState extends State<MovieTabWidget> with SingleTickerProviderStateMixin {
  late TabController _controller;
  final GlobalKey _detailsKey = GlobalKey();
  double _currentHeight = 120.0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(() {
      setState(() {
        // Update height based on active tab
        if (_controller.index == 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final RenderBox? renderBox = _detailsKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              setState(() {
                _currentHeight = renderBox.size.height;
              });
            }
          });
        } else {
          _currentHeight = 120.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCastSection() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.cast.length,
      itemBuilder: (context, index) {
        final actor = widget.cast[index];
        return Container(
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: actor['profile_path'] != null
                    ? CachedNetworkImageProvider(
                        TMDBService.getImageUrl(actor['profile_path']),
                      )
                    : null,
                backgroundColor: Colors.grey[800],
                child: actor['profile_path'] == null
                    ? const Icon(Icons.person, color: Colors.white70)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                actor['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                actor['character'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCrewSection() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.crew.length,
      itemBuilder: (context, index) {
        final crew = widget.crew[index];
        return Container(
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: crew['profile_path'] != null
                    ? CachedNetworkImageProvider(
                        TMDBService.getImageUrl(crew['profile_path']),
                      )
                    : null,
                backgroundColor: Colors.grey[800],
                child: crew['profile_path'] == null
                    ? const Icon(Icons.person, color: Colors.white70)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                crew['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                crew['job'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Casts'),
            Tab(text: 'Crews'),
            Tab(text: 'Details'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          indicator: BoxDecoration(
            color: const Color(0xFF864879),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 15),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 9),
          splashBorderRadius: BorderRadius.circular(20),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          tabAlignment: TabAlignment.start,
        ),

        // Animated line under active tab
        Align(
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _controller.animation!,
            builder: (context, child) {
              final selectedIndex = _controller.index;
              final tabWidth = 73.0; // Fixed width for each tab
              final leftPadding = selectedIndex * tabWidth + 13;

              return Padding(
                padding: EdgeInsets.only(left: leftPadding, top: 4),
                child: Container(
                  width: tabWidth - 30,
                  height: 3,
                  color: const Color(0xFF864879),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _currentHeight,
          curve: Curves.easeInOut,
          child: TabBarView(
            controller: _controller,
            children: [
              _buildCastSection(),
              _buildCrewSection(),
              SingleChildScrollView(
                key: _detailsKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre
                      if (widget.movie.genres.isNotEmpty) ...[
                        const Text(
                          'Genres',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.movie.genres.map((genre) => 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF864879),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Release Date
                      const Text(
                        'Release Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.movie.releaseDate,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MovieDetailPage extends StatefulWidget {
  final String movieId;

  const MovieDetailPage({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final controller = Get.put(MovieDetailController());

  @override
  void initState() {
    super.initState();
    controller.loadMovieDetails(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D36),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final movie = controller.movie.value;
        if (movie == null) {
          return const Center(child: Text('Movie not found'));
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Banner image with gradient overlay
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.7),
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.darken,
                          child: movie.backdropUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: movie.backdropUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.grey[900]!),
                        ),
                      ),
                      // Navy background with diagonal cut
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 160,
                        child: ClipPath(
                          clipper: DiagonalClipper(),
                          child: Container(
                            color: const Color(0xFF1F1D36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Info Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Poster and Stats
                            Column(
                              children: [
                                // Poster
                                Container(
                                  width: 120,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: movie.posterUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Stats Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(() => _buildStat(
                                      'assets/icons/eyes.svg', 
                                      '40k',
                                      isActive: controller.userRating.value > 0,
                                      activeColor: Colors.green,
                                    )),
                                    const SizedBox(width: 16),
                                    Obx(() => _buildStat(
                                      'assets/icons/fav.svg', 
                                      '30k',
                                      isActive: controller.isFavorite.value,
                                      activeColor: Colors.red,
                                    )),
                                    const SizedBox(width: 16),
                                    Obx(() => _buildStat(
                                      'assets/icons/listed.svg', 
                                      '12k',
                                      isActive: controller.isInList.value,
                                      activeColor: Colors.blue,
                                    )),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Right side - Title and Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          movie.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: Text(
                                          movie.releaseDate.split('-')[0],
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${movie.runtime} mins',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() => Text(
                                    'Directed by ${controller.movieDirector.value}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  )),
                                  const SizedBox(height: 16),
                                  Text(
                                    movie.overview,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Rest of the content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildActionButtons(),
                            const SizedBox(height: 24),
                            MovieTabWidget(
                              cast: controller.cast,
                              crew: controller.crew,
                              movie: movie,
                            ),
                            const SizedBox(height: 32),
                            // All Reviews Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'All Reviews',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to all reviews page
                                  },
                                  child: Text(
                                    'See All',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF9C4FD6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Reviews List
                            Obx(() {
                              if (controller.reviews.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No reviews yet',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: controller.reviews.take(3).map((review) {
                                  final authorDetails = review['author_details'] ?? {};
                                  final avatarPath = authorDetails['avatar_path']?.toString();
                                  
                                  print('[MovieDetail] Raw review data: ${review.toString()}');
                                  print('[MovieDetail] Raw author details: ${authorDetails.toString()}');
                                  print('[MovieDetail] Original avatar_path: $avatarPath');
                                  
                                  String? avatarUrl;
                                  if (avatarPath != null && avatarPath.isNotEmpty) {
                                    if (avatarPath.startsWith('/http') || avatarPath.startsWith('http')) {
                                      avatarUrl = avatarPath.startsWith('/') ? avatarPath.substring(1) : avatarPath;
                                      print('[MovieDetail] Using direct URL avatar: $avatarUrl');
                                    } else {
                                      avatarUrl = 'https://image.tmdb.org/t/p/w185$avatarPath';
                                      print('[MovieDetail] Using TMDB path avatar: $avatarUrl');
                                    }
                                  } else {
                                    avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(review['author'] ?? 'Anonymous')}&background=random';
                                    print('[MovieDetail] Using generated avatar: $avatarUrl');
                                  }
                                  
                                  print('[MovieDetail] Final avatar URL: $avatarUrl');
                                  
                                  return ReviewCard(
                                    authorName: review['author'] ?? 'Anonymous',
                                    avatarUrl: avatarUrl,
                                    rating: (authorDetails['rating'] ?? 0.0) / 2,
                                    content: review['content'] ?? 'No content',
                                    commentCount: 0,
                                    movieTitle: movie.title,
                                    movieYear: movie.releaseDate.split('-')[0],
                                    moviePosterUrl: movie.posterUrl,
                                    isDetailPage: true,
                                    onTap: () {
                                      final reviewObj = Review(
                                        id: review['id'].toString(),
                                        userId: authorDetails['id']?.toString() ?? 'unknown',
                                        username: review['author'] ?? 'Anonymous',
                                        userAvatarUrl: avatarPath ?? '',  // Use original avatar_path instead of generated URL
                                        movieId: movie.id.toString(),
                                        movieTitle: movie.title,
                                        movieYear: movie.releaseDate.split('-')[0],
                                        moviePosterUrl: movie.posterUrl,
                                        rating: (authorDetails['rating'] ?? 0.0) / 2,
                                        content: review['content'] ?? 'No content',
                                        watchedDate: DateTime.parse(review['created_at'] ?? DateTime.now().toIso8601String()),
                                        likes: 0,
                                        isLiked: false,
                                      );
                                      print('[MovieDetail] Created Review object with avatar path: ${reviewObj.userAvatarUrl}');
                                      Get.toNamed(AppRoutes.review, arguments: reviewObj);
                                    },
                                  );
                                }).toList(),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Back Button
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStat(String svgPath, String count, {bool isActive = false, Color activeColor = Colors.white70}) {
    final color = isActive ? activeColor : Colors.white70;
    
    return Column(
      children: [
        SvgPicture.asset(
          svgPath,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
          width: 20,
          height: 20,
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (controller.userRating.value > 0) {
                final rating = controller.userRating.value;
                final fullStars = rating.floor();
                final hasHalfStar = rating - fullStars >= 0.5;
                
                return GestureDetector(
                  onTap: controller.navigateToReviewForm,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9A6A6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(fullStars, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: SvgPicture.asset(
                              'assets/icons/star.svg',
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF1F1D36),
                                BlendMode.srcIn,
                              ),
                              width: 14,
                              height: 14,
                            ),
                          );
                        }),
                        if (hasHalfStar)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: SvgPicture.asset(
                              'assets/icons/halfstar.svg',
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF1F1D36),
                                BlendMode.srcIn,
                              ),
                              width: 14,
                              height: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                return _buildActionButton(
                  'Rate or Review',
                  onPressed: controller.navigateToReviewForm,
                  svgPath: 'assets/icons/queue.svg',
                );
              }
            }),
            const SizedBox(height: 8),
            _buildActionButton(
              'Add to Lists',
              onPressed: () {},
              svgPath: 'assets/icons/lists.svg',
            ),
            const SizedBox(height: 8),
            Obx(() => _buildActionButton(
              controller.isInWatchlist.value ? 'Remove from Watchlist' : 'Add to Watchlist',
              onPressed: controller.toggleWatchlist,
              svgPath: 'assets/icons/watchlists.svg',
            )),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRatingsSection(),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text,
      {required VoidCallback onPressed, required String svgPath}) {
    final Color activeColor = const Color(0xFFE9A6A6);
    final Color backgroundColor = const Color(0xFF1F1D36);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final buttonWidth = screenWidth * 0.35;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              width: buttonWidth,
              height: 32,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    svgPath,
                    colorFilter: ColorFilter.mode(
                      backgroundColor,
                      BlendMode.srcIn,
                    ),
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: backgroundColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingsSection() {
    final movie = controller.movie.value!;
    final tmdbRating = movie.voteAverage != null ? (movie.voteAverage! / 2).toStringAsFixed(1) : 'N/A';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ratings',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left star
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: SvgPicture.asset(
                'assets/icons/star.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
                width: 10,
                height: 10,
              ),
            ),
            const SizedBox(width: 4),
            // Rating bars
            Expanded(
              child: SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    8,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: [20, 30, 40, 50, 60, 70, 80, 90][index]
                                .toDouble() *
                            0.7,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Rating number and stars
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tmdbRating,
                  style: TextStyle(
                    color: Colors.pink[200],
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: SvgPicture.asset(
                        'assets/icons/star.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.red,
                          BlendMode.srcIn,
                        ),
                        width: 8,
                        height: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
