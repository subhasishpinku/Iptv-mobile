// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
// import 'package:screen_brightness/screen_brightness.dart';
// import 'package:volume_controller/volume_controller.dart';

// class VideoPlayerLiveScreen extends StatefulWidget {
//   final String url;
//   final String title;

//   const VideoPlayerLiveScreen({
//     super.key,
//     required this.url,
//     required this.title,
//   });

//   @override
//   State<VideoPlayerLiveScreen> createState() => _VideoPlayerLiveScreenState();
// }

// class _VideoPlayerLiveScreenState extends State<VideoPlayerLiveScreen> {
//   late VideoPlayerController _controller;

//   bool _showControls = true;

//   bool _showOverlay = false;
//   bool _isVolume = false;

//   Timer? _hideTimer;
//   Timer? _overlayTimer;

//   double _currentBrightness = 0.5;
//   double _currentVolume = 0.5;

//   @override
//   void initState() {
//     super.initState();

//     _initPlayer();
//     _initSystem();

//     _startHideTimer();
//   }

//   Future<void> _initSystem() async {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);

//     VolumeController.instance.showSystemUI = false;

//     _currentBrightness = await ScreenBrightness().current;
//     _currentVolume = await VolumeController.instance.getVolume();
//   }

//   Future<void> _initPlayer() async {
//   _controller = VideoPlayerController.network(widget.url);

//   await _controller.initialize();

//   _controller
//     ..setLooping(false)
//     ..play();

//   /// 🔥 AUTO RESUME FIX
//   _controller.addListener(() {
//     final value = _controller.value;

//     // যদি pause হয়ে যায় কিন্তু buffering না করে
//     if (!value.isPlaying &&
//         !value.isBuffering &&
//         value.position > Duration.zero) {

