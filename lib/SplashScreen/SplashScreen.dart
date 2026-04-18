import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/OtpScreen.dart/providers/auth_provider.dart';
import 'package:iptvmobile/routes/routes_names.dart';

class Splashscreen extends ConsumerStatefulWidget {
  const Splashscreen({super.key});

  @override
  ConsumerState<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends ConsumerState<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    // First, check authentication status from storage
    await ref.read(authStateProvider.notifier).checkAuthStatus();
    
    // Wait for splash duration (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authState = ref.read(authStateProvider);
    
    print("SplashScreen - Is Authenticated: ${authState.isAuthenticated}");
    print("SplashScreen - User: ${authState.user?.mobile}");
    
    if (authState.isAuthenticated) {
      // User is logged in, go to dashboard
      print("Navigating to Dashboard...");
      Navigator.pushReplacementNamed(
        context,
        RouteNames.dashBoardScreenn,
      );
    } else {
      // User not logged in, go to get started screen
      print("Navigating to GetStartScreen...");
      Navigator.pushReplacementNamed(
        context,
        RouteNames.getStartScreen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black, Colors.black]),
        ),
        child: const Center(
          child: Image(
            image: AssetImage('assets/images/logo.png'),
            width: 250,
          ),
        ),
      ),
    );
  }
}