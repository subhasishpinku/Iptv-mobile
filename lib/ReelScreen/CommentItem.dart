import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback onReply;
  final VoidCallback onLike;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
          ),
          title: Row(
            children: [
              Text(
                comment["name"],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(width: 6),
              Text(
                comment["time"],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment["comment"]),

              Row(
                children: [
                  GestureDetector(
                    onTap: onReply,
                    child: const Text(
                      "Reply",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// ❤️ Like Button
          trailing: GestureDetector(
            onTap: onLike,
            child: Icon(
              comment["isLiked"]
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: comment["isLiked"] ? Colors.red : Colors.grey,
              size: 18,
            ),
          ),
        ),

        /// 🔁 Replies UI
        if (comment["replies"].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Column(
              children: List.generate(
                comment["replies"].length,
                (index) {
                  final reply = comment["replies"][index];
                  return ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          NetworkImage("https://i.pravatar.cc/150"),
                    ),
                    title: Text(
                      reply["name"],
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      reply["comment"],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}