import 'package:flutter/material.dart';
import 'package:iptvmobile/ReelScreen/HomeReelScreen/CommentSheet.dart';
import 'package:iptvmobile/ReelScreen/HomeReelScreen/ShareSheet.dart';
import 'package:iptvmobile/ReelScreen/HomeReelScreen/VideoDetailsScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoController;

  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool isMuted = true;

  // ❤️ Like system
  bool isLiked = false;
  bool showHeart = false;
  int likeCount = 0; // For dynamic like count

  @override
  bool get wantKeepAlive => widget.post["type"] == "video";

  @override
  void initState() {
    super.initState();
    likeCount = widget.post["likes"]; // Initialize like count from post data

    if (widget.post["type"] == "video") {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.post["media"]),
      );

      _videoController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });

          _videoController.setLooping(true);
          _videoController.setVolume(0.0);
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.post["type"] == "video") {
      _videoController.dispose();
    }
    super.dispose();
  }

  // 🎯 Visibility control
  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_isVideoInitialized || !mounted) return;

    double visible = info.visibleFraction * 100;

    if (visible > 60) {
      if (!_videoController.value.isPlaying) {
        _videoController.play();
        setState(() => _isPlaying = true);
      }
    } else {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        setState(() => _isPlaying = false);
      }
    }
  }

  // ❤️ Toggle like - works for both single tap on icon AND double tap on media
  void _toggleLike() {
    setState(() {
      if (isLiked) {
        // Unlike: decrease count and set isLiked to false
        isLiked = false;
        likeCount--;
      } else {
        // Like: increase count and set isLiked to true
        isLiked = true;
        likeCount++;
        
        // Show heart animation only when liking (not when unliking)
        showHeart = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => showHeart = false);
          }
        });
      }
    });
  }

  // ❤️ Double tap handler (only shows heart animation, uses same toggle logic)
  void _handleDoubleTap() {
    if (!isLiked) {
      // Only show heart animation if actually liking
      setState(() {
        showHeart = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => showHeart = false);
        }
      });
    }
    _toggleLike(); // Toggle the like state
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post["profile"]),
            ),
            title: Text(
              widget.post["username"],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.more_vert, color: Colors.white),
          ),

          /// 🎬 Media Section
          widget.post["type"] == "video"
              ? VisibilityDetector(
                  key: Key(widget.post["media"]),
                  onVisibilityChanged: _onVisibilityChanged,
                  child: GestureDetector(
                    onTap: () {
                      // 👉 Single tap → Details Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoDetailsScreen(
                            videoUrl: widget.post["media"],
                            username: widget.post["username"],
                            caption: widget.post["caption"],
                            profile: widget.post["profile"],
                          ),
                        ),
                      );
                    },
                    onDoubleTap: _handleDoubleTap, // 🔥 Double tap to like/unlike
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// 🎥 Video
                        Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.black,
                          child: _isVideoInitialized
                              ? VideoPlayer(_videoController)
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                        ),

                        /// ❤️ Heart Animation
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: showHeart ? 1 : 0,
                          child: IgnorePointer(
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 100,
                            ),
                          ),
                        ),

                        /// 🎬 Badge (Video)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "VIDEO",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// 🔊 Volume Button
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isMuted = !isMuted;
                                _videoController.setVolume(isMuted ? 0.0 : 1.0);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isMuted ? Icons.volume_off : Icons.volume_up,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              /// 🖼️ Image
              : GestureDetector(
                  onDoubleTap: _handleDoubleTap, // 🔥 Double tap to like/unlike
                  onTap: () {
                    // Optional: Add image details screen if needed
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        widget.post["media"],
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

                      /// ❤️ Heart Animation (same as video)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: showHeart ? 1 : 0,
                        child: IgnorePointer(
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

          /// ❤️ Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 🔥 Like Button with Icon (Single tap to toggle like/unlike)
                GestureDetector(
                  onTap: _toggleLike, // 🔥 Single tap on icon toggles like/unlike
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _openComments(context);
                  },
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _openShareSheet(context);
                  },
                  child: const Icon(Icons.send, color: Colors.white, size: 26),
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border, color: Colors.white, size: 26),
              ],
            ),
          ),

          /// 👍 Likes Count (Dynamic)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              likeCount == 0 ? "Be the first to like this" : "$likeCount likes",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// 📝 Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "${widget.post["username"]} ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: widget.post["caption"],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          /// ⏱ Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post["time"],
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const CommentSheet();
      },
    );
  }

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const ShareSheet();
      },
    );
  }
}
// class PostItem extends StatefulWidget {
//   final Map<String, dynamic> post;
//   const PostItem({super.key, required this.post});

//   @override
//   State<PostItem> createState() => _PostItemState();
// }

