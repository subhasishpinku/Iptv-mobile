import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class FullScreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenPlayer({super.key, required this.controller});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  bool _showControls = true;
  Timer? _timer;

  double _currentBrightness = 0.5;
  double _currentVolume = 0.5;

  bool _showOverlay = false;
  bool _isVolume = true;

  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();

    // 🔥 FULLSCREEN LANDSCAPE
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initControls();
    _startHideTimer();
  }

  Future<void> _initControls() async {
    _currentBrightness = await ScreenBrightness().current;
    _currentVolume = await VolumeController.instance.getVolume();

    VolumeController.instance.showSystemUI = false;

    setState(() {});
  }

  void _startHideTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  /// 🔥 VOLUME + BRIGHTNESS GESTURE
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
      // ☀️ BRIGHTNESS
      _isVolume = false;

      _currentBrightness -= delta / 300;
      _currentBrightness = _currentBrightness.clamp(0.0, 1.0);

      await ScreenBrightness().setScreenBrightness(_currentBrightness);
    } else {
      // 🔊 VOLUME
      _isVolume = true;

      _currentVolume -= delta / 300;
      _currentVolume = _currentVolume.clamp(0.0, 1.0);

      await VolumeController.instance.setVolume(_currentVolume);
    }

    setState(() {});
  }

  Widget _buildSeekBar() {
    final value = widget.controller.value;

    /// ✅ SAFE CHECK
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
        widget.controller.seekTo(Duration(seconds: val.toInt()));
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _overlayTimer?.cancel();

    // 🔙 BACK TO PORTRAIT
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 134, 134),
      body: GestureDetector(
        onTap: _toggleControls,
        onVerticalDragUpdate: _handleVerticalDrag,
        child: Stack(
          children: [
            /// 🎬 FULLSCREEN VIDEO
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: widget.controller.value.size.width,
                  height: widget.controller.value.size.height,
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),

            /// 🎮 CONTROLS
            if (_showControls)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        widget.controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 60,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.controller.value.isPlaying
                              ? widget.controller.pause()
                              : widget.controller.play();
                        });
                      },
                    ),
                  ),
                ),
              ),
            if (!_showControls)
              Positioned(
                bottom: 15,
                right: 15,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset('assets/images/logo.png', width: 80, height: 80),
                ),
              ),

            /// 🎮 VIDEO CONTROLS (Skip, Play/Pause)
            /// /// 🎮 VIDEO CONTROLS + SEEKBAR
            if (_showControls)
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🔻 SEEK BAR
                    _buildSeekBar(),

                    const SizedBox(height: 10),

                    /// 🔘 CONTROLS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _controlIcon(
                          Icons.replay_10,
                          onTap: () {
                            final pos = widget.controller.value.position;
                            widget.controller.seekTo(
                              pos - const Duration(seconds: 10),
                            );
                          },
                        ),
                        const SizedBox(width: 20),

                        _controlIcon(
                          widget.controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          onTap: () {
                            setState(() {
                              widget.controller.value.isPlaying
                                  ? widget.controller.pause()
                                  : widget.controller.play();
                            });
                          },
                        ),

                        const SizedBox(width: 20),

                        _controlIcon(
                          Icons.forward_10,
                          onTap: () {
                            final pos = widget.controller.value.position;
                            widget.controller.seekTo(
                              pos + const Duration(seconds: 10),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // if (_showControls)
            //   Positioned(
            //     bottom: 30,
            //     left: 0,
            //     right: 0,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         _controlIcon(
            //           Icons.replay_10,
            //           onTap: () {
            //             final pos = widget.controller.value.position;
            //             widget.controller.seekTo(
            //               pos - const Duration(seconds: 10),
            //             );
            //           },
            //         ),
            //         const SizedBox(width: 20),

            //         _controlIcon(
            //           widget.controller.value.isPlaying
            //               ? Icons.pause
            //               : Icons.play_arrow,
            //           onTap: () {
            //             setState(() {
            //               widget.controller.value.isPlaying
            //                   ? widget.controller.pause()
            //                   : widget.controller.play();
            //             });
            //           },
            //         ),

            //         const SizedBox(width: 20),

            //         _controlIcon(
            //           Icons.forward_10,
            //           onTap: () {
            //             final pos = widget.controller.value.position;
            //             widget.controller.seekTo(
            //               pos + const Duration(seconds: 10),
            //             );
            //           },
            //         ),
            //       ],
            //     ),
            //   ),

            /// 🔙 BACK BUTTON
            if (_showControls)
              Positioned(
                top: 20,
                left: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        255,
                        252,
                        252,
                      ).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ),

            /// ☀️ BRIGHTNESS
            if (_showOverlay && !_isVolume)
              Positioned(
                left: 20,
                top: screenHeight * 0.2,
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
                top: screenHeight * 0.2,
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
    );
  }

  /// 🎚 SIDE INDICATOR UI
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
}

Widget _controlIcon(IconData icon, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(icon, color: Colors.white, size: 26),
    ),
  );
}
