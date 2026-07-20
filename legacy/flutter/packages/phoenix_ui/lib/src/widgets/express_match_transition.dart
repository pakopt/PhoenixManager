import 'package:flutter/material.dart';

/// Transição slide + fade ao abrir resultado Express.
class ExpressMatchPageRoute<T> extends PageRouteBuilder<T> {
  ExpressMatchPageRoute({required Widget child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Breve overlay "A simular…" antes de navegar para o jogo Express.
Future<void> showExpressSimulatingOverlay(BuildContext context) async {
  if (MediaQuery.disableAnimationsOf(context)) {
    return;
  }
  final navigator = Navigator.of(context);
  navigator.push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, __, ___) => const _ExpressSimulatingOverlay(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 380));
  if (navigator.mounted) {
    navigator.pop();
  }
}

class _ExpressSimulatingOverlay extends StatelessWidget {
  const _ExpressSimulatingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flash_on, size: 36, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'A simular jornada…',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Abre [screen] com transição Express (overlay opcional + route animada).
Future<void> openExpressMatchScreen(
  BuildContext context,
  Widget screen,
) async {
  await showExpressSimulatingOverlay(context);
  if (!context.mounted) {
    return;
  }
  await Navigator.of(context).push(
    ExpressMatchPageRoute<void>(child: screen),
  );
}
