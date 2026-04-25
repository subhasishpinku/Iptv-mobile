// providers/movie_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});