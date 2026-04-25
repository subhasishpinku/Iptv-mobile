import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Musicplayerscreen extends StatefulWidget {
  const Musicplayerscreen({super.key});

  @override
  State<Musicplayerscreen> createState() => _MusicplayerscreenState();
}

class _MusicplayerscreenState extends State<Musicplayerscreen> {
  final AudioPlayer _player = AudioPlayer();

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    _player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });

    _initAudio();
  }

  Future<void> _initAudio() async {
    await _player.setUrl(
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
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

      /// 🔙 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Music Player"),
      ),

      body: Column(
        children: [
          const SizedBox(height: 30),

          /// 🎵 ALBUM CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
            child: Column(
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/images/music.png",
                    height: 180,
                    width: 180,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                /// TITLE
                const Text(
                  "Alan walker - Faded",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Artist - Alan walker",
                  style: TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Length - 3:10 mins",
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// 🔁 SWITCH TEXT
          const Text(
            "Switch to video music",
            style: TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 10),

          const Icon(Icons.video_library, color: Colors.white54),

          const SizedBox(height: 30),

          /// ⏮ ⏯ ⏭ CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_previous,
                    color: Colors.white, size: 30),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.fast_rewind,
                    color: Colors.white, size: 30),
              ),

              const SizedBox(width: 10),

              /// ▶️ PLAY / PAUSE BUTTON
              GestureDetector(
                onTap: () async {
                  if (isPlaying) {
                    await _player.pause();
                  } else {
                    await _player.play();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.fast_forward,
                    color: Colors.white, size: 30),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_next,
                    color: Colors.white, size: 30),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// 🎚 PROGRESS BAR
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _player.duration ?? Duration.zero;

              return Column(
                children: [
                  Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble() > 0
                        ? duration.inSeconds.toDouble()
                        : 1,
                    onChanged: (value) async {
                      await _player.seek(Duration(seconds: value.toInt()));
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _format(position),
                          style: const TextStyle(color: Colors.white54),
                        ),
                        Text(
                          _format(duration),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }
}