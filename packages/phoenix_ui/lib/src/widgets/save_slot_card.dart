import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/game/save_slot.dart';

class SaveSlotCard extends StatelessWidget {
  const SaveSlotCard({
    required this.meta,
    required this.onContinue,
    required this.onNewCareer,
    this.onDelete,
    this.isLoading = false,
    super.key,
  });

  final SaveSlotMeta meta;
  final VoidCallback? onContinue;
  final VoidCallback? onNewCareer;
  final VoidCallback? onDelete;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: meta.isEmpty ? onNewCareer : onContinue,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: meta.isEmpty
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  meta.isEmpty ? Icons.add : Icons.sports_soccer,
                  color: meta.isEmpty
                      ? theme.colorScheme.outline
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      meta.isEmpty
                          ? 'Vazio — iniciar nova carreira'
                          : meta.clubName!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!meta.isEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta.summarySubtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                      if (meta.savedAt != null)
                        Text(
                          'Guardado ${DateFormatUtil.relative(meta.savedAt!)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (!meta.isEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Continuar',
                  onPressed: onContinue,
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: theme.colorScheme.error),
                    tooltip: 'Apagar save',
                    onPressed: onDelete,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
