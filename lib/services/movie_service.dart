import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class MovieService {
  static const String baseUrl = 'https://api.sampleapis.com/movies';

  static const List<String> categories = [
    'action-adventure',
    'animation',
    'classic',
    'comedy',
    'drama',
    'horror',
    'family',
    'mystery',
    'scifi-fantasy',
    'western',
  ];

  Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<List<Movie>> fetchMovies(String category) async {
    final url = Uri.parse('$baseUrl/$category');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load movies');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => Movie.fromJson(item as Map<String, dynamic>, category: category))
          .toList();
    }

    throw Exception('Unexpected API response');
  }

  Future<void> saveCache(String category, List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = movies.map((m) => m.toJson()).toList();
    await prefs.setString('movies_cache_$category', jsonEncode(cacheData));
  }

  Future<List<Movie>> loadCache(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('movies_cache_$category');

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .map((item) => Movie.fromCache(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}