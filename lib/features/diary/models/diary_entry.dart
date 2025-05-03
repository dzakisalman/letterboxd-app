class DiaryEntry {
  final String tmdbId;
  final String imdbId;
  final String type;
  final String title;
  final DateTime releaseDate;
  final String? seasonNumber;
  final String? episodeNumber;
  final double tmdbRating;
  final double userRating;
  final DateTime watchedDate;

  DiaryEntry({
    required this.tmdbId,
    required this.imdbId,
    required this.type,
    required this.title,
    required this.releaseDate,
    this.seasonNumber,
    this.episodeNumber,
    required this.tmdbRating,
    required this.userRating,
    required this.watchedDate,
  });

  factory DiaryEntry.fromCsv(Map<String, dynamic> map) {
    DateTime parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) {
        return DateTime.now();
      }
      try {
        // Remove the 'Z' and try parsing
        final cleanDate = dateStr.replaceAll('Z', '');
        return DateTime.parse(cleanDate);
      } catch (e) {
        print('Error parsing date: $dateStr');
        return DateTime.now();
      }
    }

    return DiaryEntry(
      tmdbId: map['TMDb ID']?.toString() ?? '',
      imdbId: map['IMDb ID']?.toString() ?? '',
      type: map['Type']?.toString() ?? '',
      title: map['Name']?.toString() ?? '',
      releaseDate: parseDate(map['Release Date']?.toString()),
      seasonNumber: map['Season Number']?.toString(),
      episodeNumber: map['Episode Number']?.toString(),
      tmdbRating: double.tryParse(map['Rating']?.toString() ?? '') ?? 0.0,
      userRating: double.tryParse(map['Your Rating']?.toString() ?? '') ?? 0.0,
      watchedDate: parseDate(map['Date Rated']?.toString()),
    );
  }
} 