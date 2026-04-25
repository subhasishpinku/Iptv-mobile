import 'package:iptvmobile/HomeScreen/movie_model.dart';

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
