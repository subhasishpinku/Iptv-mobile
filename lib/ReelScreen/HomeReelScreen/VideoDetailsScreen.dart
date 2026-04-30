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
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
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
                    child: Icon(
                      Icons.play_arrow,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),

                /// 🔝 Top Bar
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  // child: Row(
                  //   children: const [
                  //     Icon(Icons.arrow_back, color: Colors.white),
                  //     SizedBox(width: 20),
                  //     Text(
                  //       "Reels",
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     SizedBox(width: 10),
                  //     Text("Friends", style: TextStyle(color: Colors.grey)),
                  //   ],
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// 🔙 Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Reels",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Text(
                                "Friends",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Positioned(
                                left: 0,
                                child: CircleAvatar(
                                  radius: 10, // 👈 smaller size
                                  backgroundImage: NetworkImage(
                                    "https://i.pravatar.cc/150?img=1",
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 15,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundImage: NetworkImage(
                                    "https://i.pravatar.cc/150?img=2",
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 30,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundImage: NetworkImage(
                                    "https://i.pravatar.cc/150?img=3",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// ❤️ Right Side Actions
                Positioned(
                  right: 12,
                  bottom: 120,
                  child: Column(
                    children: [
                      Column(
                        children: const [
                          Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(height: 4),
                          Text("48", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Column(
                        children: const [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text("4", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Icon(Icons.send, color: Colors.white, size: 28),
                      const SizedBox(height: 20),

                      const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 20),

                      const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 60,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        widget.profile,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                /// 👤 Bottom Info
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.black.withOpacity(0.6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(widget.profile),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Add comment...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.favorite_border, color: Colors.white),
                        const SizedBox(width: 10),
                        const Icon(Icons.send, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}



// Positioned(
//   top: 40,
//   left: 12,
//   right: 12,
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       /// 🔙 Back Button
//       GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child: const Icon(
//           Icons.arrow_back,
//           color: Colors.white,
//         ),
//       ),

//       /// 🎬 Center Text (Reels | Friends + avatars)
//       Row(
//         children: [
//           const Text(
//             "Reels",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(width: 16),

//           Row(
//             children: [
//               const Text(
//                 "Friends",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(width: 6),

//               /// 👥 ছোট avatar stack
//               SizedBox(
//                 width: 60,
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       left: 0,
//                       child: CircleAvatar(
//                         radius: 10,
//                         backgroundImage: NetworkImage(
//                           "https://i.pravatar.cc/150?img=1",
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       left: 15,
//                       child: CircleAvatar(
//                         radius: 10,
//                         backgroundImage: NetworkImage(
//                           "https://i.pravatar.cc/150?img=2",
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       left: 30,
//                       child: CircleAvatar(
//                         radius: 10,
//                         backgroundImage: NetworkImage(
//                           "https://i.pravatar.cc/150?img=3",
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),

//       /// Right side empty (balance maintain)
//       const SizedBox(width: 24),
//     ],
//   ),
// ),