import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loading.dart';
import 'movie_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = Future.microtask(() => context.read<MovieProvider>().initialize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LabMob Movie App'),
      ),
      body: FutureBuilder(
        future: _initialLoad,
        builder: (context, snapshot) {
          return Consumer<MovieProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.movies.isEmpty) {
                return const ShimmerLoading();
              }

              return RefreshIndicator(
                onRefresh: () => provider.loadMovies(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCategoryFilter(context, provider),
                    const SizedBox(height: 16),
                    _buildSearchField(context, provider),
                    const SizedBox(height: 16),

                    if (provider.message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          provider.message,
                          style: TextStyle(
                            color: provider.isOffline ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    if (!provider.isLoading &&
                        provider.filteredMovies.isEmpty &&
                        provider.message.contains('Gagal'))
                      const ErrorState(
                        title: 'Data gagal dimuat',
                        subtitle: 'Coba refresh atau pilih kategori lain.',
                      )
                    else if (!provider.isLoading && provider.filteredMovies.isEmpty)
                      const EmptyState(
                        title: 'Film tidak ditemukan',
                        subtitle: 'Coba kata kunci lain atau ganti kategori.',
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.filteredMovies.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (context, index) {
                          final movie = provider.filteredMovies[index];
                          return MovieCard(
                            movie: movie,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailPage(movie: movie),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, MovieProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Pilih kategori film',
        border: OutlineInputBorder(),
      ),
      items: providerServiceCategories()
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<MovieProvider>().changeCategory(value);
        }
      },
    );
  }

  Widget _buildSearchField(BuildContext context, MovieProvider provider) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Cari film',
        hintText: 'Judul, genre, tahun...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        context.read<MovieProvider>().searchMovies(value);
      },
    );
  }

  List<String> providerServiceCategories() {
    return const [
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
  }
}