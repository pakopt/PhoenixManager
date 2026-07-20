import 'package:flutter/material.dart';

/// Tokens de cor Phoenix (identidade escura + verde).
abstract final class PhoenixColors {
  static const seed = Color(0xFF2E7D32);
  static const surface = Color(0xFF0A0E14);
  static const card = Color(0xFF141A22);
  static const cardBorder = Color(0xFF1F2937);
  static const sidebar = Color(0xFF080C11);
  static const sidebarBorder = Color(0xFF1A222D);
  static const headerBar = Color(0xFF0E141C);
  static const muted = Color(0xFF8B9AAB);
  static const textPrimary = Color(0xFFE8EEF4);
  static const textSecondary = Color(0xFFB0BCC9);
  static const positive = Color(0xFF43A047);
  static const negative = Color(0xFFC62828);
  static const warning = Color(0xFFEF6C00);
  static const draw = Color(0xFFF9A825);
  static const heroGradientStart = Color(0xFF0F2918);
  static const heroGradientEnd = Color(0xFF141A22);
}

abstract final class PhoenixTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PhoenixColors.seed,
        brightness: Brightness.dark,
        surface: PhoenixColors.surface,
        primary: PhoenixColors.seed,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: PhoenixColors.surface,
      dividerColor: PhoenixColors.cardBorder,
      textTheme: base.textTheme.apply(
        bodyColor: PhoenixColors.textPrimary.withValues(alpha: 0.92),
        displayColor: PhoenixColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: PhoenixColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PhoenixColors.cardBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: PhoenixColors.headerBar,
        foregroundColor: PhoenixColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: PhoenixColors.card,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PhoenixColors.card,
        indicatorColor: PhoenixColors.seed.withValues(alpha: 0.35),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PhoenixColors.seed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PhoenixColors.textSecondary,
          side: const BorderSide(color: PhoenixColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: PhoenixColors.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PhoenixColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PhoenixColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PhoenixColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PhoenixColors.seed, width: 1.5),
        ),
      ),
    );
  }
}
