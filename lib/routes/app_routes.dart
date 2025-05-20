import 'package:get/get.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String movieDetail = '/movie/:id';
  static const String reviewForm = '/review/:movieId';
  static const String watchlist = '/watchlist';
  static const String diary = '/diary';
  static const String lists = '/lists';
  static const String createList = '/lists/create';
  static const String likes = '/likes';
  static const String explore = '/explore';
  static const String activity = '/activity';
  static const String review = '/review';
  static const String films = '/films';
  static const String notification = '/notification';

  static String movieDetailPath(String id) => '/movie/$id';
  
  static String reviewFormPath(String movieId, String movieTitle, String movieYear, String posterPath) => 
    '/review/$movieId?title=${Uri.encodeComponent(movieTitle)}&year=${Uri.encodeComponent(movieYear)}&poster=${Uri.encodeComponent(posterPath)}';
} 