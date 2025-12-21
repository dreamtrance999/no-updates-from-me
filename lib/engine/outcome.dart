import 'game_state.dart';
import 'modification.dart';

class Outcome {
  final int weight;
  final List<Modification> modifications;
  final List<String> messages;

  Outcome({
    required this.weight,
    required this.modifications,
    required this.messages,
  });

  void apply(GameState state) {
    for (final mod in modifications) {
      mod.apply(state);
    }
  }

  factory Outcome.fromJson(Map<String, dynamic> json) {
    final modifications =
        (json['apply'] as List).map((j) => Modification.fromJson(j)).toList();

    return Outcome(
      weight: json['weight'] ?? 1,
      modifications: modifications,
      messages: (json['messages'] as List).map((e) => e as String).toList(),
    );
  }
}
