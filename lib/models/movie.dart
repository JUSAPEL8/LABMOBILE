class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String category;
  final double rating;
  final int year;
  final List<String> genres;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.category,
    required this.rating,
    required this.year,
    required this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json, {String category = ''}) {
    final rawGenres = json['genres'] ?? json['genre'] ?? json['category'];
    List<String> parsedGenres = [];

    if (rawGenres is List) {
      parsedGenres = rawGenres.map((e) => e.toString()).toList();
    } else if (rawGenres is String && rawGenres.isNotEmpty) {
      parsedGenres = rawGenres
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Movie(
      id: (json['id'] ?? json['imdbId'] ?? json['imdb_id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Untitled').toString(),
      description: (json['description'] ??
              json['plot'] ??
              json['overview'] ??
              'No description available.')
          .toString(),
      posterUrl: (json['posterURL'] ??
              json['posterUrl'] ??
              json['poster'] ??
              json['image'] ??
              '')
          .toString(),
      category: category,
      rating: _parseDouble(json['imdbRating'] ?? json['rating'] ?? json['score']),
      year: _parseInt(json['year'] ?? json['releaseYear']),
      genres: parsedGenres,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'category': category,
      'rating': rating,
      'year': year,
      'genres': genres,
    };
  }

  factory Movie.fromCache(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled').toString(),
      description: (json['description'] ?? 'No description available.').toString(),
      posterUrl: (json['posterUrl'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      rating: _parseDouble(json['rating']),
      year: _parseInt(json['year']),
      genres: (json['genres'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }
}