import 'dart:io';

import 'package:flutter/services.dart';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File(file).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

String? _materialIcons() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    for (final rel in [
      'artifacts/material_fonts/MaterialIcons-Regular.otf',
      'cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]) {
      final f = File('${dir.path}/$rel');
      if (f.existsSync()) return f.path;
    }
    dir = dir.parent;
  }
  return null;
}

/// Real app fonts for screenshot tests (widget tests use Ahem otherwise).
Future<void> loadAppFonts() async {
  await _loadFont('Baloo2', [
    'assets/fonts/Baloo2-Bold.ttf',
    'assets/fonts/Baloo2-ExtraBold.ttf',
  ]);
  await _loadFont('Nunito', [
    'assets/fonts/Nunito-SemiBold.ttf',
    'assets/fonts/Nunito-Bold.ttf',
  ]);
  final icons = _materialIcons();
  if (icons != null) await _loadFont('MaterialIcons', [icons]);
}
