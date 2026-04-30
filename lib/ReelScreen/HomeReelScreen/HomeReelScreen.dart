import 'package:flutter/material.dart';
import 'package:iptvmobile/ReelScreen/HomeReelScreen/VideoDetailsScreen.dart';
import 'package:iptvmobile/ReelScreen/HomeReelScreen/post_item.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeReelScreen extends StatefulWidget {
  const HomeReelScreen({super.key});

  @override
  State<HomeReelScreen> createState() => _HomeReelScreenState();
}

class _HomeReelScreenState extends State<HomeReelScreen> {
  int currentPlayingIndex = -1;

  final List<Map<String, String>> stories = [
    {"name": "Your story", "image": "https://i.pravatar.cc/150?img=1"},
    {"name": "pia.in.a.pod", "image": "https://i.pravatar.cc/150?img=2"},
    {"name": "cake_baker_ci", "image": "https://i.pravatar.cc/150?img=3"},
    {"name": "kiya_kayak", "image": "https://i.pravatar.cc/150?img=4"},
    {"name": "Your story", "image": "https://i.pravatar.cc/150?img=1"},
    {"name": "pia.in.a.pod", "image": "https://i.pravatar.cc/150?img=2"},
    {"name": "cake_baker_ci", "image": "https://i.pravatar.cc/150?img=3"},
    {"name": "kiya_kayak", "image": "https://i.pravatar.cc/150?img=4"},
  ];

  final List<Map<String, dynamic>> posts = [
    {
      "username": "juliahiri_official",
      "profile": "https://i.pravatar.cc/150?img=5",
      "media":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "type": "video",
      "likes": 17,
      "caption": "❤️❤️",
      "time": "4 hours ago",
    },
    {
      "username": "fitness_guru",
      "profile": "https://i.pravatar.cc/150?img=6",
      "media": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438",
      "type": "image",
      "likes": 120,
      "caption": "Workout done 💪",
      "time": "2 hours ago",
    },
    {
      "username": "travel_diary",
      "profile": "https://i.pravatar.cc/150?img=7",
      "media": "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
      "type": "image",
      "likes": 342,
      "caption": "Nature is healing 🌿",
      "time": "1 hour ago",
    },
    {
      "username": "foodie_world",
      "profile": "https://i.pravatar.cc/150?img=8",
      "media":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "type": "video",
      "likes": 89,
      "caption": "Delicious 😋",
      "time": "30 min ago",
    },
    {
      "username": "tech_master",
      "profile": "https://i.pravatar.cc/150?img=9",
      "media": "https://images.unsplash.com/photo-1518779578993-ec3579fee39f",
      "type": "image",
      "likes": 210,
      "caption": "Coding night 💻",
      "time": "5 hours ago",
    },
    {
      "username": "gym_lifestyle",
      "profile": "https://i.pravatar.cc/150?img=10",
      "media":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "type": "video",
      "likes": 560,
      "caption": "No pain no gain 🔥",
      "time": "3 hours ago",
    },
    {
      "username": "fashion_trend",
      "profile": "https://i.pravatar.cc/150?img=11",
      "media": "https://images.unsplash.com/photo-1490481651871-ab68de25d43d",
      "type": "image",
      "likes": 76,
      "caption": "New look 😎",
      "time": "6 hours ago",
    },
    {
      "username": "car_lovers",
      "profile": "https://i.pravatar.cc/150?img=12",
      "media":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "type": "video",
      "likes": 999,
      "caption": "Dream car 🚗",
      "time": "1 day ago",
    },
    {
      "username": "nature_clicks",
      "profile": "https://i.pravatar.cc/150?img=13",
      "media": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
      "type": "image",
      "likes": 430,
      "caption": "Sunset vibes 🌅",
      "time": "8 hours ago",
    },
    {
      "username": "daily_motivation",
      "profile": "https://i.pravatar.cc/150?img=14",
      "media":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "type": "video",
      "likes": 150,
      "caption": "Stay focused 💯",
      "time": "7 hours ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                return storyItem(
                  stories[index]["image"]!,
                  stories[index]["name"]!,
                  isFirst: index == 0,
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostItem(post: posts[index]);
               
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget storyItem(String imageUrl, String name, {bool isFirst = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.orange, Colors.purple],
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 29,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
              ),
              if (isFirst)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
