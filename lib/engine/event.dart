import 'choice.dart';
import 'event_line.dart';
import 'prerequisite.dart';

class Event {
  final String id;
  final String channel;
  final int baseWeight;
  final int cooldown;
  final Prerequisite prereq;
  final bool oneTime;
  final bool isFiller;
  final List<EventLine> text;
  final List<Choice> choices;

  Event({
    required this.id,
    required this.channel,
    required this.baseWeight,
    required this.cooldown,
    required this.prereq,
    required this.oneTime,
    required this.isFiller,
    required this.text,
    required this.choices,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final choices =
        (json['choices'] as List).map((j) => Choice.fromJson(j)).toList();

    final text =
        (json['text'] as List).map((j) => EventLine.fromJson(j)).toList();

    return Event(
      id: json['id'],
      channel: json['channel'],
      baseWeight: json['baseWeight'] ?? 10,
      cooldown: json['cooldown'] ?? 0,
      prereq: Prerequisite.fromJson(json['prereq'] ?? {}),
      oneTime: json['oneTime'] ?? false,
      isFiller: json['isFiller'] ?? false,
      text: text,
      choices: choices,
    );
  }
}
