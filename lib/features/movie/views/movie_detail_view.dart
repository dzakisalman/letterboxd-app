import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/movie.dart';
import 'package:letterboxd/features/movie/controllers/movie_detail_controller.dart';
import 'package:letterboxd/features/movie/widgets/movie_card.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieDetailView extends GetView<MovieDetailController> {
  final String movieId;

  const MovieDetailView({Key? key, required this.movieId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.loadMovieDetails(movieId);

    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.movie.value == null
                ? const Center(child: Text('Movie not found'))
                : CustomScrollView(
                    slivers: [
                      _buildAppBar(context),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMovieInfo(),
                              const SizedBox(height: 16),
                              _buildActionButtons(),
                              const SizedBox(height: 16),
                              _buildRatingSection(),
                              const SizedBox(height: 24),
                              _buildOverview(),
                              const SizedBox(height: 24),
                              _buildCastSection(),
                              const SizedBox(height: 24),
                              _buildReviewsSection(),
                              const SizedBox(height: 24),
                              _buildSimilarMovies(),
                              const SizedBox(height: 24),
                              _buildRecommendedMovies(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final movie = controller.movie.value!;
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    final movie = controller.movie.value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${movie.releaseDate.split('-')[0]} • ${movie.runtime} min',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' (${movie.voteCount} votes)',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() => ElevatedButton.icon(
              onPressed: controller.toggleWatchlist,
              icon: Icon(
                controller.isInWatchlist.value
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
              label: Text(
                controller.isInWatchlist.value
                    ? 'In Watchlist'
                    : 'Add to Watchlist',
              ),
            )),
        ElevatedButton.icon(
          onPressed: () => controller.navigateToReviewForm(),
          icon: const Icon(Icons.rate_review),
          label: const Text('Write Review'),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rating',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Obx(() => RatingBar.builder(
                  initialRating: controller.userRating.value,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: controller.rateMovie,
                )),
            const SizedBox(width: 16),
            Obx(() => controller.userRating.value > 0
                ? TextButton(
                    onPressed: controller.deleteRating,
                    child: const Text('Remove Rating'),
                  )
                : const SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(controller.movie.value!.overview),
      ],
    );
  }

  Widget _buildCastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.cast.length,
            itemBuilder: (context, index) {
              final actor = controller.cast[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: actor['profile_path'] != null
                          ? NetworkImage(
                              'https://image.tmdb.org/t/p/w200${actor['profile_path']}',
                            )
                          : null,
                      child: actor['profile_path'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      actor['name'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...controller.reviews.map((review) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review['author'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (review['rating'] != null) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        Text(review['rating'].toString()),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review['content'],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSimilarMovies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar Movies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.similarMovies.length,
            itemBuilder: (context, index) {
              final movie = controller.similarMovies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 120,
                  child: MovieCard(movie: movie),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedMovies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Movies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.recommendedMovies.length,
            itemBuilder: (context, index) {
              final movie = controller.recommendedMovies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 120,
                  child: MovieCard(movie: movie),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 