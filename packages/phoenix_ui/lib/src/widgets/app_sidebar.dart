import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';

typedef ShellDestination = (IconData outlined, IconData filled, String label);

/// Sidebar escura estilo FootSim (wide layout).
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.clubName,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    this.extended = true,
    this.onOpenMenu,
    super.key,
  });

  final String clubName;
  final List<ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool extended;
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final width = extended ? 220.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      decoration: const BoxDecoration(
        color: PhoenixColors.sidebar,
        border: Border(
          right: BorderSide(color: PhoenixColors.sidebarBorder),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                extended ? 16 : 12,
                16,
                extended ? 12 : 12,
                8,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: extended ? 18 : 16,
                    backgroundColor: PhoenixColors.seed,
                    child: Text(
                      clubName.isEmpty
                          ? '?'
                          : clubName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        clubName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: PhoenixColors.textPrimary,
                        ),
                      ),
                    ),
                    if (onOpenMenu != null)
                      IconButton(
                        tooltip: 'Menu do jogo',
                        onPressed: onOpenMenu,
                        icon: const Icon(Icons.more_horiz),
                        color: PhoenixColors.muted,
                      ),
                  ] else if (onOpenMenu != null)
                    IconButton(
                      tooltip: 'Menu do jogo',
                      onPressed: onOpenMenu,
                      icon: const Icon(Icons.more_horiz, size: 20),
                      color: PhoenixColors.muted,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final dest = destinations[index];
                  final selected = index == selectedIndex;
                  return _NavItem(
                    outlined: dest.$1,
                    filled: dest.$2,
                    label: dest.$3,
                    selected: selected,
                    extended: extended,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.outlined,
    required this.filled,
    required this.label,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final IconData outlined;
  final IconData filled;
  final String label;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? PhoenixColors.seed.withValues(alpha: 0.22)
        : Colors.transparent;
    final fg = selected ? PhoenixColors.positive : PhoenixColors.muted;

    final child = Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: selected
            ? Border.all(color: PhoenixColors.seed.withValues(alpha: 0.4))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? 12 : 0,
              vertical: 12,
            ),
            child: extended
                ? Row(
                    children: [
                      Icon(selected ? filled : outlined, color: fg, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selected
                                ? PhoenixColors.textPrimary
                                : PhoenixColors.muted,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(
                      selected ? filled : outlined,
                      color: fg,
                      size: 22,
                    ),
                  ),
          ),
        ),
      ),
    );

    if (extended) {
      return child;
    }
    return Tooltip(message: label, child: child);
  }
}
