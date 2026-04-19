import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _service = MovieService();

  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  String _selectedCategory = MovieService.categories.first;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isOffline = false;
  String _message = '';

  List<Movie> get movies => _movies;
  List<Movie> get filteredMovies => _filteredMovies;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String get message => _message;

  Future<void> initialize() async {
    await loadMovies();
  }

  Future<void> loadMovies({String? category}) async {
    final targetCategory = category ?? _selectedCategory;

    _isLoading = true;
    _message = '';
    notifyListeners();

    try {
      final hasInternet = await _service.hasInternet();

      if (hasInternet) {
        final data = await _service.fetchMovies(targetCategory);
        _movies = data;
        _filteredMovies = _applySearchAndFilter(_movies);
        await _service.saveCache(targetCategory, data);
        _isOffline = false;
        _message = 'Data terbaru berhasil dimuat.';
      } else {
        _isOffline = true;
        final cached = await _service.loadCache(targetCategory);

        if (cached.isNotEmpty) {
          _movies = cached;
          _filteredMovies = _applySearchAndFilter(_movies);
          _message = 'Mode offline. Menampilkan data terakhir yang tersimpan.';
        } else {
          _movies = [];
          _filteredMovies = [];
          _message = 'Tidak ada koneksi dan cache belum tersedia.';
        }
      }
    } catch (e) {
      _isOffline = true;
      final cached = await _service.loadCache(targetCategory);

      if (cached.isNotEmpty) {
        _movies = cached;
        _filteredMovies = _applySearchAndFilter(_movies);
        _message = 'Gagal mengambil data terbaru. Menampilkan cache terakhir.';
      } else {
        _movies = [];
        _filteredMovies = [];
        _message = 'Gagal memuat data film. Coba lagi nanti.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _searchQuery = '';
    await loadMovies(category: category);
  }

  Future<void> searchMovies(String query) async {
    _searchQuery = query;
    await Future.delayed(const Duration(milliseconds: 150));
    _filteredMovies = _applySearchAndFilter(_movies);
    notifyListeners();
  }

  List<Movie> _applySearchAndFilter(List<Movie> source) {
    if (_searchQuery.trim().isEmpty) return source;

    final q = _searchQuery.toLowerCase().trim();

    return source.where((movie) {
      final inTitle = movie.title.toLowerCase().contains(q);
      final inDescription = movie.description.toLowerCase().contains(q);
      final inGenres = movie.genres.any((g) => g.toLowerCase().contains(q));
      final inYear = movie.year.toString().contains(q);

      return inTitle || inDescription || inGenres || inYear;
    }).toList();
  }

  bool get hasData => _filteredMovies.isNotEmpty;
}