import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:letterboxd/features/movie/pages/youtube_player_page.dart';

class MovieYoutubePlayer extends StatefulWidget {
  final String videoId;
  final String title;

  const MovieYoutubePlayer({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<MovieYoutubePlayer> createState() => _MovieYoutubePlayerState();
}

class _MovieYoutubePlayerState extends State<MovieYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        forceHD: true,
      ),
    );

    // Listen to fullscreen changes
    _controller.addListener(() {
      if (_controller.value.isFullScreen) {
        // Navigate to fullscreen page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YoutubePlayerPage(
              videoId: widget.videoId,
              title: widget.title,
            ),
          ),
        );
        // Exit fullscreen mode in the current player
        _controller.toggleFullScreenMode();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFFE9A6A6),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFFE9A6A6),
              handleColor: Color(0xFFE9A6A6),
            ),
            onReady: () {
              print('Player is ready.');
            },
          ),
        ),
      ],
    );
  }
} 