// class _PostItemState extends State<PostItem> {
//   late VideoPlayerController _videoController;
//   bool _isVideoInitialized = false;
//   bool _isPlaying = false;
//   bool isMuted = true;
//   @override
//   void initState() {
//     super.initState();

//     if (widget.post["type"] == "video") {
//       _videoController = VideoPlayerController.networkUrl(
//         Uri.parse(widget.post["media"]),
//       );

//       _videoController.initialize().then((_) {
//         setState(() {
//           _isVideoInitialized = true;
//         });

//         _videoController.setLooping(true);

//         // ✅ AUTO PLAY
//         _videoController.play();
//         _isPlaying = true;

//         // ✅ START WITH MUTE
//         _videoController.setVolume(0.0);
//       });
//     }
//   }
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   if (widget.post["type"] == "video") {
//   //     _videoController = VideoPlayerController.networkUrl(
//   //       Uri.parse(widget.post["media"]),
//   //     );
//   //     _videoController.initialize().then((_) {
//   //       setState(() {
//   //         _isVideoInitialized = true;
//   //       });
//   //     });
//   //     _videoController.setLooping(true);
//   //   }
//   // }

//   @override
//   void dispose() {
//     if (widget.post["type"] == "video") {
//       _videoController.dispose();
//     }
//     super.dispose();
//   }

//   void _togglePlayPause() {
//     if (_isVideoInitialized) {
//       setState(() {
//         if (_videoController.value.isPlaying) {
//           _videoController.pause();
//           _isPlaying = false;
//         } else {
//           _videoController.play();
//           _isPlaying = true;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(widget.post["profile"]),
//             ),
//             title: Text(
//               widget.post["username"],
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             trailing: const Icon(Icons.more_vert, color: Colors.white),
//           ),

//           // Media Player (Video or Image)
//           GestureDetector(
//             // onTap: widget.post["type"] == "video" ? _togglePlayPause : null,
//             // onTap: () {
//             //   if (widget.post["type"] == "video") {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //         builder: (_) => VideoDetailsScreen(
//             //           videoUrl: widget.post["media"],
//             //           username: widget.post["username"],
//             //           caption: widget.post["caption"],
//             //           profile: widget.post["profile"],
//             //         ),
//             //       ),
//             //     );
//             //   } else {
//             //     _togglePlayPause();
//             //   }
//             // },
//             onTap: () {
//               if (widget.post["type"] == "video") {
//                 // ✅ SOUND ON
//                 _videoController.setVolume(1.0);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => VideoDetailsScreen(
//                       videoUrl: widget.post["media"],
//                       username: widget.post["username"],
//                       caption: widget.post["caption"],
//                       profile: widget.post["profile"],
//                     ),
//                   ),
//                 );
//               }
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 if (widget.post["type"] == "video")
//                   Container(
//                     height: 300,
//                     width: double.infinity,
//                     color: Colors.black,
//                     child: _isVideoInitialized
//                         ? VideoPlayer(_videoController)
//                         : const Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           ),
//                   )
//                 else
//                   Image.network(
//                     widget.post["media"],
//                     height: 300,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         height: 300,
//                         color: Colors.grey,
//                         child: const Center(
//                           child: Icon(Icons.broken_image, color: Colors.white),
//                         ),
//                       );
//                     },
//                   ),

//                 // Play/Pause Button for Video
//                 if (widget.post["type"] == "video" && _isVideoInitialized)
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.5),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       _isPlaying ? Icons.pause : Icons.play_arrow,
//                       color: Colors.white,
//                       size: 50,
//                     ),
//                   ),

//                 // Video Indicator Badge
//                 if (widget.post["type"] == "video")
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.7),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.videocam, color: Colors.white, size: 14),
//                           SizedBox(width: 4),
//                           Text(
//                             "VIDEO",
//                             style: TextStyle(color: Colors.white, fontSize: 10),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 Positioned(
//                   bottom: 10,
//                   right: 10,
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isMuted = !isMuted;
//                         _videoController.setVolume(isMuted ? 0.0 : 1.0);
//                       });
//                     },
//                     child: Icon(
//                       isMuted ? Icons.volume_off : Icons.volume_up,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 Icon(Icons.favorite_border, color: Colors.white),
//                 SizedBox(width: 12),
//                 Icon(Icons.chat_bubble_outline, color: Colors.white),
//                 SizedBox(width: 12),
//                 Icon(Icons.send, color: Colors.white),
//                 Spacer(),
//                 Icon(Icons.bookmark_border, color: Colors.white),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               "${widget.post["likes"]} likes",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           const SizedBox(height: 4),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text.rich(
//               TextSpan(
//                 children: [
//                   TextSpan(
//                     text: "${widget.post["username"]} ",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   TextSpan(
//                     text: widget.post["caption"],
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 4),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               widget.post["time"],
//               style: const TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//           ),

//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }
