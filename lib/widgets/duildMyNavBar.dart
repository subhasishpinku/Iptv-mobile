import 'package:flutter/material.dart';

class BuildMyNavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onPageSelected;

  const BuildMyNavBar({
    super.key,
    required this.pageIndex,
    required this.onPageSelected,
  });

  final List<Map<String, dynamic>> navItems = const [
    {
      "active": Icons.home_filled,
      "inactive": Icons.home_outlined,
      "label": "Home",
    },
    {
      "active": Icons.live_tv,
      "inactive": Icons.live_tv_outlined,
      "label": "Live",
    },

    // 👇 NEW (Reels)
    {
      "active": Icons.play_circle_fill,
      "inactive": Icons.play_circle_outline,
      "label": "Reels",
    },

    {
      "active": Icons.music_note,
      "inactive": Icons.music_note_outlined,
      "label": "Music",
    },
    {
      "active": Icons.movie,
      "inactive": Icons.movie_outlined,
      "label": "Movies",
    },
    {
      "active": Icons.category,
      "inactive": Icons.category_outlined,
      "label": "Category",
    },
  ];

Widget buildNavItem(int i) {
  bool isSelected = pageIndex == i;

  return GestureDetector(
    onTap: () => onPageSelected(i),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // 👈 ADD THIS
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSelected ? navItems[i]["active"] : navItems[i]["inactive"],
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          navItems[i]["label"],
          textAlign: TextAlign.center, // 👈 ADD THIS
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.6),
            fontSize: 11, // 👈 slightly smaller for 6 items
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

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
          children: [for (int i = 0; i < navItems.length; i++) buildNavItem(i)],
        ),
      ),
    );
  }
}
