class Movie {
  final int id;
  final String title;
  final String description;
  final int duration; // in minutes
  final String posterUrl;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.posterUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] as int,
      posterUrl: json['posterUrl'] as String,
    );
  }

  /// Format duration minutes → "Xh Ym"
  String get durationFormatted {
    final h = duration ~/ 60;
    final m = duration % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