//       // একটু delay দিয়ে আবার play
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted && !_controller.value.isPlaying) {
//           _controller.play();
//         }
//       });
//     }
//   });

//   setState(() {});
// }
//   void _startHideTimer() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(seconds: 4), () {
//       if (mounted) setState(() => _showControls = false);
//     });
//   }

//   void _toggleControls() {
//     setState(() => _showControls = !_showControls);
//     if (_showControls) _startHideTimer();
//   }

//   void _togglePlay() {
//     setState(() {
//       _controller.value.isPlaying ? _controller.pause() : _controller.play();
//     });
//   }

//   /// 🔥 BRIGHTNESS + VOLUME
//   void _handleVerticalDrag(DragUpdateDetails details) async {
//     double delta = details.primaryDelta ?? 0;

//     final screenWidth = MediaQuery.of(context).size.width;
//     final touchX = details.globalPosition.dx;

//     setState(() => _showOverlay = true);

//     _overlayTimer?.cancel();
//     _overlayTimer = Timer(const Duration(seconds: 1), () {
//       if (mounted) setState(() => _showOverlay = false);
//     });

//     if (touchX < screenWidth / 2) {
//       _isVolume = false;

//       _currentBrightness -= delta / 300;
//       _currentBrightness = _currentBrightness.clamp(0.0, 1.0);

//       await ScreenBrightness().setScreenBrightness(_currentBrightness);
//     } else {
//       _isVolume = true;

//       _currentVolume -= delta / 300;
//       _currentVolume = _currentVolume.clamp(0.0, 1.0);

//       await VolumeController.instance.setVolume(_currentVolume);
//     }

//     setState(() {});
//   }

//   void _onDoubleTap(bool isLeft) async {
//     final pos = _controller.value.position;

//     final seekTo = isLeft
//         ? pos - const Duration(seconds: 10)
//         : pos + const Duration(seconds: 10);

//     await _controller.seekTo(seekTo);
//   }

//   Widget _controlIcon(IconData icon, {VoidCallback? onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white.withOpacity(0.2),
//         ),
//         padding: const EdgeInsets.all(10),
//         child: Icon(icon, color: Colors.white, size: 20),
//       ),
//     );
//   }

//   Widget _sideIndicator(
//     IconData icon,
//     double value,
//     Color color,
//     double height,
//   ) {
//     double barHeight = height * 0.25;

//     return Container(
//       width: 60,
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(height: 10),
//           Container(
//             width: 4,
//             height: barHeight,
//             color: Colors.white24,
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: barHeight * value,
//                 width: 4,
//                 color: color,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "${(value * 100).toInt()}%",
//             style: const TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     _overlayTimer?.cancel();
//     _controller.dispose();

//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: _controller.value.isInitialized
//           ? GestureDetector(
//               onTap: _toggleControls,
//               onVerticalDragUpdate: _handleVerticalDrag,
//               child: Stack(
//                 children: [
//                   /// VIDEO
//                   SizedBox.expand(
//                     child: FittedBox(
//                       fit:
//                           BoxFit.cover, // 🔥 Full screen crop (MX Player style)
//                       child: SizedBox(
//                         width: _controller.value.size.width,
//                         height: _controller.value.size.height,
//                         child: VideoPlayer(_controller),
//                       ),
//                     ),
//                   ),

//                   /// DOUBLE TAP LEFT
//                   Positioned.fill(
//                     right: MediaQuery.of(context).size.width / 2,
//                     child: GestureDetector(
//                       onDoubleTap: () => _onDoubleTap(true),
//                     ),
//                   ),

//                   /// DOUBLE TAP RIGHT
//                   Positioned.fill(
//                     left: MediaQuery.of(context).size.width / 2,
//                     child: GestureDetector(
//                       onDoubleTap: () => _onDoubleTap(false),
//                     ),
//                   ),

//                   /// BUFFER
//                   if (_controller.value.isBuffering)
//                     const Center(
//                       child: CircularProgressIndicator(color: Colors.red),
//                     ),

//                   /// OVERLAY
//                   if (_showOverlay && !_isVolume)
//                     Positioned(
//                       left: 20,
//                       top: h * 0.2,
//                       child: _sideIndicator(
//                         Icons.brightness_6,
//                         _currentBrightness,
//                         Colors.amber,
//                         h,
//                       ),
//                     ),

//                   if (_showOverlay && _isVolume)
//                     Positioned(
//                       right: 20,
//                       top: h * 0.2,
//                       child: _sideIndicator(
//                         Icons.volume_up,
//                         _currentVolume,
//                         Colors.blue,
//                         h,
//                       ),
//                     ),

//                   /// CONTROLS
//                   if (_showControls) ...[
//                     /// BACK
//                     Positioned(
//                       top: 20,
//                       left: 10,
//                       child: IconButton(
//                         icon: const Icon(Icons.arrow_back, color: Colors.white),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),

//                     /// CENTER PLAY
//                     Center(
//                       child: IconButton(
//                         iconSize: 70,
//                         color: Colors.white,
//                         icon: Icon(
//                           _controller.value.isPlaying
//                               ? Icons.pause_circle
//                               : Icons.play_circle,
//                         ),
//                         onPressed: _togglePlay,
//                       ),
//                     ),

//                     /// BOTTOM CONTROLS
//                     Positioned(
//                       bottom: 15,
//                       left: 0,
//                       right: 0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           _controlIcon(
//                             Icons.replay_10,
//                             onTap: () {
//                               final pos = _controller.value.position;
//                               _controller.seekTo(
//                                 pos - const Duration(seconds: 10),
//                               );
//                             },
//                           ),
//                           const SizedBox(width: 16),
//                           _controlIcon(
//                             _controller.value.isPlaying
//                                 ? Icons.pause
//                                 : Icons.play_arrow,
//                             onTap: _togglePlay,
//                           ),
//                           const SizedBox(width: 16),
//                           _controlIcon(
//                             Icons.forward_10,
//                             onTap: () {
//                               final pos = _controller.value.position;
//                               _controller.seekTo(
//                                 pos + const Duration(seconds: 10),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             )
//           : const Center(child: CircularProgressIndicator(color: Colors.red)),
//     );
//   }
// }
import 'dart:async';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoPlayerLiveScreen extends StatefulWidget {
  final List channels;
  final int currentIndex;

  const VideoPlayerLiveScreen({
    super.key,
    required this.channels,
    required this.currentIndex,
  });

  @override
  State<VideoPlayerLiveScreen> createState() => _VideoPlayerLiveScreenState();
}

class _VideoPlayerLiveScreenState extends State<VideoPlayerLiveScreen> {
  // late VideoPlayerController _controller;
  late BetterPlayerController _betterController;

  late int _currentIndex;

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

    _currentIndex = widget.currentIndex;

    _initPlayer();
    _initSystem();
    _startHideTimer();
  }

  /// ================= SYSTEM =================
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

  /// ================= PLAYER =================
  Future<void> _initPlayer() async {
    final channel = widget.channels[_currentIndex];

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      channel.streamUrl,
      liveStream: true,
    );

    _betterController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        // liveStream: true,
        useRootNavigator: true,
        allowedScreenSleep: false,
        handleLifecycle: true,
        autoDetectFullscreenDeviceOrientation: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false, // we use custom controls
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    /// 🔥 AUTO RETRY
    _betterController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        Future.delayed(const Duration(seconds: 2), () {
          _betterController.retryDataSource();
        });
      }
    });

    setState(() {});
  }

  // Future<void> _initPlayer1() async {
  //   final channel = widget.channels[_currentIndex];

  //   _controller = VideoPlayerController.network(channel.streamUrl);

  //   await _controller.initialize();

  //   _controller
  //     ..setLooping(false)
  //     ..play();

  //   /// AUTO RESUME
  //   _controller.addListener(() {
  //     final value = _controller.value;

  //     if (!value.isPlaying &&
  //         !value.isBuffering &&
  //         value.position > Duration.zero) {
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         if (mounted && !_controller.value.isPlaying) {
  //           _controller.play();
  //         }
  //       });
  //     }
  //   });

  //   setState(() {});
  // }

  /// ================= CHANGE CHANNEL =================
  ///   Future<void> _changeChannel(int newIndex) async {
  Future<void> _changeChannel(int newIndex) async {
    if (newIndex < 0 || newIndex >= widget.channels.length) return;

    _currentIndex = newIndex;

    final channel = widget.channels[_currentIndex];

    await _betterController.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        channel.streamUrl,
        liveStream: true,
      ),
    );

    setState(() {});
  }

  // Future<void> _changeChannel1(int newIndex) async {
  //   if (newIndex < 0 || newIndex >= widget.channels.length) return;

  //   _currentIndex = newIndex;

  //   await _controller.dispose();

  //   final newChannel = widget.channels[_currentIndex];

  //   _controller = VideoPlayerController.network(newChannel.streamUrl);

  //   await _controller.initialize();
  //   _controller.play();

  //   setState(() {});
  // }

  /// ================= CONTROLS =================
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
    final isPlaying = _betterController.isPlaying() ?? false;

    if (isPlaying) {
      _betterController.pause();
    } else {
      _betterController.play();
    }

    setState(() {});
  }

  // void _togglePlay1() {
  //   setState(() {
  //     _controller.value.isPlaying ? _controller.pause() : _controller.play();
  //   });
  // }

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

  /// ================= BRIGHTNESS + VOLUME =================
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

  /// ================= SEEK =================
  void _onDoubleTap(bool isLeft) async {
    final pos =
        _betterController.videoPlayerController?.value.position ??
        Duration.zero;

    final seekTo = isLeft
        ? pos - const Duration(seconds: 10)
        : pos + const Duration(seconds: 10);

    _betterController.seekTo(seekTo);
  }

  // void _onDoubleTap1(bool isLeft) async {
  //   final pos = _controller.value.position;

  //   final seekTo = isLeft
  //       ? pos - const Duration(seconds: 10)
  //       : pos + const Duration(seconds: 10);

  //   await _controller.seekTo(seekTo);
  // }

  /// ================= INDICATOR =================
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

  Widget _buildSeekBar() {
    final controller = _betterController.videoPlayerController;

    if (controller == null) {
      return const SizedBox();
    }

    final value = controller.value;

    /// ✅ SAFE CHECK (no isInitialized)
    if (value.duration == null ||
        value.duration == Duration.zero ||
        value.position == null) {
      return const SizedBox();
    }

    final position = value.position;
    final duration = value.duration;

    return Slider(
      min: 0,
      max: duration!.inSeconds.toDouble(),
      value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
      activeColor: Colors.red,
      inactiveColor: Colors.white38,
      onChanged: (value) {
        _betterController.seekTo(Duration(seconds: value.toInt()));
      },
    );
  }

  /// ================= DISPOSE =================
  @override
  void dispose() {
    _hideTimer?.cancel();
    _overlayTimer?.cancel();
    _betterController.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }
  // @override
  // void dispose() {
  //   _hideTimer?.cancel();
  //   _overlayTimer?.cancel();
  //   _controller.dispose();

  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //   super.dispose();
  // }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final videoController = _betterController.videoPlayerController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: videoController != null && videoController.value.size != null
          ? GestureDetector(
              onTap: _toggleControls,
              onVerticalDragUpdate: _handleVerticalDrag,
              child: Stack(
                children: [
                  /// VIDEO
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width:
                            videoController.value.size?.width ??
                            MediaQuery.of(context).size.width,
                        height:
                            videoController.value.size?.height ??
                            MediaQuery.of(context).size.height,
                        child: BetterPlayer(controller: _betterController),
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

                  // /// PREV
                  // Positioned(
                  //   left: 80,
                  //   top: 0,
                  //   bottom: 0,
                  //   child: Center(
                  //     child: GestureDetector(
                  //       onTap: _currentIndex > 0
                  //           ? () => _changeChannel(_currentIndex - 1)
                  //           : null,
                  //       child: Icon(
                  //         Icons.arrow_back_ios,
                  //         color: _currentIndex > 0 ? Colors.white : Colors.grey,
                  //         size: 35,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // /// NEXT
                  // Positioned(
                  //   right: 80,
                  //   top: 0,
                  //   bottom: 0,
                  //   child: Center(
                  //     child: GestureDetector(
                  //       onTap: _currentIndex < widget.channels.length - 1
                  //           ? () => _changeChannel(_currentIndex + 1)
                  //           : null,
                  //       child: Icon(
                  //         Icons.arrow_forward_ios,
                  //         color: _currentIndex < widget.channels.length - 1
                  //             ? Colors.white
                  //             : Colors.grey,
                  //         size: 35,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  if (_showControls) ...[
                    /// PREV
                    Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _currentIndex > 0
                              ? () => _changeChannel(_currentIndex - 1)
                              : null,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: _currentIndex > 0
                                ? Colors.white
                                : Colors.grey,
                            size: 35,
                          ),
                        ),
                      ),
                    ),

                    /// NEXT
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _currentIndex < widget.channels.length - 1
                              ? () => _changeChannel(_currentIndex + 1)
                              : null,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: _currentIndex < widget.channels.length - 1
                                ? Colors.white
                                : Colors.grey,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ],

                  /// BUFFER
                  if (_betterController.isBuffering() ?? false)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),

                  /// BRIGHTNESS
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
                            final pos = videoController.value.position;
                            _betterController.seekTo(
                              pos - const Duration(seconds: 10),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _controlIcon(
                          (_betterController.isPlaying() ?? false)
                              ? Icons.pause
                              : Icons.play_arrow,
                          onTap: _togglePlay,
                        ),
                        const SizedBox(width: 16),
                        _controlIcon(
                          Icons.forward_10,
                          onTap: () {
                            final pos = videoController.value.position;
                            _betterController.seekTo(
                              pos + const Duration(seconds: 10),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Positioned(
                  //   bottom: 5,
                  //   left: 0,
                  //   right: 0,
                  //   child: _buildSeekBar(),
                  // ),

                  /// VOLUME
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
                    Center(
                      child: IconButton(
                        iconSize: 70,
                        color: Colors.white,
                        icon: Icon(
                          (_betterController.isPlaying() ?? false)
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        onPressed: _togglePlay,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   final h = MediaQuery.of(context).size.height;

  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     // body: _controller.value.isInitialized
  //     // body: _betterController.isVideoInitialized()
  //     body: _betterController.videoPlayerController != null
  //         ? GestureDetector(
  //             onTap: _toggleControls,
  //             onVerticalDragUpdate: _handleVerticalDrag,
  //             child: Stack(
  //               children: [
  //                 /// VIDEO
  //                      SizedBox.expand(
  //                   child: FittedBox(
  //                     fit: BoxFit.cover,
  //                     child: SizedBox(
  //                       width: _betterController.videoPlayerController?.value.size!.width,
  //                       height: _betterController.videoPlayerController?.value.size!.height,
  //                       child: BetterPlayer(controller: _betterController),
  //                     ),
  //                   ),
  //                 ),
  //                 // SizedBox.expand(
  //                 //   child: FittedBox(
  //                 //     fit: BoxFit.cover,
  //                 //     child: SizedBox(
  //                 //       width: _controller.value.size.width,
  //                 //       height: _controller.value.size.height,
  //                 //       // child: VideoPlayer(_controller),
  //                 //       child: BetterPlayer(controller: _betterController),
  //                 //     ),
  //                 //   ),
  //                 // ),

  //                 /// DOUBLE TAP LEFT
  //                 Positioned.fill(
  //                   right: MediaQuery.of(context).size.width / 2,
  //                   child: GestureDetector(
  //                     onDoubleTap: () => _onDoubleTap(true),
  //                   ),
  //                 ),

  //                 /// DOUBLE TAP RIGHT
  //                 Positioned.fill(
  //                   left: MediaQuery.of(context).size.width / 2,
  //                   child: GestureDetector(
  //                     onDoubleTap: () => _onDoubleTap(false),
  //                   ),
  //                 ),

  //                 /// 🔥 PREV
  //                 Positioned(
  //                   left: 10,
  //                   top: 0,
  //                   bottom: 0,
  //                   child: Center(
  //                     child: GestureDetector(
  //                       onTap: _currentIndex > 0
  //                           ? () => _changeChannel(_currentIndex - 1)
  //                           : null,
  //                       child: Icon(
  //                         Icons.arrow_back_ios,
  //                         color: _currentIndex > 0 ? Colors.white : Colors.grey,
  //                         size: 35,
  //                       ),
  //                     ),
  //                   ),
  //                 ),

  //                 /// 🔥 NEXT
  //                 Positioned(
  //                   right: 10,
  //                   top: 0,
  //                   bottom: 0,
  //                   child: Center(
  //                     child: GestureDetector(
  //                       onTap: _currentIndex < widget.channels.length - 1
  //                           ? () => _changeChannel(_currentIndex + 1)
  //                           : null,
  //                       child: Icon(
  //                         Icons.arrow_forward_ios,
  //                         color: _currentIndex < widget.channels.length - 1
  //                             ? Colors.white
  //                             : Colors.grey,
  //                         size: 35,
  //                       ),
  //                     ),
  //                   ),
  //                 ),

  //                 /// BUFFER
  //                 // if (_controller.value.isBuffering)
  //                 //   const Center(
  //                 //     child: CircularProgressIndicator(color: Colors.red),
  //                 //   ),
  //                 if (_betterController.isBuffering() ?? false)
  //                   const Center(
  //                     child: CircularProgressIndicator(color: Colors.red),
  //                   ),

  //                 /// 🔥 BRIGHTNESS
  //                 if (_showOverlay && !_isVolume)
  //                   Positioned(
  //                     left: 20,
  //                     top: h * 0.2,
  //                     child: _sideIndicator(
  //                       Icons.brightness_6,
  //                       _currentBrightness,
  //                       Colors.amber,
  //                       h,
  //                     ),
  //                   ),

  //                 /// BOTTOM CONTROLS
  //                          Positioned(
  //                   bottom: 15,
  //                   left: 0,
  //                   right: 0,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       _controlIcon(
  //                         Icons.replay_10,
  //                         onTap: () {
  //                           final pos = _betterController.videoPlayerController?.value.position ?? Duration.zero;
  //                           _betterController.seekTo(
  //                             pos - const Duration(seconds: 10),
  //                           );
  //                         },
  //                       ),
  //                       const SizedBox(width: 16),
  //                       _controlIcon(
  //                         (_betterController.isPlaying() ?? false)
  //                             ? Icons.pause
  //                             : Icons.play_arrow,
  //                         onTap: _togglePlay,
  //                       ),
  //                       const SizedBox(width: 16),
  //                       _controlIcon(
  //                         Icons.forward_10,
  //                         onTap: () {
  //                           final pos = _betterController.videoPlayerController?.value.position ?? Duration.zero;
  //                           _betterController.seekTo(
  //                             pos + const Duration(seconds: 10),
  //                           );
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 // Positioned(
  //                 //   bottom: 15,
  //                 //   left: 0,
  //                 //   right: 0,
  //                 //   child: Row(
  //                 //     mainAxisAlignment: MainAxisAlignment.center,
  //                 //     children: [
  //                 //       _controlIcon(
  //                 //         Icons.replay_10,
  //                 //         onTap: () {
  //                 //           final pos = _controller.value.position;
  //                 //           _controller.seekTo(
  //                 //             pos - const Duration(seconds: 10),
  //                 //           );
  //                 //         },
  //                 //       ),
  //                 //       const SizedBox(width: 16),
  //                 //       _controlIcon(
  //                 //         _controller.value.isPlaying
  //                 //             ? Icons.pause
  //                 //             : Icons.play_arrow,
  //                 //         onTap: _togglePlay,
  //                 //       ),
  //                 //       const SizedBox(width: 16),
  //                 //       _controlIcon(
  //                 //         Icons.forward_10,
  //                 //         onTap: () {
  //                 //           final pos = _controller.value.position;
  //                 //           _controller.seekTo(
  //                 //             pos + const Duration(seconds: 10),
  //                 //           );
  //                 //         },
  //                 //       ),
  //                 //     ],
  //                 //   ),
  //                 // ),

  //                 /// 🔥 VOLUME
  //                 if (_showOverlay && _isVolume)
  //                   Positioned(
  //                     right: 20,
  //                     top: h * 0.2,
  //                     child: _sideIndicator(
  //                       Icons.volume_up,
  //                       _currentVolume,
  //                       Colors.blue,
  //                       h,
  //                     ),
  //                   ),

  //                 /// CONTROLS
  //                 if (_showControls) ...[
  //                   Positioned(
  //                     top: 20,
  //                     left: 10,
  //                     child: GestureDetector(
  //                       onTap: () => Navigator.pop(context),
  //                       child: Container(
  //                         padding: const EdgeInsets.all(10),
  //                         decoration: BoxDecoration(
  //                           color: const Color.fromARGB(
  //                             255,
  //                             255,
  //                             252,
  //                             252,
  //                           ).withOpacity(0.5),
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: const Icon(
  //                           Icons.arrow_back,
  //                           color: Colors.black,
  //                           size: 30, // 👈 clean size
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   Center(
  //                     child: IconButton(
  //                       iconSize: 70,
  //                       color: Colors.white,
  //                       icon: Icon(
  //                         (_betterController.isPlaying() ?? false)
  //                             ? Icons.pause_circle
  //                             : Icons.play_circle,
  //                       ),
  //                       onPressed: _togglePlay,
  //                     ),
  //                   ),
  //                   // Center(
  //                   //   child: IconButton(
  //                   //     iconSize: 70,
  //                   //     color: Colors.white,
  //                   //     icon: Icon(
  //                   //       _controller.value.isPlaying
  //                   //           ? Icons.pause_circle
  //                   //           : Icons.play_circle,
  //                   //     ),
  //                   //     onPressed: _togglePlay,
  //                   //   ),
  //                   // ),
  //                 ],
  //               ],
  //             ),
  //           )
  //         : const Center(child: CircularProgressIndicator(color: Colors.red)),
  //   );
  // }
}
