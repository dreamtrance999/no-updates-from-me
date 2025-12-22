import 'dart:math';

import 'package:no_updates_from_me/engine/status_meter/status_meter_game_state.dart';
import 'package:no_updates_from_me/ui_models/game_clock_ui_model.dart';

import '../persistence/game_database.dart';
import '../persistence/game_save.dart';

class GameRepository {
  final GameDatabase _db;

  const GameRepository(this._db);

  Future<void> save(GameSave save) => _db.saveJson(save.toJson());

  GameSave? load() {
    final json = _db.loadJson();
    if (json == null) return null;
    return GameSave.fromJson(json);
  }

  /// Creates a new save file for the Status & Meter game mode.
  GameSave createNewStatusMeterGame() {
    final seed = Random().nextInt(0x7FFFFFFF);
    final statusMeterState = StatusMeterGameState.initial(seed: seed);

    // The old game state is not used in this mode, so we create dummy data.
    return GameSave(
      clock: const GameClockUiModel(hour: 9, minute: 0, day: 1),
      channels: [],
      chatByChannel: {},
      morale: 50,
      stress: 10,
      statusMeterGameState: statusMeterState,
    );
  }

  Future<void> reset() => _db.clear();
}
