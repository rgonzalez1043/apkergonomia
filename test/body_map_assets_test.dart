import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ergonoworkcoah/core/constants/body_region.dart';

void main() {
  test('the 3D body map defines every pain region exactly once', () {
    final script = File('assets/three/body_map.js').readAsStringSync();
    final zoneIds = RegExp(r"\{ id: '([^']+)'")
        .allMatches(script)
        .map((match) => match.group(1)!)
        .toList();
    final expected = BodyRegion.values.map((region) => region.name).toSet();

    expect(zoneIds, hasLength(expected.length));
    expect(zoneIds.toSet(), expected);
    expect(zoneIds.toSet(), hasLength(zoneIds.length));
  });

  test('the 3D body map vendors its runtime and uses raycasting', () {
    final script = File('assets/three/body_map.js').readAsStringSync();
    final requiredFiles = [
      'assets/three/body_map.html',
      'assets/three/vendor/three.module.min.js',
      'assets/three/vendor/three.core.min.js',
      'assets/three/addons/controls/OrbitControls.js',
      'assets/three/addons/loaders/GLTFLoader.js',
      'assets/three/THREE_LICENSE.txt',
      'assets/models/male_anatomy_figure.glb',
    ];

    expect(script, contains('new THREE.Raycaster()'));
    expect(script, contains("surface: 'front'"));
    expect(script, contains("surface: 'back'"));
    for (final path in requiredFiles) {
      expect(File(path).existsSync(), isTrue, reason: '$path is required');
    }
  });
}
