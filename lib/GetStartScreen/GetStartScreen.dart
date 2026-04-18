import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/OtpScreen.dart/providers/auth_provider.dart';
import 'package:iptvmobile/routes/routes_names.dart';

class Getstartscreen extends ConsumerStatefulWidget {
  const Getstartscreen({super.key});

  @override
  ConsumerState<Getstartscreen> createState() => _GetstartscreenState();
}

class _GetstartscreenState extends ConsumerState<Getstartscreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  Timer? _timer;

  final List<String> images = [
    'assets/images/start01.png',
    'assets/images/start02.png',
    'assets/images/start03.png',
    'assets/images/start04.png',
  ];

  final List<String> titles = [
    "Unlimited entertainment,\none low price.",
    "All of IPTV, starting at just",
    "Unlimited entertainment,\none low price.",
    "All of IPTV, starting at just",
  ];

  final List<String> prices = ["₹200", "₹500", "₹500", "₹500"];

  @override
  void initState() {
    super.initState();

    // Auto slider
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentIndex < images.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }

      _controller.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          /// Image Slider
          Expanded(
            flex: 5,
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),

          /// Dot Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                margin: const EdgeInsets.all(4),
                width: currentIndex == index ? 12 : 8,
                height: currentIndex == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          /// Text Section
          Text(
            titles[currentIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "All of IPTV, starting at just",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 5),

          Text(
            prices[currentIndex],
            style: const TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          /// Get Start Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  // Check if already logged in before navigating to login
                  if (authState.isAuthenticated) {
                    Navigator.pushReplacementNamed(
                      context, 
                      RouteNames.dashBoardScreenn,
                    );
                  } else {
                    Navigator.pushNamed(
                      context, 
                      RouteNames.loginScreen,
                    );
                  }
                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}