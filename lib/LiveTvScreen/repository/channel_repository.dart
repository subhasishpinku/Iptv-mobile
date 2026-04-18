import 'package:iptvmobile/services/api_service.dart';

import '../models/channel_model.dart';

class ChannelRepository {
  final ApiService api;

  ChannelRepository(this.api);

  Future<List<Channel>> fetchChannels() {
    return api.getChannels();
  }
}