import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDetailsScreen extends StatefulWidget {
  final String videoUrl;
  final String username;
  final String caption;
  final String profile;

  const VideoDetailsScreen({
    super.key,
    required this.videoUrl,
    required this.username,
    required this.caption,
    required this.profile,
  });

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late VideoPlayerController _controller;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isPlaying = false;
      } else {
        _controller.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? Stack(
              children: [
                /// 🎥 Fullscreen Video
                GestureDetector(
                  onTap: togglePlay,
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),

                /// ▶️ Play Icon
                if (!isPlaying)
                  const Center(
                    child: Icon(Icons.play_arrow,
                        size: 80, color: Colors.white),
                  ),

                /// 🔝 Top Bar
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 20),
                      Text("Reels",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Text("Friends",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                /// ❤️ Right Side Actions
                Positioned(
                  right: 12,
                  bottom: 120,
                  child: Column(
                    children: const [
                      Icon(Icons.favorite_border,
                          color: Colors.white, size: 30),
                      SizedBox(height: 20),
                      Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 28),
                      SizedBox(height: 20),
                      Icon(Icons.send,
                          color: Colors.white, size: 28),
                      SizedBox(height: 20),
                      Icon(Icons.more_vert,
                          color: Colors.white, size: 28),
                    ],
                  ),
                ),

                /// 👤 Bottom Info
                Positioned(
                  left: 12,
                  bottom: 40,
                  right: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.profile),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.caption,
                              style: const TextStyle(
                                  color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}