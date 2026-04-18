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

  // Brightness
  double _brightness = 1.0;
  bool _showBrightnessControl = false;
  double _startY = 0;
  double _startBrightness = 1.0;
  bool _isDraggingRightSide = false;

  // Volume
  double _volume = 1.0;
  bool _showVolumeControl = false;
  double _startVolume = 1.0;
  bool _isDraggingLeftSide = false;

  // UI visibility
  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    // Landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Full screen
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
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  // 🎯 Gesture START
  void _handleVerticalDragStart(DragStartDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragX = details.globalPosition.dx;

    _startY = details.globalPosition.dy;

    if (dragX > screenWidth / 2) {
      // RIGHT → Brightness
      _isDraggingRightSide = true;
      _isDraggingLeftSide = false;

      _startBrightness = _brightness;

      setState(() => _showBrightnessControl = true);
    } else {
      // LEFT → Volume
      _isDraggingLeftSide = true;
      _isDraggingRightSide = false;

      _startVolume = _volume;

      setState(() => _showVolumeControl = true);
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final deltaY = details.globalPosition.dy - _startY;

    if (_isDraggingRightSide) {
      final change = -deltaY / 500;
      _brightness = (_startBrightness + change).clamp(0.2, 1.0);
      setState(() {});
    }

    if (_isDraggingLeftSide) {
      final change = -deltaY / 500;
      _volume = (_startVolume + change).clamp(0.0, 1.0);

      _videoController.setVolume(_volume);
      setState(() {});
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _showBrightnessControl = false;
      _showVolumeControl = false;
    });

    _isDraggingRightSide = false;
    _isDraggingLeftSide = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🎬 VIDEO + GESTURE
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

          // 👉 LEFT indicator
          if (_isDraggingLeftSide)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 5,
                color: Colors.white.withOpacity(0.3),
              ),
            ),

          // 👉 RIGHT indicator
          if (_isDraggingRightSide)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 5,
                color: Colors.white.withOpacity(0.3),
              ),
            ),

          // 🔊 VOLUME UI
          if (_showVolumeControl && _isDraggingLeftSide)
            Positioned(
              left: 20,
              top: MediaQuery.of(context).size.height / 2 - 100,
              child: _volumeUI(),
            ),

          // 🔆 BRIGHTNESS UI
          if (_showBrightnessControl && _isDraggingRightSide)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).size.height / 2 - 100,
              child: _brightnessUI(),
            ),

          // 🔙 Back
          if (_showControls)
            Positioned(
              top: 30,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 30),
                onPressed: () {
                  _videoController.pause();
                  Navigator.pop(context);
                },
              ),
            ),

          // ▶ PLAY BUTTON (Center)
          if (_showControls && !_videoController.value.isPlaying)
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: AnimatedOpacity(
                    opacity: _videoController.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
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
              ),
            ),

          // 🎮 VIDEO CONTROLS (Skip, Play/Pause)
          if (_showControls)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlIcon(
                    Icons.replay_10,
                    onTap: () {
                      final pos = _videoController.value.position;
                      _videoController.seekTo(pos - const Duration(seconds: 10));
                    },
                  ),
                  const SizedBox(width: 20),
                  _controlIcon(
                    _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    onTap: _togglePlay,
                    size: 45,
                  ),
                  const SizedBox(width: 20),
                  _controlIcon(
                    Icons.forward_10,
                    onTap: () {
                      final pos = _videoController.value.position;
                      _videoController.seekTo(pos + const Duration(seconds: 10));
                    },
                  ),
                ],
              ),
            ),

          // 📌 Instruction + Logo
          if (_showControls)
            Positioned(
              bottom: 10,
              right: 20,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 70,
                    height: 70,
                  ),
                  const Text(
                    'Left: Volume\nRight: Brightness',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _controlIcon(IconData icon, {required VoidCallback onTap, double size = 35}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }

  // 🔊 Volume UI
  Widget _volumeUI() {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Icon(Icons.volume_up, color: Colors.white),
          const SizedBox(height: 10),
          Text('${(_volume * 100).toInt()}%',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: RotatedBox(
              quarterTurns: 1,
              child: LinearProgressIndicator(value: _volume),
            ),
          ),
        ],
      ),
    );
  }

  // 🔆 Brightness UI
  Widget _brightnessUI() {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Icon(Icons.brightness_6, color: Colors.white),
          const SizedBox(height: 10),
          Text('${(_brightness * 100).toInt()}%',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: RotatedBox(
              quarterTurns: 1,
              child: LinearProgressIndicator(value: _brightness),
            ),
          ),
        ],
      ),
    );
  }
}