import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/constants/body_region.dart';
import '../../../../core/network/local_asset_server.dart';
import 'body_model_view.dart';

class InteractiveBodyModel extends StatefulWidget {
  final BodyRegion? selectedRegion;
  final BodyModelView view;
  final bool isDark;
  final ValueChanged<BodyRegion> onRegionSelected;
  final VoidCallback onReady;
  final VoidCallback onError;

  const InteractiveBodyModel({
    super.key,
    required this.selectedRegion,
    required this.view,
    required this.isDark,
    required this.onRegionSelected,
    required this.onReady,
    required this.onError,
  });

  @override
  State<InteractiveBodyModel> createState() => _InteractiveBodyModelState();
}

class _InteractiveBodyModelState extends State<InteractiveBodyModel> {
  late final WebViewController _controller;
  bool _pageReady = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'BodyMapBridge',
        onMessageReceived: _onMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            _pageReady = true;
            _sendState();
          },
          onWebResourceError: (error) {
            if (mounted && (error.isForMainFrame ?? true)) widget.onError();
          },
        ),
      );

    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    _loadPage();
  }

  // file:// pages cannot load ES modules or fetch the GLB, so serve over HTTP.
  Future<void> _loadPage() async {
    try {
      final base = await LocalAssetServer.baseUri;
      if (!mounted) return;
      await _controller.loadRequest(
        base.resolve('assets/three/body_map.html').replace(
          queryParameters: {
            'view': widget.view.name,
            'theme': widget.isDark ? 'dark' : 'light',
            if (widget.selectedRegion != null)
              'selected': widget.selectedRegion!.name,
          },
        ),
      );
    } catch (_) {
      if (mounted) widget.onError();
    }
  }

  void _onMessage(JavaScriptMessage message) {
    if (!mounted) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(message.message);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, dynamic> || decoded['channel'] != 'ergobody') {
      return;
    }
    switch (decoded['type']) {
      case 'ready':
        widget.onReady();
        _sendState();
      case 'regionSelected':
        final regionName = decoded['region'];
        if (regionName is! String) return;
        try {
          widget.onRegionSelected(BodyRegion.values.byName(regionName));
        } on ArgumentError {
          widget.onError();
        }
      case 'error':
        widget.onError();
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveBodyModel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRegion != widget.selectedRegion ||
        oldWidget.view != widget.view ||
        oldWidget.isDark != widget.isDark) {
      _sendState();
    }
  }

  Future<void> _sendState() async {
    if (!mounted || !_pageReady) return;
    final command = jsonEncode({
      'selectedRegion': widget.selectedRegion?.name,
      'view': widget.view.name,
      'theme': widget.isDark ? 'dark' : 'light',
    });
    try {
      await _controller.runJavaScript('window.bodyMapCommand($command);');
    } catch (_) {
      if (mounted) widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
