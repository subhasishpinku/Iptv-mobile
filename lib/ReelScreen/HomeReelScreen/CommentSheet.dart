import 'package:flutter/material.dart';
import 'package:iptvmobile/ReelScreen/CommentItem.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> comments = [
    {
      "name": "vikram.singh660",
      "comment": "❤️",
      "time": "1w",
      "isLiked": false,
      "replies": [],
    },
    {
      "name": "rupabiswas4245",
      "comment": "❤️❤️❤️❤️",
      "time": "1w",
      "isLiked": false,
      "replies": [],
    },
  ];
  bool showEmoji = false;
  int? replyingIndex;

  /// 📡 Fake API call
  Future<void> sendCommentToAPI(String text) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print("Sent to API: $text");
  }

  /// 💬 Add comment locally + API
  void _sendComment() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    if (replyingIndex != null) {
      setState(() {
        comments[replyingIndex!]["replies"].add({
          "name": "you",
          "comment": text,
          "time": "now",
          "isLiked": false,
        });
        replyingIndex = null;
      });
    } else {
      setState(() {
        comments.insert(0, {
          "name": "you",
          "comment": text,
          "time": "now",
          "isLiked": false,
          "replies": [],
        });
      });
    }

    _controller.clear();
    await sendCommentToAPI(text);
  }

  /// 😀 Add emoji
  void _addEmoji(String emoji) {
    _controller.text += emoji;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),

            /// Top handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),

            const Divider(),

            /// 💬 Comment List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final c = comments[index];

                  return CommentItem(
                    comment: c,

                    /// 💬 Reply click
                    onReply: () {
                      setState(() {
                        replyingIndex = index;
                      });
                    },

                    /// ❤️ Like toggle
                    onLike: () {
                      setState(() {
                        c["isLiked"] = !c["isLiked"];
                      });
                    },
                  );
                },
              ),
            ),

            /// 😀 Emoji Panel
            if (showEmoji)
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ["😀", "😂", "😍", "🔥", "❤️", "👍", "🥺", "😎"]
                      .map((e) {
                        return GestureDetector(
                          onTap: () => _addEmoji(e),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),

            /// ✍️ Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=1",
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// Input field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.black),
                      onSubmitted: (_) => _sendComment(), // 🎯 Enter send
                      decoration: InputDecoration(
                        hintText: "What do you think of this?",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  /// 😀 Emoji toggle
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    onPressed: () {
                      setState(() {
                        showEmoji = !showEmoji;
                      });
                    },
                  ),

                  /// 📤 Send button
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
