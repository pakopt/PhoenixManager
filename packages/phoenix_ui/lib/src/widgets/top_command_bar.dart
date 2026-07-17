import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/util/money_format.dart';

/// Barra superior com data, saldo, próximo jogo e CTA verde.
class TopCommandBar extends StatelessWidget implements PreferredSizeWidget {
  const TopCommandBar({
    required this.session,
    required this.playMode,
    required this.activeSlot,
    this.hasUnsavedChanges = false,
    this.inboxUnread = 0,
    this.onSave,
    this.onGoToMatch,
    this.onOpenMenu,
    this.onOpenInbox,
    this.compact = false,
    this.showLeadingMenu = false,
    super.key,
  });

  final GameSession session;
  final PlayMode playMode;
  final int activeSlot;
  final bool hasUnsavedChanges;
  final int inboxUnread;
  final VoidCallback? onSave;
  final VoidCallback? onGoToMatch;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onOpenInbox;
  final bool compact;
  final bool showLeadingMenu;

  @override
  Size get preferredSize => Size.fromHeight(compact ? 64 : 72);

  @override
  Widget build(BuildContext context) {
    final finance = session.userFinance;
    final next = session.nextFixture;
    final nextLabel = next == null
        ? 'Sem jogo'
        : '${session.clubName(next.homeClubId)} vs '
            '${session.clubName(next.awayClubId)}';

    return Material(
      color: PhoenixColors.headerBar,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: PhoenixColors.sidebarBorder),
            ),
          ),
          child: Row(
            children: [
              if (showLeadingMenu && onOpenMenu != null)
                IconButton(
                  tooltip: 'Menu do jogo',
                  onPressed: onOpenMenu,
                  icon: const Icon(Icons.menu),
                ),
              _MetaChip(
                icon: Icons.calendar_today_outlined,
                label: DateFormatUtil.gameDate(session.currentDate),
                compact: compact,
              ),
              if (!compact) ...[
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.sports_score_outlined,
                  label: 'Jornada ${session.tick}',
                  compact: compact,
                ),
              ],
              const SizedBox(width: 8),
              if (finance != null)
                _MetaChip(
                  icon: Icons.account_balance_wallet_outlined,
                  label: MoneyFormat.compact(finance.balance),
                  emphasize: true,
                  compact: compact,
                ),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nextLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PhoenixColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              if (onOpenInbox != null)
                IconButton(
                  tooltip: inboxUnread > 0
                      ? 'Inbox ($inboxUnread não lidas)'
                      : 'Inbox',
                  onPressed: onOpenInbox,
                  icon: Badge(
                    isLabelVisible: inboxUnread > 0,
                    label: Text('$inboxUnread'),
                    backgroundColor: PhoenixColors.seed,
                    child: const Icon(Icons.mail_outline),
                  ),
                ),
              if (hasUnsavedChanges && onSave != null) ...[
                compact
                    ? IconButton(
                        tooltip: 'Guardar',
                        onPressed: onSave,
                        icon: const Icon(
                          Icons.save_outlined,
                          color: PhoenixColors.warning,
                        ),
                      )
                    : TextButton.icon(
                        onPressed: onSave,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Guardar'),
                        style: TextButton.styleFrom(
                          foregroundColor: PhoenixColors.warning,
                        ),
                      ),
              ],
              if (!compact)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      playMode == PlayMode.express
                          ? Icons.flash_on
                          : Icons.manage_accounts,
                      size: 14,
                    ),
                    label: Text(
                      '${playMode.label} · S${activeSlot + 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              if (onGoToMatch != null && next != null && !session.isFullSeasonComplete)
                FilledButton.icon(
                  onPressed: onGoToMatch,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: Text(compact ? 'Jogo' : 'Ir ao jogo'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 16,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.emphasize = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool emphasize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: emphasize ? PhoenixColors.positive : PhoenixColors.muted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: emphasize
                  ? PhoenixColors.positive
                  : PhoenixColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
