import 'package:flutter/services.dart';

abstract final class UiFeedback {
  static void tap() => HapticFeedback.selectionClick();

  static void action() => HapticFeedback.lightImpact();
}
