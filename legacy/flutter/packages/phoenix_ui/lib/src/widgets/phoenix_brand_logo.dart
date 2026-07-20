import 'package:flutter/material.dart';

/// Logo de marca (mesma arte que o ícone da app / Dock).
///
/// Asset declarado em `apps/phoenix_manager/assets/branding/icon.png`.
class PhoenixBrandLogo extends StatelessWidget {
  const PhoenixBrandLogo({this.size = 72, super.key});

  final double size;

  static const assetPath = 'assets/branding/icon.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Phoenix Manager',
      ),
    );
  }
}
