import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:iptvmobile/HomeScreen/movie_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Movie movie;

  const VideoPlayerScreen({super.key, required this.movie});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;

  // Brightness & Volume
  double _brightness = 1.0;
  double _volume = 1.0;

  double _startY = 0;
  double _currentBrightness = 1.0;
  double _currentVolume = 1.0;

  bool _showOverlay = false;
  bool _isVolume = false;

  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.movie.videoUrl))
          ..initialize().then((_) {
            _videoController.play();
            setState(() {});
          });
  }

  @override
  void dispose() {
    _videoController.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
  }

  void _toggleControlsVisibility() {
    setState(() => _showControls = !_showControls);
  }

  // 🎯 Gesture
  void _handleVerticalDragStart(DragStartDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragX = details.globalPosition.dx;

    _startY = details.globalPosition.dy;

    if (dragX > screenWidth / 2) {
      // 👉 RIGHT SIDE → VOLUME
      _isVolume = true;
      _currentVolume = _volume;
    } else {
      // 👉 LEFT SIDE → BRIGHTNESS
      _isVolume = false;
      _currentBrightness = _brightness;
    }

    setState(() => _showOverlay = true);
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final deltaY = details.globalPosition.dy - _startY;
    final change = -deltaY / 500;

    if (_isVolume) {
      _volume = (_currentVolume + change).clamp(0.0, 1.0);
      _videoController.setVolume(_volume);
    } else {
      _brightness = (_currentBrightness + change).clamp(0.2, 1.0);
    }

    setState(() {});
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    setState(() => _showOverlay = false);
  }

  // 🔥 Side Indicator
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
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildSeekBar() {
    final value = _videoController.value;

    /// SAFE CHECK
    if (!value.isInitialized || value.duration == Duration.zero) {
      return const SizedBox();
    }

    final position = value.position;
    final duration = value.duration;

    return Slider(
      min: 0,
      max: duration.inSeconds.toDouble(),
      value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
      activeColor: Colors.red,
      inactiveColor: Colors.white38,
      onChanged: (val) {
        _videoController.seekTo(Duration(seconds: val.toInt()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🎬 VIDEO
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: _handleVerticalDragStart,
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            onVerticalDragEnd: _handleVerticalDragEnd,
            onTap: _toggleControlsVisibility,
            child: Center(
              child: _videoController.value.isInitialized
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(1 - _brightness),
                        BlendMode.darken,
                      ),
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          if (_showControls)
            Positioned(
              bottom: 10,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // 👉 তোমার logo path
                    width: 80,
                    height: 80,
                  ),
                  // const SizedBox(height: 4),
                  // const Text(
                  //   'Left: Brightness\nRight: Volume',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: 10,
                  //     height: 1.2,
                  //   ),
                  // ),
                ],
              ),
            ),

          /// ☀️ BRIGHTNESS
          if (_showOverlay && !_isVolume)
            Positioned(
              left: 20,
              top: screenHeight * 0.2,
              child: _sideIndicator(
                Icons.brightness_6,
                _brightness,
                Colors.amber,
                screenHeight,
              ),
            ),

          /// 🔊 VOLUME
          if (_showOverlay && _isVolume)
            Positioned(
              right: 20,
              top: screenHeight * 0.2,
              child: _sideIndicator(
                Icons.volume_up,
                _volume,
                Colors.blue,
                screenHeight,
              ),
            ),

          /// 🔙 BACK
          if (_showControls)
            Positioned(
              top: 30,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  _videoController.pause();
                  Navigator.pop(context);
                },
              ),
            ),

          /// ▶ PLAY BUTTON
          if (_showControls && !_videoController.value.isPlaying)
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: const EdgeInsets.all(15),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          /// 🎮 CONTROLS
          if (_showControls)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlIcon(Icons.replay_10, () {
                    final pos = _videoController.value.position;
                    _videoController.seekTo(pos - const Duration(seconds: 10));
                  }),
                  const SizedBox(width: 20),
                  _controlIcon(
                    _videoController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    _togglePlay,
                    size: 45,
                  ),
                  const SizedBox(width: 20),
                  _controlIcon(Icons.forward_10, () {
                    final pos = _videoController.value.position;
                    _videoController.seekTo(pos + const Duration(seconds: 10));
                  }),
                ],
              ),
            ),

          if (_showControls)
            Positioned(
              bottom: 5, // 👈 controls এর উপরে
              left: 0,
              right: 0,
              child: _buildSeekBar(),
            ),
        ],
      ),
    );
  }

  Widget _controlIcon(IconData icon, VoidCallback onTap, {double size = 35}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
