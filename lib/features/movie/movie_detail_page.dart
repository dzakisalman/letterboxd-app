import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/core/services/tmdb_service.dart';
import 'package:letterboxd/features/movie/controllers/movie_detail_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(() {
      setState(() {}); // to rebuild and move the line
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

  Widget _buildDetailsSection() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.movie.overview,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
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

        SizedBox(
          height: 120,
          child: TabBarView(
            controller: _controller,
            children: [
              _buildCastSection(),
              _buildCrewSection(),
              _buildDetailsSection(),
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
                _buildAppBar(movie),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Placeholder for poster space
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 120), // Width of poster
                            const SizedBox(width: 16),
                            // Movie info
                            Expanded(
                              child: SizedBox(
                                height: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          movie.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          movie.releaseDate.split('-')[0],
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${movie.runtime} mins',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Obx(() => Text(
                                          'Directed by ${controller.movieDirector.value}',
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 12,
                                          ),
                                        )),
                                    const SizedBox(height: 12),
                                    Text(
                                      movie.overview,
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 0),
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                        MovieTabWidget(
                          cast: controller.cast,
                          crew: controller.crew,
                          movie: movie,
                        ),
                      ],
                    ),
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
            // Poster overlay
            Positioned(
              top: 160, // Adjust this value to overlap with banner
              left: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('assets/icons/eyes.svg', '40k'),
                      const SizedBox(width: 16),
                      _buildStat('assets/icons/fav.svg', '30k'),
                      const SizedBox(width: 16),
                      _buildStat('assets/icons/listed.svg', '12k'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(Movie movie) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner image
            movie.backdropUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[900]!),
            // Navy background with diagonal cut
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
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
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildStat(String svgPath, String count) {
    return Column(
      children: [
        SvgPicture.asset(
          svgPath,
          colorFilter: const ColorFilter.mode(
            Colors.white70,
            BlendMode.srcIn,
          ),
          width: 20,
          height: 20,
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white70,
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
            _buildActionButton(
              'Rate or Review',
              onPressed: controller.navigateToReviewForm,
              svgPath: 'assets/icons/queue.svg',
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              'Add to Lists',
              onPressed: () {},
              svgPath: 'assets/icons/lists.svg',
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              'Add to Watchlist',
              onPressed: controller.toggleWatchlist,
              svgPath: 'assets/icons/watchlists.svg',
            ),
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
                  Text(
                    text,
                    style: TextStyle(
                      color: backgroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ratings',
            style: TextStyle(
              color: Colors.grey,
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
                    '4.4',
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
      ),
    );
  }
}
