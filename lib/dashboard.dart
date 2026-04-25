import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/CategoriesScreen/CategoriesScreen.dart';
import 'package:iptvmobile/HomeScreen/HomeScreen.dart';
import 'package:iptvmobile/LiveTvScreen/LiveTvScreen.dart';
import 'package:iptvmobile/MovieScreen/MovieScreen.dart';
import 'package:iptvmobile/MusicScreen/MusicScreen.dart';
import 'package:iptvmobile/OtpScreen.dart/providers/auth_provider.dart';
import 'package:iptvmobile/ScannerScreen/mobile_scanner.dart';
import 'package:iptvmobile/widgets/CustomDrawer.dart';
import 'package:iptvmobile/widgets/duildMyNavBar.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});
  
  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int pageIndex = 0;
  final List<Widget> pages = [
    const Homescreen(),
    const LiveTvScreen(),
    const MusicScreen(),
    const MovieScreen(),
    const Categoriesscreen(),
  ];

  void _onPageSelected(int index) {
    setState(() {
      pageIndex = index;
    });
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
          MaterialPageRoute(
            builder: (_) => const ScannerScreen(),
          ),
        );
      },
    ),
  ],
),

  body: pages[pageIndex],

  floatingActionButton: FloatingActionButton(
    onPressed: () {
      print("Plus Clicked");
    },
    backgroundColor: Colors.red,
    child: const Icon(Icons.add),
  ),

  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

  bottomNavigationBar: BuildMyNavBar(
    pageIndex: pageIndex,
    onPageSelected: _onPageSelected,
  ),

  drawer: CustomDrawer(
    userName: user?.name ?? "User",
    userMobile: user?.mobile ?? "",
  ),
);
  }
}