import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/HomeScreen/MovieDetailsScreen/movie_Details_Screen.dart';
import 'package:iptvmobile/HomeScreen/movie_model.dart';
import 'package:iptvmobile/HomeScreen/providers/providers.dart';
import 'package:iptvmobile/VideoPlayerScreen/video_player_screen.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});
  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  bool _isAutoSliding = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isAutoSliding) return;

      if (mounted && _pageController.hasClients) {
        final movieState = ref.read(homeProvider);

        movieState.whenData((movies) {
          if (movies.isEmpty) return;

          final int nextPage = ((_currentPage + 1) % movies.length).toInt();

          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  void _stopAutoSlide() {
    _isAutoSliding = false;
    _timer?.cancel();
  }

  void _resumeAutoSlide() {
    _isAutoSliding = true;
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: movieState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: ElevatedButton(
            onPressed: () => ref.read(homeProvider.notifier).fetchMovies(),
            child: const Text("Retry"),
          ),
        ),
        data: (movies) {
          if (movies.isEmpty) {
            return const Center(
              child: Text("No Movies", style: TextStyle(color: Colors.white)),
            );
          }

          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.black,
            onRefresh: () async {
              await ref.read(homeProvider.notifier).fetchMovies();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // 👈 IMPORTANT

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 🔥 Banner
                  _buildBannerCarousel(movies),

                  const SizedBox(height: 20),

                  _buildSection("Trending Movies", movies),

                  const SizedBox(height: 20),

                  _buildSection("Upcoming Movies", movies.reversed.toList()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 Banner Carousel
  Widget _buildBannerCarousel(List<Movie> movies) {
    int maxDots = 5;

    int start = _currentPage - (maxDots ~/ 2);
    if (start < 0) start = 0;
    int end = start + maxDots;
    if (end > movies.length) {
      end = movies.length;
      start = (end - maxDots).clamp(0, movies.length);
    }
    final visibleMovies = movies.sublist(start, end);

    return GestureDetector(
      onTapDown: (_) => _stopAutoSlide(),
      onTapUp: (_) => _resumeAutoSlide(),
      onTapCancel: () => _resumeAutoSlide(),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: movies.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (_, index) {
                final movie = movies[index];
                return Stack(
                  children: [
                    Image.network(
                      movie.image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),

                    // 🔥 Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),

                    // 🎬 Title + Buttons
                    Positioned(
                      bottom: 15,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🎯 Movie Title
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          // 🔥 Buttons Row
                          Row(
                            children: [
                              // ▶ PLAY BUTTON
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Open Video Player
                                  print("Play ${movie.title}");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VideoPlayerScreen(movie: movie),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text("Play"),
                              ),

                              const SizedBox(width: 10),

                              // ℹ INFO BUTTON
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                ),
                                onPressed: () {
                                  // TODO: Show details
                                  print("Info ${movie.title}");
                                  _showMovieDialog(movie);
                                },
                                icon: const Icon(Icons.info_outline),
                                label: const Text("Info"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // ✅ FIXED Indicators (NO OVERFLOW)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(visibleMovies.length, (index) {
                  final realIndex = start + index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == realIndex ? 12 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == realIndex
                          ? Colors.white
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Movie> movies) {
    final controller = PageController(viewportFraction: 0.35); // 👈 increase

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: controller,
            padEnds: false, // 👈 IMPORTANT FIX

            itemCount: movies.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  double value = 1.0;

                  if (controller.position.haveDimensions) {
                    value = controller.page! - index;
                    value = (1 - (value.abs() * 0.25)).clamp(0.85, 1.0);
                  }

                  return Transform.scale(scale: value, child: child);
                },
                child: _movieCard(movies[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _movieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 110,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(movie.image, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // 🎬 Movie Section
  Widget _buildSection1(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            itemBuilder: (_, index) {
              final movie = movies[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.image,
                    width: 110,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMovieDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎬 Banner Image (16:9 if available)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    movie.image169 ?? movie.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

                // 📄 Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎯 Title
                      Text(
                        movie.fullTitle ?? movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ⭐ Rating + Year + Duration
                      Row(
                        children: [
                          if (movie.rating != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie.rating.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),

                          const SizedBox(width: 10),

                          if (movie.year != null)
                            Text(
                              movie.year.toString(),
                              style: const TextStyle(color: Colors.white70),
                            ),

                          const SizedBox(width: 10),

                          if (movie.runtimeStr != null)
                            Text(
                              movie.runtimeStr!,
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 🎭 Genres
                      if (movie.genres != null)
                        Text(
                          movie.genres!,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),

                      const SizedBox(height: 10),

                      // 📝 Plot (DESCRIPTION FIXED)
                      Text(
                        movie.plot ?? "No description available",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🎬 Directors & Stars
                      if (movie.directors != null)
                        Text(
                          "Director: ${movie.directors}",
                          style: const TextStyle(color: Colors.white60),
                        ),

                      if (movie.stars != null)
                        Text(
                          "Stars: ${movie.stars}",
                          style: const TextStyle(color: Colors.white60),
                        ),

                      const SizedBox(height: 15),

                      // 🔥 Buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pop(context);

                              // ▶️ PLAY VIDEO
                              print("Play ${movie.videoUrl}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VideoPlayerScreen(movie: movie),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Play"),
                          ),

                          const SizedBox(width: 10),

                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Close",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
