import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuração de system UI (edge-to-edge no Android 15+ / targetSdk 35).
abstract final class PhoenixPlatformChrome {
  /// macOS / Windows / Linux (não web, não mobile).
  static bool get isDesktop {
    if (kIsWeb) {
      return false;
    }
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// Activa edge-to-edge e barras transparentes em Android.
  ///
  /// Complementa `WindowCompat.setDecorFitsSystemWindows` em `MainActivity.kt`
  /// e alinha com a exigência da Play Console para apps que segmentam SDK 35.
  static void applyEdgeToEdgeIfAndroid() {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  /// Encerra a app (útil em fullscreen no desktop, onde Alt+F4 / Cmd+Q não são óbvios).
  static void quitApp() {
    if (kIsWeb) {
      return;
    }
    if (isDesktop) {
      exit(0);
    }
    SystemNavigator.pop();
  }
}
