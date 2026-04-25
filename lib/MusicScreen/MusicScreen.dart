import 'package:flutter/material.dart';
import 'package:iptvmobile/routes/routes_names.dart';
import 'package:just_audio/just_audio.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _player = AudioPlayer();

  String? _currentUrl;
  int? _currentIndex;
  bool _isPlaying = false;

  final List<String> categories = [
    "assets/images/music.png",
    "assets/images/music1.png",
    "assets/images/music2.png",
  ];

  final List<String> trending = [
    "assets/images/trandin1.png",
    "assets/images/trandin2.png",
    "assets/images/trandin3.png",
    "assets/images/trandin4.png",
    "assets/images/trandin5.png",
  ];

  final List<Map<String, String>> songs = [
    {
      "image": "assets/images/play.png",
      "title": "Katy Perry - Roar",
      "time": "3:20",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    },
    {
      "image": "assets/images/play1.png",
      "title": "Taylor Swift - Shake It Off",
      "time": "3:45",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    },
  ];

  Future<void> _playMusic(int index) async {
    final url = songs[index]["url"]!;

    if (_currentIndex == index) {
      /// 🔁 TOGGLE
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    try {
      await _player.setUrl(url);
      await _player.play();

      setState(() {
        _currentIndex = index;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    /// 🎧 PLAY / PAUSE LISTENER
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    /// 🔚 COMPLETE হলে reset
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _currentIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Music"),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
            ),

            /// 🎵 CATEGORY
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(categories[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 TRENDING
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Trending",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: trending.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(trending[index], fit: BoxFit.cover),
                );
              },
            ),

            /// 🎧 SONG LIST
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final song = songs[index];

                final isCurrent = _currentIndex == index;
                final isPlaying = _player.playing;

                return GestureDetector(
                  onTap: () => _playMusic(index),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.musicPlayerScreen,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              song["image"]!,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              song["title"]!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          Text(
                            song["time"]!,
                            style: const TextStyle(color: Colors.white54),
                          ),

                          const SizedBox(width: 10),

                          /// ▶ PLAY / ⏸ PAUSE ICON
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white24,
                            ),
                            padding: const EdgeInsets.all(
                              8,
                            ), // 👈 padding একটু কমাও
                            child: Icon(
                              isCurrent && _isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 35, // 👈 ICON SIZE CONTROL এখানে
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
