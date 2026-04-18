import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/LiveTvScreen/VideoPlayerLiveScreen/video_player_live_screen.dart';
import 'package:iptvmobile/LiveTvScreen/providers/providers.dart';
import 'package:video_player/video_player.dart';

class LiveTvScreen extends ConsumerStatefulWidget {
  const LiveTvScreen({super.key});

  @override
  ConsumerState<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends ConsumerState<LiveTvScreen> {
  @override
  Widget build(BuildContext context) {
    final channelState = ref.watch(channelProvider);

    return Scaffold(
      // appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: channelState.when(
        loading: () => const _LoadingWidget(),
        error: (e, _) => _ErrorWidget(error: e.toString()),
        data: (channels) => _BodyContent(channels: channels),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Live TV",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.95),
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Navigate to favorites
          },
        ),
      ],
    );
  }
}

class _BodyContent extends StatelessWidget {
  final List channels;

  const _BodyContent({required this.channels});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Featured Banner Sliver
        SliverToBoxAdapter(
          child: _FeaturedBanner(channels: channels),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Recommended Section
        _SectionSlider(
          title: "Recommended for You",
          channels: channels,
          icon: Icons.trending_up,
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Popular Section
        _SectionSlider(
          title: "Most Popular",
          channels: channels.reversed.toList(),
          icon: Icons.whatshot,
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Recently Added Section (if you have data)
        if (channels.length > 10)
          _SectionSlider(
            title: "Recently Added",
            channels: channels.sublist(0, 10),
            icon: Icons.fiber_new,
          ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _FeaturedBanner extends StatefulWidget {
  final List channels;

  const _FeaturedBanner({required this.channels});

  @override
  State<_FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<_FeaturedBanner> {
  late PageController _pageController;
  int _currentIndex = 0;

  Timer? _timer;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _initVideo(widget.channels[_currentIndex]);

    _startAutoSlide();
  }

  void _initVideo(channel) {
    _videoController?.dispose();

    _videoController = VideoPlayerController.network(channel.streamUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController!.setVolume(0); // mute autoplay
        _videoController!.play();
      });
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;

      _currentIndex =
          (_currentIndex + 1) % widget.channels.length;

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      _initVideo(widget.channels[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.channels.isEmpty) return const SizedBox();

    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.channels.length,
        onPageChanged: (index) {
          _currentIndex = index;
          _initVideo(widget.channels[index]);
        },
        itemBuilder: (context, index) {
          final channel = widget.channels[index];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerLiveScreen(
                      url: channel.streamUrl,
                      title: channel.name,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 🔥 Video Background
                    _videoController != null &&
                            _videoController!.value.isInitialized &&
                            index == _currentIndex
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController!.value.size.width,
                              height: _videoController!.value.size.height,
                              child: VideoPlayer(_videoController!),
                            ),
                          )
                        : Image.network(
                            channel.logoUrl,
                            fit: BoxFit.cover,
                          ),

                    // Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Info
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "LIVE",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            channel.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class _SectionSlider extends StatelessWidget {
  final String title;
  final List channels;
  final IconData icon;
  
  const _SectionSlider({
    required this.title,
    required this.channels,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Show all channels
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: channels.length > 10 ? 10 : channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return _ChannelCard(
                  channel: channel,
                  viewCount: (index + 1) * 100, // Pass viewCount instead of using index inside
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final dynamic channel;
  final int viewCount;
  
  const _ChannelCard({
    required this.channel,
    required this.viewCount,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerLiveScreen(
              url: channel.streamUrl,
              title: channel.name,
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      channel.logoUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.tv,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                    // Gradient overlay on hover effect
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Play icon overlay
                    const Positioned(
                      bottom: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.play_arrow,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Channel Name
            Text(
              channel.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Metadata
            Row(
              children: [
                const Icon(
                  Icons.visibility,
                  size: 10,
                  color: Colors.white54,
                ),
                const SizedBox(width: 2),
                Text(
                  "$viewCount",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading channels...",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends ConsumerWidget {
  final String error;
  
  const _ErrorWidget({required this.error});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            "Failed to load channels",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(channelProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}