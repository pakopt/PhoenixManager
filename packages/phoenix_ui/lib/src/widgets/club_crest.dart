import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';

/// Emblema do clube (asset) ou inicial de fallback.
class ClubCrest extends StatelessWidget {
  const ClubCrest({
    required this.club,
    this.size = 40,
    this.showBorder = true,
    super.key,
  });

  final Club club;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final asset = club.logoAsset;

    if (asset != null && asset.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: showBorder
              ? Border.all(color: PhoenixColors.cardBorder, width: 1)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(size * 0.06),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _Initial(
              name: club.displayShortName,
              size: size,
            ),
          ),
        ),
      );
    }

    return _Initial(name: club.displayShortName, size: size);
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: PhoenixColors.seed,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
          color: Colors.white,
        ),
      ),
    );
  }
}
