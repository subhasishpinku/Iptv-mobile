import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key});

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  List<Map<String, String>> users = [
    {"name": "Puja Halder", "img": "https://i.pravatar.cc/150?img=1", "time": "", "online": "false"},
    {"name": "juliahiri_official", "img": "https://i.pravatar.cc/150?img=2", "time": "40m", "online": "false"},
    {"name": "Rina Chakraborty", "img": "https://i.pravatar.cc/150?img=3", "time": "", "online": "true"},
    {"name": "Anwesa", "img": "https://i.pravatar.cc/150?img=4", "time": "", "online": "false"},
    {"name": "Sanjukta", "img": "https://i.pravatar.cc/150?img=5", "time": "", "online": "true"},
    {"name": "Rahul", "img": "https://i.pravatar.cc/150?img=6", "time": "9m", "online": "false"},
  ];

  String search = "";
  final String shareContent = "Check out this amazing content!";

  // WhatsApp share function
  Future<void> shareToWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
      "whatsapp://send?text=${Uri.encodeComponent(shareContent)}",
    );
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      // Show dialog if WhatsApp is not installed
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('WhatsApp Not Found'),
              content: const Text('Please install WhatsApp to share content.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Default share using share_plus
  void shareDefault() {
    Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = users
        .where((u) =>
            u["name"]!.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            /// Handle bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            /// Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Share with",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),

            /// Search + Add
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() => search = val);
                        },
                        decoration: InputDecoration(
                          hintText: "Search contacts...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                          suffixIcon: search.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[500]),
                                  onPressed: () => setState(() => search = ""),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.black87),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                    ),
                  ),
                ],
              ),
            ),

            /// Recent chats title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Recent chats",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            /// Users Grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            "No contacts found",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final user = filtered[index];

                        return InkWell(
                          onTap: () {
                            // Here you can implement share to specific user
                            shareDefault();
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(user["img"]!),
                                    ),
                                  ),
                                  // Online indicator
                                  if (user["online"] == "true")
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  // Time badge
                                  if (user["time"]!.isNotEmpty)
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          user["time"]!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user["name"]!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            /// Share Actions Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          "Share via",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _action(Icons.message, "WhatsApp", const Color(0xFF25D366), onTap: shareToWhatsApp),
                        _action(Icons.add_circle_outline, "Add to story", Colors.grey[600]!, onTap: shareDefault),
                        _action(Icons.refresh, "Status", Colors.blue[700]!, onTap: shareDefault),
                        _action(Icons.share, "Share", Colors.blue[400]!, onTap: shareDefault),
                        _action(Icons.link, "Copy link", Colors.grey[700]!, onTap: shareDefault),
                        _action(Icons.alternate_email, "Threads", Colors.black, onTap: shareDefault),
                        _action(Icons.sms, "SMS", Colors.green[600]!, onTap: shareDefault),
                        _action(Icons.facebook, "Facebook", Colors.blue[800]!, onTap: shareDefault),
                        _action(Icons.photo_camera, "Instagram", const Color(0xFFE4405F), onTap: shareDefault),
                        _action(Icons.email, "Email", Colors.red[400]!, onTap: shareDefault),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(IconData icon, String text, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 68,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}