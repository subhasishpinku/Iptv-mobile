import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/CategoriesScreen/CategoriesScreen.dart';
import 'package:iptvmobile/HomeScreen/HomeScreen.dart';
import 'package:iptvmobile/LiveTvScreen/LiveTvScreen.dart';
import 'package:iptvmobile/MovieScreen/MovieScreen.dart';
import 'package:iptvmobile/OtpScreen.dart/providers/auth_provider.dart';
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
    const MovieScreen(),
    const LiveTvScreen(),
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
        title: const Text("IPTV"),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)),
        ),
        elevation: 0.00,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: pages[pageIndex],
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