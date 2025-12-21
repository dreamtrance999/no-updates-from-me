import 'outcome.dart';

class Choice {
  final String id;
  final String label;
  final int timeCost;
  final List<Outcome> outcomes;

  Choice({
    required this.id,
    required this.label,
    required this.timeCost,
    required this.outcomes,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    final outcomes =
        (json['outcomes'] as List).map((j) => Outcome.fromJson(j)).toList();

    return Choice(
      id: json['id'],
      label: json['label'],
      timeCost: json['timeCost'] ?? 0,
      outcomes: outcomes,
    );
  }
}
