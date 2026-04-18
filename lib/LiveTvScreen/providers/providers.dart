import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/services/api_service.dart';
import '../repository/channel_repository.dart';
import '../models/channel_model.dart';

final apiProvider = Provider((ref) => ApiService());

final channelRepositoryProvider = Provider(
  (ref) => ChannelRepository(ref.read(apiProvider)),
);

final channelProvider = FutureProvider<List<Channel>>((ref) async {
  return ref.read(channelRepositoryProvider).fetchChannels();
});