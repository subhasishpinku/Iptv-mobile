import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iptvmobile/HomeScreen/movie_model.dart';
import 'package:iptvmobile/services/api_service.dart';

class HomeViewModel extends StateNotifier<AsyncValue<List<Movie>>> {
  final ApiService apiService;

  HomeViewModel(this.apiService) : super(const AsyncLoading()) {
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final movies = await apiService.getMovies();
      state = AsyncData(movies);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}