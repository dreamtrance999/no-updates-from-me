import 'dart:math';

class GameState {
  int time;
  int stress;
  int morale;
  int chaos;

  final Set<String> flags;
  final Map<String, int> eventHistory;
  final Random rng;

  GameState({
    required this.time,
    required this.stress,
    required this.morale,
    required this.chaos,
    int? seed,
  })  : flags = {},
        eventHistory = {},
        rng = Random(seed);

  factory GameState.initial() => GameState(
        time: 9 * 60, // Start at 9:00 AM
        stress: 10,
        morale: 70,
        chaos: 0,
      );
}
