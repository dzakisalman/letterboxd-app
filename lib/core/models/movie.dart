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

  static Movie fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Untitled Movie',
      overview: json['overview']?.toString() ?? '',
      posterPath: json['poster_path']?.toString(),
      backdropPath: json['backdrop_path']?.toString(),
      voteAverage: json['vote_average'] != null ? (json['vote_average'] as num).toDouble() : null,
      voteCount: json['vote_count'] is int ? json['vote_count'] : int.tryParse(json['vote_count']?.toString() ?? '0'),
      releaseDate: json['release_date']?.toString() ?? '',
      genres: (json['genres'] as List?)
          ?.map((genre) => genre['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList() ??
        [],
      runtime: json['runtime'] is int ? json['runtime'] : int.tryParse(json['runtime']?.toString() ?? '0'),
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