import 'package:no_updates_from_me/persistence/game_mode_state.dart';

class GameSave {
  final GameModeState gameModeState;

  const GameSave({
    required this.gameModeState,
  });

  Map<String, dynamic> toJson() => {
        'gameModeState': gameModeState.toJson(),
      };

  static GameSave fromJson(Map<String, dynamic> json) {
    // Check if it's the new format with a `gameModeState` wrapper
    if (json.containsKey('gameModeState')) {
      final stateJson = (json['gameModeState'] as Map).cast<String, dynamic>();
      return GameSave(gameModeState: GameModeState.fromJson(stateJson));
    } else {
      // This is a legacy save file. We wrap it in the Narrative state.
      return GameSave(gameModeState: Narrative(saveData: json));
    }
  }

  // Helper method for the old game mode to get its data.
  static Map<String, dynamic> getNarrativeSaveData(GameSave save) {
    if (save.gameModeState is Narrative) {
      return (save.gameModeState as Narrative).saveData;
    }
    // Return empty map or throw error if the state is not Narrative
    return {};
  }
}
