import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final appDir = Directory.current.path;
  final outDir = Platform.environment['STORE_SCREENSHOT_DIR'] ??
      '$appDir/../../build/release/store/android/screenshots';

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final dir = Directory(outDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('$outDir/$name.png');
      await file.writeAsBytes(bytes, flush: true);
      stderr.writeln('STORE_SCREENSHOT_HOST: ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
