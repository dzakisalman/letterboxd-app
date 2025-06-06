class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? profileImage;
  final int watchedMovies;
  final int reviews;
  final int followers;
  final int following;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.profileImage,
    this.watchedMovies = 0,
    this.reviews = 0,
    this.followers = 0,
    this.following = 0,
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'],
      watchedMovies: json['watchedMovies'] ?? 0,
      reviews: json['reviews'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'watchedMovies': watchedMovies,
      'reviews': reviews,
      'followers': followers,
      'following': following,
    };
  }
} 