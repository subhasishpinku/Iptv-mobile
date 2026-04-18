import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iptvmobile/HomeScreen/full_screen_player.dart';
import 'package:video_player/video_player.dart';
import 'package:iptvmobile/HomeScreen/movie_model.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late VideoPlayerController _controller;

  double _currentBrightness = 0.5;
  double _currentVolume = 0.5;

  bool _showOverlay = false;
  bool _isVolume = true;

  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    VolumeController.instance.showSystemUI = false; // 👈 ADD THIS

    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.movie.videoUrl))
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
          });

    _initControls();
  }

  Future<void> _initControls() async {
    _currentBrightness = await ScreenBrightness().current;
    _currentVolume = await VolumeController.instance.getVolume();
    setState(() {});
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  /// 🎯 Gesture
  void _handleVerticalDrag(DragUpdateDetails details) async {
    double delta = details.primaryDelta!;

    final screenWidth = MediaQuery.of(context).size.width;
    final touchX = details.globalPosition.dx;

    setState(() => _showOverlay = true);

    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 1), () {
      setState(() => _showOverlay = false);
    });

    if (touchX < screenWidth / 2) {
      // 👉 LEFT SIDE = BRIGHTNESS
      _isVolume = false;

      _currentBrightness -= delta / 300;
      _currentBrightness = _currentBrightness.clamp(0.0, 1.0);

      await ScreenBrightness().setScreenBrightness(_currentBrightness);
    } else {
      // 👉 RIGHT SIDE = VOLUME
      _isVolume = true;

      _currentVolume -= delta / 300;
      _currentVolume = _currentVolume.clamp(0.0, 1.0);

      await VolumeController.instance.setVolume(_currentVolume);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              /// 🎬 VIDEO
              GestureDetector(
                onVerticalDragUpdate: _handleVerticalDrag,
                child: Stack(
                  children: [
                    _controller.value.isInitialized
                        ? SizedBox(
                            width: double.infinity,
                            height: 250,
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          )
                        : Image.network(
                            widget.movie.image169 ?? widget.movie.image,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),

                    Container(
                      height: 250,
                      color: Colors.black.withOpacity(0.3),
                    ),

                    /// ▶ PLAY
                    Positioned.fill(
                      child: Center(
                        child: GestureDetector(
                          onTap: _togglePlay,
                          child: AnimatedOpacity(
                            opacity: _controller.value.isPlaying ? 0 : 1,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// ▶ PLAY BUTTON
                    Positioned.fill(
                      child: Center(
                        child: GestureDetector(
                          onTap: _togglePlay,
                          child: AnimatedOpacity(
                            opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// 🎮 VIDEO CONTROLS (Skip, Play/Pause)
                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _controlIcon(
                            Icons.replay_10,
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(
                                pos - const Duration(seconds: 10),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _controlIcon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            onTap: _togglePlay,
                          ),
                          const SizedBox(width: 12),
                          _controlIcon(
                            Icons.forward_10,
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(
                                pos + const Duration(seconds: 10),
                              );
                            },
                          ),
                          _controlIcon(
                            Icons.fullscreen,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FullScreenPlayer(controller: _controller),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    /// 🔙 BACK
                    Positioned(
                      top: 40,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    /// ☀️ BRIGHTNESS
                    if (_showOverlay && !_isVolume)
                      Positioned(
                        left: 20,
                        top: screenHeight * 0.0,
                        child: _sideIndicator(
                          Icons.brightness_6,
                          _currentBrightness,
                          Colors.amber,
                          screenHeight,
                        ),
                      ),

                    /// 🔊 VOLUME
                    if (_showOverlay && _isVolume)
                      Positioned(
                        right: 20,
                        top: screenHeight * 0.0,
                        child: _sideIndicator(
                          Icons.volume_up,
                          _currentVolume,
                          Colors.blue,
                          screenHeight,
                        ),
                      ),
                  ],
                ),
              ),

              /// 📄 CONTENT
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: (widget.movie.genres ?? "Action, Crime")
                          .split(',')
                          .map(
                            (g) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                g.trim(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.movie.fullTitle ?? widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              color: Colors.red,
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "(${widget.movie.rating ?? "4.0"})",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${widget.movie.runtimeStr ?? "2hr"} • ${widget.movie.year ?? ""}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {},
                            child: const Text("Subscribe ▶"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.movie.plot ?? "No description available",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _bigCircle(Icons.favorite, Colors.red),
                        _bigCircle(Icons.bookmark, Colors.pink),
                        _bigCircle(Icons.add, Colors.white),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "❤️ 4 Likes",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 FIXED SIDE INDICATOR (Responsive)
  Widget _sideIndicator(
    IconData icon,
    double value,
    Color color,
    double screenHeight,
  ) {
    double barHeight = screenHeight * 0.25;

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ FIX
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Container(
            width: 4,
            height: barHeight,
            color: Colors.white24,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: barHeight * value,
                width: 4,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(value * 100).toInt()}%",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

Widget _sideIndicator(IconData icon, double value, Color color) {
  return Container(
    width: 60,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 16),
        Container(
          width: 4,
          height: 120,
          color: Colors.white24,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: 120 * value, width: 4, color: color),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${(value * 100).toInt()}%",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}

Widget _controlIcon(IconData icon, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

Widget _bigCircle(IconData icon, Color color) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white54),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Icon(icon, color: color, size: 28),
    ),
  );
}
