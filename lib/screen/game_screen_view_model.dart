import 'dart:math';

import 'package:flutter/foundation.dart';

import '../engine/actor.dart';
import '../engine/choice.dart' as engine;
import '../engine/decision_engine.dart';
import '../engine/event.dart' as engine;
import '../engine/event_line.dart';
import '../engine/game_state.dart';
import '../game_controller.dart';
import '../repository/asset_event_repository.dart';
import '../ui_models/chat_item_ui_model.dart';
import '../ui_models/game_channel_ui_model.dart';
import '../ui_models/game_clock_ui_model.dart';

class GameScreenViewModel extends ChangeNotifier {
  // ================= ENGINE =================
  late GameController _engineController;
  late AssetEventRepository _repo;

  // ================= UI STATE =================
  GameClockUiModel get _clock {
    const minutesInDay = 24 * 60;
    final time = _engineController.state.time;
    final day = (time ~/ minutesInDay) + 1;
    final minutesSinceMidnight = time % minutesInDay;
    return GameClockUiModel(
        day: day, minutesSinceMidnight: minutesSinceMidnight);
  }

  List<GameChannelUiModel> _channels = [];
  final Map<String, List<ChatItemUiModel>> _chatByChannel = {};

  bool _initialized = false;
  engine.Event? _activeEvent;

  final Map<String, Actor> _actors = {
    'olivia': const Actor(name: 'Olivia'),
    'pete': const Actor(name: 'Pete'),
    'gan': const Actor(name: 'Gan'),
  };

  // ================= GETTERS (USED BY UI) =================
  bool get isInitialized => _initialized;

  String get clockLabel => _clock.hhmm;

  int get day => _clock.day;

  String get weekday => _clock.weekday;

  int get morale => _engineController.state.morale;

  int get stress => _engineController.state.stress;

  int get chaos => _engineController.state.chaos;

  List<GameChannelUiModel> get channels =>
      _channels.where((c) => c.kind != GameChannelKind.dm).toList();

  List<GameChannelUiModel> get chats =>
      _channels.where((c) => c.kind == GameChannelKind.dm).toList();

  GameChannelUiModel get selectedChannel =>
      _channels.firstWhere((c) => c.isSelected);

  List<ChatItemUiModel> get chatItems =>
      _chatByChannel[selectedChannel.id] ?? const [];

  // ================= INIT =================
  Future<void> init() async {
    await _initEngine();
    _seedUi();
    if (_channels.isNotEmpty) {
      _pushEngineEvent(_channels.first.id);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _initEngine() async {
    final state = GameState.initial();
    _repo = AssetEventRepository();
    await _repo.init();
    final engineCore = DecisionEngine(_repo);
    _engineController = GameController(state, engineCore);
  }

  // ================= UI ACTIONS =================
  Future<void> onChannelSelected(String id) async {
    if (selectedChannel.id == id) {
      return;
    }
    _channels =
        _channels.map((c) => c.copyWith(isSelected: c.id == id)).toList();
    if (_chatByChannel[id]!.isEmpty) {
      _pushEngineEvent(id);
    }
    notifyListeners();
  }

  Future<void> onDecisionOptionSelected({
    required String decisionId,
    required String optionId,
  }) async {
    final channelId = selectedChannel.id;
    final items = List<ChatItemUiModel>.from(_chatByChannel[channelId]!);

    // mark decision resolved
    final idx = items.indexWhere(
      (e) => e is ChatDecisionUiModel && e.id == decisionId,
    );
    final decision = items[idx] as ChatDecisionUiModel;
    items[idx] = decision.copyWith(isResolved: true);

    // ENGINE RESOLVE
    final messages = _engineController.choose(_activeEvent!, optionId);

    for (final msg in messages) {
      items.add(
        ChatMessageUiModel(
          id: _randId(),
          actor: Actor.system,
          message: msg,
          timeLabel: _clock.hhmm,
        ),
      );
    }

    _chatByChannel[channelId] = items;

    // push next engine event
    _pushEngineEvent(channelId);

    notifyListeners();
  }

  Future<void> resetGame() async {
    await _initEngine();
    _seedUi();
    _chatByChannel.clear();
    if (_channels.isNotEmpty) {
      _chatByChannel[_channels.first.id] = [];
      _pushEngineEvent(_channels.first.id);
    }
    notifyListeners();
  }

  // ================= ENGINE → UI =================
  void _pushEngineEvent(String channelId) {
    final e = _engineController.nextEvent(channelId);
    _activeEvent = e;

    if (e == null) {
      // No event found, so we don't add anything to the chat.
      return;
    }

    _chatByChannel.putIfAbsent(channelId, () => []);

    for (final line in e.text) {
      _chatByChannel[channelId]!.add(
        ChatMessageUiModel(
          id: _randId(),
          actor: _getActor(line.actorId),
          message: line.line,
          timeLabel: _clock.hhmm,
        ),
      );
    }

    _chatByChannel[channelId]!.add(
      ChatDecisionUiModel(
        id: e.id,
        prompt: e.choices.isNotEmpty ? 'What do you do?' : '',
        isResolved: false,
        options: e.choices.map(_mapChoice).toList(),
      ),
    );
  }

  Actor _getActor(String? actorId) {
    if (actorId == null) {
      return Actor.system;
    }
    return _actors[actorId] ?? Actor.system;
  }

  DecisionOptionUiModel _mapChoice(engine.Choice c) {
    return DecisionOptionUiModel(
      id: c.id,
      label: c.label,
      hint: '',
      timeJumpMinutes: c.timeCost,
      outcomes: const [], // engine owns outcomes
    );
  }

  // ================= SEED DATA =================
  void _seedUi() {
    final channelNames = _repo.channels;
    _channels = channelNames.map((name) {
      final isDm = !name.startsWith('#');
      return GameChannelUiModel(
        id: name,
        title: name,
        kind: isDm ? GameChannelKind.dm : GameChannelKind.development,
        isSelected: name == channelNames.first,
        unreadCount: 0,
      );
    }).toList();

    for (final channel in _channels) {
      _chatByChannel[channel.id] = [];
    }
  }

  String _randId() => Random().nextInt(1 << 32).toString();
}
