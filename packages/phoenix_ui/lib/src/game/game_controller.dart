import 'package:flutter/foundation.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/game/save_slot.dart';
import 'package:phoenix_ui/src/game/save_storage.dart';
import 'package:phoenix_ui/src/util/date_format.dart';

/// Mutable UI controller — notifies widgets when the engine state changes.
class GameController extends ChangeNotifier {
  GameController({SaveStorage? saveStorage})
      : _saveStorage = saveStorage ?? SaveStorage();

  final SaveStorage _saveStorage;

  GameSession? _session;
  bool _booting = false;
  String? _error;
  PlayMode _playMode = PlayMode.director;
  int _activeSlot = 0;
  List<SaveSlotMeta> _slots = List.generate(
    SaveStorage.maxSlots,
    SaveSlotMeta.empty,
  );
  DateTime? _lastSavedAt;
  bool _unsavedChanges = false;
  final List<AchievementId> _pendingAchievementUnlocks = [];
  Set<AchievementId> _seenAchievementIds = {};

  GameSession? get session => _session;
  bool get isReady => _session != null;
  bool get isBooting => _booting;
  String? get error => _error;
  PlayMode get playMode => _playMode;
  int get activeSlot => _activeSlot;
  List<SaveSlotMeta> get slots => List.unmodifiable(_slots);
  bool get hasSave => _slots.any((s) => !s.isEmpty);
  DateTime? get lastSavedAt => _lastSavedAt;
  bool get hasUnsavedChanges => _unsavedChanges;

  Future<void> initializeMenu() async {
    await refreshSlots();
    notifyListeners();
  }

  Future<void> refreshSlots() async {
    _slots = await _saveStorage.listSlots();
  }

  void setPlayMode(PlayMode mode) {
    _playMode = mode;
    notifyListeners();
  }

  void togglePlayMode() {
    _playMode =
        _playMode == PlayMode.express ? PlayMode.director : PlayMode.express;
    notifyListeners();
  }

  Future<void> boot({String worldId = 'manager-career'}) async {
    if (_booting) {
      return;
    }
    _booting = true;
    _error = null;
    notifyListeners();

    try {
      final context = await AppBootstrap().boot(worldId: worldId);
      _session = GameSession(context);
      _seedAchievementTracking();
    } catch (e) {
      _error = e.toString();
    } finally {
      _booting = false;
      notifyListeners();
    }
  }

  Future<void> startNewCareer(int slot) async {
    _activeSlot = slot;
    await boot();
    if (_session != null) {
      _lastSavedAt = null;
      _unsavedChanges = false;
      notifyListeners();
    }
  }

  /// Continua o save mais recente ou inicia carreira Express no primeiro slot livre.
  Future<void> quickPlay() async {
    final saved = _slots.where((s) => !s.isEmpty).toList();
    if (saved.isNotEmpty) {
      saved.sort(
        (a, b) =>
            (b.savedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
              a.savedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
      );
      await continueCareer(saved.first.index);
      return;
    }

    final emptySlot = _slots.indexWhere((s) => s.isEmpty);
    _playMode = PlayMode.express;
    notifyListeners();
    await startNewCareer(emptySlot >= 0 ? emptySlot : 0);
  }

  Future<void> continueCareer(int slot) async {
    _activeSlot = slot;
    await boot();
    if (_session != null) {
      await loadGame(slot);
    }
  }

  Future<void> deleteSlot(int slot) async {
    await _saveStorage.clearSlot(slot);
    await refreshSlots();
    notifyListeners();
  }

  Future<void> saveGame([int? slot]) async {
    if (_session == null) {
      return;
    }
    final target = slot ?? _activeSlot;
    final now = DateTime.now();
    final json = _session!.exportSave();
    final meta = SaveSlotMeta(
      index: target,
      clubName: _session!.userClub.name,
      dateLabel: DateFormatUtil.gameDate(_session!.currentDate),
      tick: _session!.tick,
      savedAt: now,
      playMode: _playMode.name,
      seasonYear: _session!.seasonYear,
      leaguePosition: _session!.leaguePosition,
      leagueTitles: _session!.leagueTitlesWon,
      cupTitles: _session!.cupTitlesWon,
    );
    await _saveStorage.writeSlot(slot: target, json: json, meta: meta);
    _activeSlot = target;
    _lastSavedAt = now;
    _unsavedChanges = false;
    await refreshSlots();
    notifyListeners();
  }

  Future<bool> loadGame([int? slot]) async {
    if (_session == null) {
      return false;
    }
    final target = slot ?? _activeSlot;
    final json = await _saveStorage.readSlot(target);
    if (json == null) {
      return false;
    }
    _session!.importSave(json);
    _activeSlot = target;
    _seedAchievementTracking();
    final slots = await _saveStorage.listSlots();
    final meta = slots[target];
    if (!meta.isEmpty && meta.playMode != null) {
      _playMode = meta.playMode == PlayMode.express.name
          ? PlayMode.express
          : PlayMode.director;
    }
    _lastSavedAt = meta.savedAt;
    _unsavedChanges = false;
    await refreshSlots();
    notifyListeners();
    return true;
  }

  void advanceDay() {
    _session?.advanceDay();
    _afterSessionMutation();
  }

  void advanceWeek() {
    _session?.advanceWeek();
    _afterSessionMutation();
  }

  void advanceToNextMatch() {
    _session?.advanceToNextUserMatch();
    _afterSessionMutation();
  }

  /// Returns error message on failure, null on success.
  Future<String?> renewContract(PlayerId playerId, {int? extensionYears}) async {
    final error = _session?.renewContract(
      playerId,
      extensionYears: extensionYears,
    );
    if (error == null) {
      _afterSessionMutation();
    }
    return error;
  }

  /// Returns error message on failure, null on success.
  String? startNextSeason() {
    final error = _session?.beginNextSeason();
    if (error == null) {
      _afterSessionMutation();
    }
    return error;
  }

  /// Express shortcut — jump to next user match and return result for UI.
  MatchSimulationOutput? advanceExpressRound() {
    if (_session == null || _session!.nextFixture == null) {
      return null;
    }
    _session!.advanceToNextUserMatch();
    final match = _session!.getLatestUserMatch();
    _afterSessionMutation();
    return match;
  }

  List<AchievementId> consumePendingAchievementUnlocks() {
    final pending = List<AchievementId>.from(_pendingAchievementUnlocks);
    _pendingAchievementUnlocks.clear();
    return pending;
  }

  void _seedAchievementTracking() {
    _seenAchievementIds = Set<AchievementId>.from(
      _session?.registry.unlockedAchievements.keys ?? [],
    );
    _pendingAchievementUnlocks.clear();
  }

  void _trackNewAchievements() {
    if (_session == null) {
      return;
    }
    for (final id in _session!.registry.unlockedAchievements.keys) {
      if (_seenAchievementIds.add(id)) {
        _pendingAchievementUnlocks.add(id);
      }
    }
  }

  void _afterSessionMutation() {
    _unsavedChanges = true;
    _trackNewAchievements();
    notifyListeners();
  }
}
