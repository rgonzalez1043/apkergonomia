import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../../../core/constants/body_region.dart';
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
  static int _nextId = 0;

  late final String _instanceId;
  late final String _viewType;
  late final String _source;
  late final web.HTMLIFrameElement _iframe;
  late final StreamSubscription<web.MessageEvent> _messageSubscription;

  @override
  void initState() {
    super.initState();
    final id = _nextId++;
    _instanceId = 'ergobody-$id';
    _viewType = 'ergobody-view-$id';
    _iframe = web.HTMLIFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = '0'
      ..setAttribute('title', 'Mapa corporal 3D interactivo')
      ..setAttribute('aria-label', 'Mapa corporal 3D interactivo');
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
    _messageSubscription = web.window.onMessage.listen(_onMessage);
    _source = Uri.parse(web.document.baseURI)
        .resolve('assets/assets/three/body_map.html')
        .replace(
      queryParameters: {
        'instance': _instanceId,
        'view': widget.view.name,
        'theme': widget.isDark ? 'dark' : 'light',
        if (widget.selectedRegion != null)
          'selected': widget.selectedRegion!.name,
      },
    ).toString();
    _iframe.src = _source;
  }

  void _onMessage(web.MessageEvent event) {
    if (event.origin != web.window.location.origin ||
        event.source != _iframe.contentWindow) {
      return;
    }
    final raw = event.data.dartify();
    if (raw is! String) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['channel'] != 'ergobody' ||
        decoded['instanceId'] != _instanceId) {
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

  void _sendState() {
    final command = jsonEncode({
      'channel': 'ergobody-command',
      'instanceId': _instanceId,
      'selectedRegion': widget.selectedRegion?.name,
      'view': widget.view.name,
      'theme': widget.isDark ? 'dark' : 'light',
    });
    _iframe.contentWindow
        ?.postMessage(command.toJS, web.window.location.origin.toJS);
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _iframe.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
