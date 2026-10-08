import 'dart:io';

import 'package:flutter/services.dart';

/// Serves bundled assets over loopback HTTP so embedded WebViews get a real
/// origin. Android and iOS WebViews block ES modules and `fetch()` on
/// `file://` pages, which prevents three.js and its GLB model from loading.
class LocalAssetServer {
  LocalAssetServer._();

  static const _servedPrefixes = ['assets/three/', 'assets/models/'];

  static Future<Uri>? _baseUri;

  /// Base URI of the shared server; asset `assets/x` is served at `base/assets/x`.
  static Future<Uri> get baseUri => _baseUri ??= _start().catchError(
        (Object error, StackTrace stackTrace) {
          // Allow a later retry instead of caching the failure.
          _baseUri = null;
          return Future<Uri>.error(error, stackTrace);
        },
      );

  static Future<Uri> _start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
    return Uri.parse('http://${server.address.address}:${server.port}/');
  }

  static Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    final segments = request.uri.pathSegments;
    final key = segments.join('/');
    final allowed = request.method == 'GET' &&
        !segments.contains('..') &&
        _servedPrefixes.any(key.startsWith);
    try {
      if (!allowed) throw const FormatException();
      final data = await rootBundle.load(key);
      response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = _contentTypeFor(key)
        ..headers.contentLength = data.lengthInBytes
        ..add(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    } catch (_) {
      response.statusCode = HttpStatus.notFound;
    }
    await response.close();
  }

  static ContentType _contentTypeFor(String key) {
    // Module scripts are rejected unless served with a JavaScript MIME type.
    if (key.endsWith('.js')) {
      return ContentType('text', 'javascript', charset: 'utf-8');
    }
    if (key.endsWith('.html')) return ContentType.html;
    if (key.endsWith('.glb')) return ContentType('model', 'gltf-binary');
    if (key.endsWith('.json')) return ContentType.json;
    if (key.endsWith('.txt') || key.endsWith('.md')) return ContentType.text;
    return ContentType.binary;
  }
}
