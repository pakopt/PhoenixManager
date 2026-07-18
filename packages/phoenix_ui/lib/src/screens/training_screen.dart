import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/training_prefs.dart';
import 'package:phoenix_ui/src/screens/academy_panel.dart';
import 'package:phoenix_ui/src/screens/player_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/util/player_display_profile.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: PhoenixColors.headerBar,
            child: const TabBar(
              tabs: [
                Tab(text: 'Treinos', icon: Icon(Icons.fitness_center)),
                Tab(text: 'Academia', icon: Icon(Icons.school)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TrainingPanel(controller: controller),
                AcademyPanel(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingPanel extends StatefulWidget {
  const _TrainingPanel({required this.controller});

  final GameController controller;

  @override
  State<_TrainingPanel> createState() => _TrainingPanelState();
}

class _TrainingPanelState extends State<_TrainingPanel> {
  var _snapshot = TrainingSnapshot(
    weekFocus: TrainingSnapshot.defaultWeekFocus(),
  );
  var _prefsLoaded = false;
  var _search = '';
  var _onlyTrainable = false;
  int? _loadedSlot;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _loadPrefs();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (!mounted) {
      return;
    }
    if (_loadedSlot != null &&
        _loadedSlot != widget.controller.activeSlot) {
      _loadPrefs();
      return;
    }
    setState(() {});
  }

  Future<void> _loadPrefs() async {
    final slot = widget.controller.activeSlot;
    final loaded = await TrainingPrefs.load(slot);
    if (!mounted) {
      return;
    }
    setState(() {
      _loadedSlot = slot;
      if (loaded != null) {
        _snapshot = loaded.weekFocus.isEmpty
            ? loaded.copyWith(weekFocus: TrainingSnapshot.defaultWeekFocus())
            : loaded;
      } else {
        _snapshot = TrainingSnapshot(
          weekFocus: TrainingSnapshot.defaultWeekFocus(),
        );
      }
      _prefsLoaded = true;
    });
  }

  Future<void> _persist() async {
    await TrainingPrefs.save(widget.controller.activeSlot, _snapshot);
  }

  void _setWeekFocus(int weekday, WeeklyTrainingFocus focus) {
    setState(() {
      _snapshot = _snapshot.copyWith(
        weekFocus: {..._snapshot.weekFocus, weekday: focus},
      );
    });
    _persist();
  }

  void _applyPreset() {
    setState(() {
      _snapshot = _snapshot.copyWith(
        weekFocus: TrainingSnapshot.defaultWeekFocus(),
      );
    });
    _persist();
    UiFeedback.tap();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Predefinição aplicada à semana.')),
    );
  }

  Future<void> _saveRoutine() async {
    await _persist();
    if (!mounted) {
      return;
    }
    UiFeedback.tap();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rotina de treino guardada.')),
    );
  }

  void _setPlayerFocus(String playerId, PlayerTrainingFocus focus) {
    setState(() {
      _snapshot = _snapshot.copyWith(
        playerFocus: {..._snapshot.playerFocus, playerId: focus},
      );
    });
    _persist();
  }

  static List<GameDate> _weekDates(GameDate current) {
    final weekday = DateTime(current.year, current.month, current.day).weekday;
    final monday = current.addDays(-(weekday - 1));
    return [for (var i = 0; i < 7; i++) monday.addDays(i)];
  }

  static const _dayLabels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

  Color _focusColor(WeeklyTrainingFocus focus) => switch (focus) {
        WeeklyTrainingFocus.physical => PhoenixColors.warning,
        WeeklyTrainingFocus.attacking => PhoenixColors.negative,
        WeeklyTrainingFocus.defending => const Color(0xFF1565C0),
        WeeklyTrainingFocus.possession => PhoenixColors.positive,
        WeeklyTrainingFocus.rest => PhoenixColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session!;
    final config = session.trainingConfig;
    final week = _weekDates(session.currentDate);
    final monday = week.first;
    final sunday = week.last;
    final trainable = session.trainablePlayers;
    final trainableIds = trainable.map((p) => p.id).toSet();

    var squad = List<Player>.from(session.squad);
    squad.sort(
      (a, b) => (b.potentialAbility - b.currentAbility)
          .compareTo(a.potentialAbility - a.currentAbility),
    );
    if (_onlyTrainable) {
      squad = squad.where((p) => trainableIds.contains(p.id)).toList();
    }
    final query = _search.trim().toLowerCase();
    if (query.isNotEmpty) {
      squad = squad
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          ScreenPageHeader(
            title: 'Treinos',
            subtitle:
                '${DateFormatUtil.gameDate(monday)} – ${DateFormatUtil.gameDate(sunday)}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_prefsLoaded)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                _WeekStrip(
                  days: [
                    for (var i = 0; i < 7; i++)
                      _DaySlot(
                        weekday: i + 1,
                        label: _dayLabels[i],
                        date: week[i],
                        isToday: week[i] == session.currentDate,
                        fixture: session.userFixtureOn(week[i]),
                        focus: _snapshot.focusForWeekday(i + 1),
                        focusColor: _focusColor(_snapshot.focusForWeekday(i + 1)),
                        opponentLabel: () {
                          final f = session.userFixtureOn(week[i]);
                          if (f == null) {
                            return null;
                          }
                          final oppId = f.homeClubId == GameSession.userClubId
                              ? f.awayClubId
                              : f.homeClubId;
                          final club = session.registry.getClub(oppId);
                          return club?.displayShortName ??
                              session.clubName(oppId);
                        }(),
                        onFocusChanged: (focus) => _setWeekFocus(i + 1, focus),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Predefinição',
                      style: TextStyle(
                        color: PhoenixColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _applyPreset,
                      child: const Text('Aplicar'),
                    ),
                    FilledButton.icon(
                      onPressed: _saveRoutine,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Guardar rotina'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Evolução PSE automática · ≤${config.maxAgeForGrowth} anos · '
                  '${(config.dailyCaGainChance * 100).toStringAsFixed(0)}% / dia',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PhoenixColors.muted,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Foco do plantel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _AvgChip(
                      label: 'Forma média',
                      value: '${session.squadAverageForm.round()}%',
                      color: PhoenixColors.positive,
                    ),
                    const SizedBox(width: 8),
                    _AvgChip(
                      label: 'Moral média',
                      value: '${session.squadAverageMorale.round()}%',
                      color: PhoenixColors.seed,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar jogadores…',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
                const SizedBox(height: 8),
                FilterChip(
                  label: Text(
                    'Só com margem de evolução (${trainable.length})',
                  ),
                  selected: _onlyTrainable,
                  onSelected: (v) => setState(() => _onlyTrainable = v),
                ),
                const SizedBox(height: 12),
                Text(
                  '${squad.length} jogadores',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: PhoenixColors.muted,
                      ),
                ),
                const SizedBox(height: 8),
                if (session.squad.isEmpty)
                  const EmptyState(
                    icon: Icons.groups_outlined,
                    message: 'Plantel vazio.',
                  )
                else if (squad.isEmpty)
                  const EmptyState(
                    icon: Icons.filter_alt_off,
                    message: 'Nenhum jogador corresponde aos filtros.',
                  )
                else
                  ...squad.map(
                    (player) => _PlayerTrainingRow(
                      player: player,
                      focus: _snapshot.focusForPlayer(player.id.value),
                      onFocusChanged: (focus) =>
                          _setPlayerFocus(player.id.value, focus),
                      onTap: () {
                        UiFeedback.tap();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlayerDetailScreen(
                              controller: widget.controller,
                              playerId: player.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySlot {
  const _DaySlot({
    required this.weekday,
    required this.label,
    required this.date,
    required this.isToday,
    required this.fixture,
    required this.focus,
    required this.focusColor,
    required this.opponentLabel,
    required this.onFocusChanged,
  });

  final int weekday;
  final String label;
  final GameDate date;
  final bool isToday;
  final MatchFixture? fixture;
  final WeeklyTrainingFocus focus;
  final Color focusColor;
  final String? opponentLabel;
  final ValueChanged<WeeklyTrainingFocus> onFocusChanged;
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.days});

  final List<_DaySlot> days;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < days.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _DayCard(slot: days[i])),
              ],
            ],
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < days.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                SizedBox(width: 118, child: _DayCard(slot: days[i])),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.slot});

  final _DaySlot slot;

  @override
  Widget build(BuildContext context) {
    final isMatch = slot.fixture != null;
    final borderColor = slot.isToday
        ? PhoenixColors.negative
        : isMatch
            ? PhoenixColors.seed.withValues(alpha: 0.55)
            : PhoenixColors.cardBorder;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: slot.isToday
            ? PhoenixColors.negative.withValues(alpha: 0.12)
            : PhoenixColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: slot.isToday ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                slot.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: PhoenixColors.muted,
                ),
              ),
              const Spacer(),
              Text(
                '${slot.date.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: slot.isToday
                      ? PhoenixColors.negative
                      : PhoenixColors.textPrimary,
                ),
              ),
            ],
          ),
          if (slot.isToday) ...[
            const SizedBox(height: 4),
            const Text(
              'HOJE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: PhoenixColors.negative,
                letterSpacing: 0.6,
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (isMatch)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sports_soccer, size: 18, color: PhoenixColors.seed),
                const SizedBox(height: 6),
                Text(
                  'vs ${slot.opponentLabel ?? 'adversário'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  slot.fixture!.isPlayed ? 'Jogado' : 'Jogo',
                  style: const TextStyle(
                    fontSize: 11,
                    color: PhoenixColors.muted,
                  ),
                ),
              ],
            )
          else
            DropdownButtonHideUnderline(
              child: DropdownButton<WeeklyTrainingFocus>(
                isExpanded: true,
                value: slot.focus,
                icon: Icon(
                  Icons.expand_more,
                  size: 18,
                  color: slot.focusColor,
                ),
                items: [
                  for (final focus in WeeklyTrainingFocus.values)
                    DropdownMenuItem(
                      value: focus,
                      child: Text(
                        focus.labelPt,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _colorFor(focus),
                        ),
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    slot.onFocusChanged(value);
                  }
                },
              ),
            ),
          if (!isMatch) ...[
            const SizedBox(height: 4),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: slot.focusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _colorFor(WeeklyTrainingFocus focus) => switch (focus) {
        WeeklyTrainingFocus.physical => PhoenixColors.warning,
        WeeklyTrainingFocus.attacking => PhoenixColors.negative,
        WeeklyTrainingFocus.defending => const Color(0xFF90CAF9),
        WeeklyTrainingFocus.possession => PhoenixColors.positive,
        WeeklyTrainingFocus.rest => PhoenixColors.muted,
      };
}

class _AvgChip extends StatelessWidget {
  const _AvgChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PhoenixColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PhoenixColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: PhoenixColors.muted,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerTrainingRow extends StatelessWidget {
  const _PlayerTrainingRow({
    required this.player,
    required this.focus,
    required this.onFocusChanged,
    required this.onTap,
  });

  final Player player;
  final PlayerTrainingFocus focus;
  final ValueChanged<PlayerTrainingFocus> onFocusChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final profile = PlayerDisplayProfile.from(player);
    final canGrow = player.currentAbility < player.potentialAbility;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: PhoenixColors.seed.withValues(alpha: 0.25),
                    child: Text(
                      '${player.currentAbility}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${profile.position} · ${player.age} anos · '
                          'CA ${player.currentAbility} → PA ${player.potentialAbility}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: PhoenixColors.muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (player.isInjured)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.healing,
                        size: 18,
                        color: PhoenixColors.negative,
                      ),
                    )
                  else if (canGrow)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.trending_up,
                        size: 18,
                        color: PhoenixColors.positive,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Forma',
                      value: player.form,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      label: 'Moral',
                      value: player.morale,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonHideUnderline(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          labelText: 'Foco',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: DropdownButton<PlayerTrainingFocus>(
                          isExpanded: true,
                          isDense: true,
                          value: focus,
                          items: [
                            for (final f in PlayerTrainingFocus.values)
                              DropdownMenuItem(
                                value: f,
                                child: Text(
                                  f.labelPt,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              onFocusChanged(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: PhoenixColors.muted),
            ),
            Text(
              '$value',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: PhoenixColors.cardBorder,
            color: color,
          ),
        ),
      ],
    );
  }
}
