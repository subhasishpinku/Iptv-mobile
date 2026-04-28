import 'package:flutter/material.dart';

class ReelNavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onPageSelected;

  const ReelNavBar({
    super.key,
    required this.pageIndex,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10),
           decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            /// 🏠 HOME
            IconButton(
              onPressed: () => onPageSelected(0),
              icon: Icon(
                pageIndex == 0
                    ? Icons.home
                    : Icons.home_outlined,
                size: 28,
                color: Colors.white,
              ),
            ),

            /// 🎬 REELS
            IconButton(
              onPressed: () => onPageSelected(1),
              icon: Icon(
                pageIndex == 1
                    ? Icons.smart_display
                    : Icons.smart_display_outlined,
                size: 28,
                color: Colors.white,
              ),
            ),

            /// ✈️ SEND
            IconButton(
              onPressed: () => onPageSelected(2),
              icon: Icon(
                pageIndex == 2
                    ? Icons.send
                    : Icons.send_outlined,
                size: 26,
                color: Colors.white,
              ),
            ),

            /// 🔍 SEARCH
            IconButton(
              onPressed: () => onPageSelected(3),
              icon: Icon(
                pageIndex == 3
                    ? Icons.search
                    : Icons.search_outlined,
                size: 28,
                color: Colors.white,
              ),
            ),

            /// 👤 PROFILE + RED DOT
            GestureDetector(
              onTap: () => onPageSelected(4),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: pageIndex == 4
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: const CircleAvatar(
                      radius: 13,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=5",
                      ),
                    ),
                  ),

                  /// 🔴 notification dot
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}