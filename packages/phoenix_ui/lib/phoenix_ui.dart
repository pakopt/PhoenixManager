library phoenix_ui;

export 'src/app/phoenix_manager_app.dart';
export 'src/game/game_controller.dart';
export 'src/game/game_session.dart';
export 'src/game/play_mode.dart';
export 'src/theme/phoenix_theme.dart';

import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/app/phoenix_manager_app.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';

/// Convenience entry for host apps.
Widget createPhoenixManagerApp({GameController? controller}) {
  return PhoenixManagerApp(controller: controller ?? GameController());
}
