import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iptvmobile/services/api_service.dart';
import '../viewmodels/home_viewmodel.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final homeProvider =
    StateNotifierProvider<HomeViewModel, AsyncValue>((ref) {
  final api = ref.watch(apiServiceProvider);
  return HomeViewModel(api);
});