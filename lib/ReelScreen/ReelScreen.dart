import 'package:flutter/material.dart';
import 'package:iptvmobile/ReelScreen/HomeReelScreen/HomeReelScreen.dart';
import 'package:iptvmobile/ReelScreen/ReelNavBar.dart';
import 'package:iptvmobile/ReelScreen/ReelProfileScreen/ReelProfileScreen.dart';
import 'package:iptvmobile/ReelScreen/ReelSearchScreen/ReelSearchScreen.dart';
import 'package:iptvmobile/ReelScreen/ReelVideoScreen/ReelVideoScreen.dart';
import 'package:iptvmobile/ReelScreen/ShareScreen/ReelShareScreen.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({super.key});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late final List<Widget> pages;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    pages = const [
      HomeReelScreen(),       // 🏠 Home
      ReelVideoScreen(),      // 🎬 Reels
      ReelShareScreen(),          // ✈️ Send
      ReelSharchScreen(),     // 🔍 Search
      ReelProfileScreen(),    // 👤 Profile
    ];
  }

  void _onPageSelected(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      /// 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const Icon(Icons.add, color: Colors.white),
        title: const Text(
          "Reels",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),

      /// 🔥 PAGE SWITCH (ONLY THIS)
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),

      /// 🔻 NAVBAR
      bottomNavigationBar: ReelNavBar(
        pageIndex: pageIndex,
        onPageSelected: _onPageSelected,
      ),
    );
  }
}