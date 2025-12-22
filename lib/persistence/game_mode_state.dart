import 'package:no_updates_from_me/engine/status_meter/status_meter_game_state.dart';

/// A wrapper for the state of the currently active game mode.
sealed class GameModeState {
  const GameModeState();

  factory GameModeState.fromJson(Map<String, dynamic> json) {
    final type = json['runtimeType'] as String;
    if (type == 'statusMeter') {
      return StatusMeter.fromJson(json);
    }
    // Default to Narrative for legacy saves or explicit narrative saves
    return Narrative.fromJson(json);
  }

  Map<String, dynamic> toJson();
}

class Narrative extends GameModeState {
  final Map<String, dynamic> saveData;
  const Narrative({required this.saveData});

  // Factory to construct from the 'saveData' part of the json
  factory Narrative.fromJson(Map<String, dynamic> json) {
    // Handles both new format { "runtimeType": "narrative", "saveData": {...} }
    // and legacy format { ... original save data ... }
    final data = json.containsKey('saveData') ? json['saveData'] : json;
    return Narrative(saveData: Map<String, dynamic>.from(data));
  }

  @override
  Map<String, dynamic> toJson() =>
      {'runtimeType': 'narrative', 'saveData': saveData};
}

class StatusMeter extends GameModeState {
  final StatusMeterGameState state;
  const StatusMeter({required this.state});

  factory StatusMeter.fromJson(Map<String, dynamic> json) {
    return StatusMeter(
      state: StatusMeterGameState.fromJson(
        Map<String, dynamic>.from(json['state']),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() =>
      {'runtimeType': 'statusMeter', 'state': state.toJson()};
}
