import 'choice.dart';
import 'prerequisite.dart';

class Event {
  final String id;
  final String channel;
  final int baseWeight;
  final int cooldown;
  final Prerequisite prereq;
  final List<String> text;
  final List<Choice> choices;

  Event({
    required this.id,
    required this.channel,
    required this.baseWeight,
    required this.cooldown,
    required this.prereq,
    required this.text,
    required this.choices,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final choices =
        (json['choices'] as List).map((j) => Choice.fromJson(j)).toList();

    return Event(
      id: json['id'],
      channel: json['channel'],
      baseWeight: json['baseWeight'] ?? 10,
      cooldown: json['cooldown'] ?? 0,
      prereq: Prerequisite.fromJson(json['prereq'] ?? {}),
      text: (json['text'] as List).map((e) => e as String).toList(),
      choices: choices,
    );
  }
}
