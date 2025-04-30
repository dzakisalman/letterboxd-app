class Review {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String movieId;
  final String movieTitle;
  final String movieYear;
  final String moviePosterUrl;
  final double rating;
  final String content;
  final DateTime watchedDate;
  final int likes;
  final bool isLiked;

  Review({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.movieId,
    required this.movieTitle,
    required this.movieYear,
    required this.moviePosterUrl,
    required this.rating,
    required this.content,
    required this.watchedDate,
    required this.likes,
    this.isLiked = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      userAvatarUrl: json['user_avatar_url'] as String,
      movieId: json['movie_id'] as String,
      movieTitle: json['movie_title'] as String,
      movieYear: json['movie_year'] as String,
      moviePosterUrl: json['movie_poster_url'] as String,
      rating: (json['rating'] as num).toDouble(),
      content: json['content'] as String,
      watchedDate: DateTime.parse(json['watched_date'] as String),
      likes: json['likes'] as int,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'user_avatar_url': userAvatarUrl,
      'movie_id': movieId,
      'movie_title': movieTitle,
      'movie_year': movieYear,
      'movie_poster_url': moviePosterUrl,
      'rating': rating,
      'content': content,
      'watched_date': watchedDate.toIso8601String(),
      'likes': likes,
      'is_liked': isLiked,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? movieId,
    String? movieTitle,
    String? movieYear,
    String? moviePosterUrl,
    double? rating,
    String? content,
    DateTime? watchedDate,
    int? likes,
    bool? isLiked,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      movieYear: movieYear ?? this.movieYear,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      watchedDate: watchedDate ?? this.watchedDate,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
} 