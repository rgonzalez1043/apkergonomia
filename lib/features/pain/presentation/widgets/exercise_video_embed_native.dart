import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ExerciseVideoEmbed extends StatefulWidget {
  final String videoId;

  const ExerciseVideoEmbed({
    super.key,
    required this.videoId,
  });

  @override
  State<ExerciseVideoEmbed> createState() => _ExerciseVideoEmbedState();
}

class _ExerciseVideoEmbedState extends State<ExerciseVideoEmbed> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId == widget.videoId) return;
    _controller.close();
    _controller = _createController();
  }

  YoutubePlayerController _createController() {
    return YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        captionLanguage: 'es',
        interfaceLanguage: 'es',
        playsInline: true,
        strictRelatedVideos: true,
        privacyEnhancedMode: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
      backgroundColor: const Color(0xFF101820),
      enableFullScreenOnVerticalDrag: true,
    );
  }
}
