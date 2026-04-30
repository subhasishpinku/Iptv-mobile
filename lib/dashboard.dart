import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/CategoriesScreen/CategoriesScreen.dart';
import 'package:iptvmobile/HomeScreen/HomeScreen.dart';
import 'package:iptvmobile/LiveTvScreen/LiveTvScreen.dart';
import 'package:iptvmobile/MovieScreen/MovieScreen.dart';
import 'package:iptvmobile/MusicScreen/MusicScreen.dart';
import 'package:iptvmobile/OtpScreen.dart/providers/auth_provider.dart';
import 'package:iptvmobile/ScannerScreen/mobile_scanner.dart';
import 'package:iptvmobile/routes/routes_names.dart';
import 'package:iptvmobile/widgets/CustomDrawer.dart';
import 'package:iptvmobile/widgets/duildMyNavBar.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int pageIndex = 0;

  final List<Widget> pages = const [
    Homescreen(),
    LiveTvScreen(),
    MusicScreen(),
    MovieScreen(),
    Categoriesscreen(),
  ];

  void _onPageSelected(int index) {
    if (index == 2) {
      // 🎬 Reels → Full screen open (NO navbar)
      Navigator.pushNamed(context, RouteNames.reelScreen);
      return;
    }

    // 👉 Fix index (because reels not in pages)
    final newIndex = index > 2 ? index - 1 : index;

    if (newIndex != pageIndex) {
      setState(() {
        pageIndex = newIndex;
      });
    }
  }

  /// 👉 Navbar highlight fix (Reels should never stay selected)
  int get selectedIndex {
    if (pageIndex >= 2) return pageIndex + 1;
    return pageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
          ),
        ],
      ),

      body: pages[pageIndex],

      bottomNavigationBar: BuildMyNavBar(
        pageIndex: selectedIndex, // 👈 IMPORTANT FIX
        onPageSelected: _onPageSelected,
      ),

      drawer: CustomDrawer(
        userName: user?.name ?? "User",
        userMobile: user?.mobile ?? "",
      ),
    );
  }
}