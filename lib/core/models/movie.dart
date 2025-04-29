import 'package:letterboxd/core/services/tmdb_service.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final String releaseDate;
  final List<String> genres;
  final int? runtime;
  final double? userRating;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    required this.releaseDate,
    this.genres = const [],
    this.runtime,
    this.userRating,
  });

  String get posterUrl => posterPath != null 
    ? TMDBService.getImageUrl(posterPath!) 
    : '';

  String get backdropUrl => backdropPath != null 
    ? TMDBService.getImageUrl(backdropPath!, size: 'original') 
    : '';

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average'] != null ? (json['vote_average'] as num).toDouble() : null,
      voteCount: json['vote_count'],
      releaseDate: json['release_date'] ?? '',
      genres: (json['genres'] as List?)
          ?.map((genre) => genre['name'] as String)
          .toList() ??
        [],
      runtime: json['runtime'],
      userRating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genres': genres,
      'runtime': runtime,
      'user_rating': userRating,
    };
  }
} 