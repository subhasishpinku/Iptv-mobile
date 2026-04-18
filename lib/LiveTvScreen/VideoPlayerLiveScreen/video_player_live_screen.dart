import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoPlayerLiveScreen extends StatefulWidget {
  final String url;
  final String title;

  const VideoPlayerLiveScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<VideoPlayerLiveScreen> createState() => _VideoPlayerLiveScreenState();
}

class _VideoPlayerLiveScreenState extends State<VideoPlayerLiveScreen> {
  late VideoPlayerController _controller;

  bool _showControls = true;

  bool _showOverlay = false;
  bool _isVolume = false;

  Timer? _hideTimer;
  Timer? _overlayTimer;

  double _currentBrightness = 0.5;
  double _currentVolume = 0.5;

  @override
  void initState() {
    super.initState();

    _initPlayer();
    _initSystem();

    _startHideTimer();
  }

  Future<void> _initSystem() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    VolumeController.instance.showSystemUI = false;

    _currentBrightness = await ScreenBrightness().current;
    _currentVolume = await VolumeController.instance.getVolume();
  }

  Future<void> _initPlayer() async {
  _controller = VideoPlayerController.network(widget.url);

  await _controller.initialize();

  _controller
    ..setLooping(false)
    ..play();

  /// 🔥 AUTO RESUME FIX
  _controller.addListener(() {
    final value = _controller.value;

    // যদি pause হয়ে যায় কিন্তু buffering না করে
    if (!value.isPlaying &&
        !value.isBuffering &&
        value.position > Duration.zero) {

      // একটু delay দিয়ে আবার play
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_controller.value.isPlaying) {
          _controller.play();
        }
      });
    }
  });

  setState(() {});
}
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  /// 🔥 BRIGHTNESS + VOLUME
  void _handleVerticalDrag(DragUpdateDetails details) async {
    double delta = details.primaryDelta ?? 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final touchX = details.globalPosition.dx;

    setState(() => _showOverlay = true);

    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showOverlay = false);
    });

    if (touchX < screenWidth / 2) {
      _isVolume = false;

      _currentBrightness -= delta / 300;
      _currentBrightness = _currentBrightness.clamp(0.0, 1.0);

      await ScreenBrightness().setScreenBrightness(_currentBrightness);
    } else {
      _isVolume = true;

      _currentVolume -= delta / 300;
      _currentVolume = _currentVolume.clamp(0.0, 1.0);

      await VolumeController.instance.setVolume(_currentVolume);
    }

    setState(() {});
  }

  void _onDoubleTap(bool isLeft) async {
    final pos = _controller.value.position;

    final seekTo = isLeft
        ? pos - const Duration(seconds: 10)
        : pos + const Duration(seconds: 10);

    await _controller.seekTo(seekTo);
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

  Widget _sideIndicator(
    IconData icon,
    double value,
    Color color,
    double height,
  ) {
    double barHeight = height * 0.25;

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
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

  @override
  void dispose() {
    _hideTimer?.cancel();
    _overlayTimer?.cancel();
    _controller.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? GestureDetector(
              onTap: _toggleControls,
              onVerticalDragUpdate: _handleVerticalDrag,
              child: Stack(
                children: [
                  /// VIDEO
                  SizedBox.expand(
                    child: FittedBox(
                      fit:
                          BoxFit.cover, // 🔥 Full screen crop (MX Player style)
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),

                  /// DOUBLE TAP LEFT
                  Positioned.fill(
                    right: MediaQuery.of(context).size.width / 2,
                    child: GestureDetector(
                      onDoubleTap: () => _onDoubleTap(true),
                    ),
                  ),

                  /// DOUBLE TAP RIGHT
                  Positioned.fill(
                    left: MediaQuery.of(context).size.width / 2,
                    child: GestureDetector(
                      onDoubleTap: () => _onDoubleTap(false),
                    ),
                  ),

                  /// BUFFER
                  if (_controller.value.isBuffering)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),

                  /// OVERLAY
                  if (_showOverlay && !_isVolume)
                    Positioned(
                      left: 20,
                      top: h * 0.2,
                      child: _sideIndicator(
                        Icons.brightness_6,
                        _currentBrightness,
                        Colors.amber,
                        h,
                      ),
                    ),

                  if (_showOverlay && _isVolume)
                    Positioned(
                      right: 20,
                      top: h * 0.2,
                      child: _sideIndicator(
                        Icons.volume_up,
                        _currentVolume,
                        Colors.blue,
                        h,
                      ),
                    ),

                  /// CONTROLS
                  if (_showControls) ...[
                    /// BACK
                    Positioned(
                      top: 20,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    /// CENTER PLAY
                    Center(
                      child: IconButton(
                        iconSize: 70,
                        color: Colors.white,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        onPressed: _togglePlay,
                      ),
                    ),

                    /// BOTTOM CONTROLS
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
                          const SizedBox(width: 16),
                          _controlIcon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            onTap: _togglePlay,
                          ),
                          const SizedBox(width: 16),
                          _controlIcon(
                            Icons.forward_10,
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(
                                pos + const Duration(seconds: 10),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }
}
