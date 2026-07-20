import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/screens/career_menu_screen.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  bool _menuReady = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    await widget.controller.initializeMenu();
    if (mounted) {
      setState(() => _menuReady = true);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_menuReady) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return CareerMenuScreen(controller: widget.controller);
  }
}
