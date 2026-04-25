import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/MovieScreen/viewmodels/movie_viewmodel.dart';
import 'package:iptvmobile/VideoPlayerScreen/video_player_screen.dart';

class MovieScreen extends ConsumerStatefulWidget {
  const MovieScreen({super.key});

  @override
  ConsumerState<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends ConsumerState<MovieScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() {
      ref.read(movieViewModelProvider.notifier).fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movieViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(state.error!,
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final movies = state.movies;

    if (movies.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No Data", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final movie = movies.first;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔴 BANNER
            Stack(
              children: [
                Image.network(
                  movie.image169!.isNotEmpty
                      ? movie.image169!
                      : "https://via.placeholder.com/300",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start Watching Now"),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${movie.rating}/5",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        movie.plot!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        movie.genres!,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),

            /// TABS
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.red,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Movie"),
                Tab(text: "Trailers"),
                Tab(text: "More Like This"),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEpisodes(movies),
                  const Center(
                      child: Text("Trailers",
                          style: TextStyle(color: Colors.white))),
                  _buildMoreLikeThis(movies),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🎞️ Episodes
Widget _buildEpisodes(List movies) {
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: movies.length,
    itemBuilder: (context, index) {
      final m = movies[index];

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(movie: m),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      m.image169.isNotEmpty
                          ? m.image169
                          : "https://via.placeholder.com/150",
                      height: 80,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 30)
                ],
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      m.plot,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

  /// 🎬 More Like This
  Widget _buildMoreLikeThis(List movies) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final m = movies[index];

        return Column(
          children: [
            Image.network(
              m.image,
              height: 120,
              fit: BoxFit.cover,
            ),
            Text(
              m.title,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            )
          ],
        );
      },
    );
  }
}