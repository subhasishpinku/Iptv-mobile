import 'package:flutter/material.dart';

class BuildMyNavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onPageSelected;

  const BuildMyNavBar({
    super.key,
    required this.pageIndex,
    required this.onPageSelected,
  });

  final List<Map<String, IconData>> navItems = const [
    {
      "active": Icons.home_filled,
      "inactive": Icons.home_outlined,
    },
     {
      "active": Icons.live_tv,
      "inactive": Icons.live_tv_outlined,
    },
      {
    "active": Icons.music_note,
    "inactive": Icons.music_note_outlined,
  },
    {
      "active": Icons.movie,
      "inactive": Icons.movie_outlined,
    },
   
    {
      "active": Icons.category,
      "inactive": Icons.category_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 65,
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
    // Left (2 items)
    for (int i = 0; i < 2; i++)
      IconButton(
        onPressed: () => onPageSelected(i),
        icon: Icon(
          pageIndex == i
              ? navItems[i]["active"]
              : navItems[i]["inactive"],
          color: pageIndex == i
              ? Colors.white
              : Colors.white.withOpacity(0.6),
          size: 30,
        ),
      ),

    const SizedBox(width: 60), // 👈 FAB gap

    // Right (3 items)
    for (int i = 2; i < 5; i++) // ✅ FIXED
      IconButton(
        onPressed: () => onPageSelected(i),
        icon: Icon(
          pageIndex == i
              ? navItems[i]["active"]
              : navItems[i]["inactive"],
          color: pageIndex == i
              ? Colors.white
              : Colors.white.withOpacity(0.6),
          size: 30,
        ),
      ),
  ],
),
      ),
    );
  }
}