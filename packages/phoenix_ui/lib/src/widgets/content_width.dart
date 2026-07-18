import 'package:flutter/material.dart';

/// Limita a largura do conteúdo em ecrãs médios; em desktop largo preenche.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    required this.child,
    this.maxWidth = 920,
    /// Se true, não aplica teto de largura (shell desktop).
    this.expand = false,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (expand) {
      return child;
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
