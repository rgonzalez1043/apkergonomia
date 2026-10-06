import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
  static int _nextViewId = 0;

  late final String _viewType;
  late final web.HTMLIFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _viewType = 'exercise-youtube-${_nextViewId++}';
    _iframe = web.HTMLIFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = '0'
      ..setAttribute('title', 'Video demostrativo del ejercicio')
      ..setAttribute(
        'allow',
        'accelerometer; autoplay; clipboard-write; encrypted-media; '
            'gyroscope; picture-in-picture; web-share; fullscreen',
      )
      ..setAttribute('allowfullscreen', 'true');
    _loadVideo();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) _loadVideo();
  }

  void _loadVideo() {
    final query = Uri(queryParameters: const {
      'rel': '0',
      'playsinline': '1',
      'cc_load_policy': '1',
      'cc_lang_pref': 'es',
      'hl': 'es',
    }).query;
    _iframe.src =
        'https://www.youtube-nocookie.com/embed/${widget.videoId}?$query';
  }

  @override
  void dispose() {
    _iframe.src = 'about:blank';
    _iframe.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
