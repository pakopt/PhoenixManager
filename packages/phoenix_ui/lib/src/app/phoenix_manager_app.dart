import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/screens/boot_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';

class PhoenixManagerApp extends StatefulWidget {
  const PhoenixManagerApp({super.key, GameController? controller})
      : _controller = controller;

  final GameController? _controller;

  @override
  State<PhoenixManagerApp> createState() => _PhoenixManagerAppState();
}

class _PhoenixManagerAppState extends State<PhoenixManagerApp> {
  late final GameController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget._controller == null;
    _controller = widget._controller ?? GameController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Phoenix Manager',
      debugShowCheckedModeBanner: false,
      theme: PhoenixTheme.dark(),
      home: BootScreen(controller: _controller),
    );
  }
}
