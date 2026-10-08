import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ergonoworkcoah/core/network/local_asset_server.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The test binding mocks HttpClient; this suite needs real loopback requests.
  setUpAll(() => HttpOverrides.global = null);

  Future<HttpClientResponse> get(String path) async {
    final base = await LocalAssetServer.baseUri;
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    final request = await client.getUrl(base.resolve(path));
    return request.close();
  }

  test('serves the body map over loopback HTTP with module-safe MIME types',
      () async {
    final base = await LocalAssetServer.baseUri;
    expect(base.scheme, 'http');
    expect(base.host, '127.0.0.1');

    final expected = {
      'assets/three/body_map.html': 'text/html',
      'assets/three/body_map.js': 'text/javascript',
      'assets/three/vendor/three.module.min.js': 'text/javascript',
      'assets/three/addons/loaders/GLTFLoader.js': 'text/javascript',
      'assets/models/male_anatomy_figure.glb': 'model/gltf-binary',
    };
    for (final entry in expected.entries) {
      final response = await get(entry.key);
      await response.drain<void>();
      expect(response.statusCode, HttpStatus.ok, reason: entry.key);
      expect(response.headers.contentType?.mimeType, entry.value,
          reason: entry.key);
    }
  });

  test('refuses assets outside the 3D viewer folders', () async {
    for (final path in [
      'assets/images/logo.png',
      'assets/three/missing.js',
      'pubspec.yaml',
    ]) {
      final response = await get(path);
      await response.drain<void>();
      expect(response.statusCode, HttpStatus.notFound, reason: path);
    }
  });
}
