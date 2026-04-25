import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iptvmobile/HomeScreen/movie_model.dart';
import '../providers/movie_provider.dart';

class MovieState {
  final bool isLoading;
  final List<Movie> movies;
  final String? error;

  MovieState({
    this.isLoading = false,
    this.movies = const [],
    this.error,
  });

  MovieState copyWith({
    bool? isLoading,
    List<Movie>? movies,
    String? error,
  }) {
    return MovieState(
      isLoading: isLoading ?? this.isLoading,
      movies: movies ?? this.movies,
      error: error,
    );
  }
}

class MovieViewModel extends StateNotifier<MovieState> {
  final Ref ref;

  MovieViewModel(this.ref) : super(MovieState());

  Future<void> fetchMovies() async {
    try {
      state = state.copyWith(isLoading: true);

      final api = ref.read(apiServiceProvider);
      final data = await api.getMovies();

      state = state.copyWith(
        isLoading: false,
        movies: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final movieViewModelProvider =
    StateNotifierProvider<MovieViewModel, MovieState>((ref) {
  return MovieViewModel(ref);
});