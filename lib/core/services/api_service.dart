import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get accessToken => dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';

  static Map<String, String> get headers => {
        'Authorization': 'Bearer $accessToken',
        'accept': 'application/json',
      };

  static String get baseUrl => 'https://api.themoviedb.org/3';
  static String get imageBaseUrl => 'https://image.tmdb.org/t/p';
} 