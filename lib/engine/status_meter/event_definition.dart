import 'package:no_updates_from_me/engine/status_meter/action.dart';

enum EventTag {
  operational,
  institutional,
  social,
  personal;

  static EventTag fromString(String value) {
    return EventTag.values.firstWhere((e) => e.name == value);
  }
}

class EventDefinition {
  final String id;
  final String text;
  final List<EventTag> tags;
  final double baseWeight;
  final double priority;
  final int cooldownTurns;
  final Map<StatusMeterAction, EventEffect> effects;

  const EventDefinition({
    required this.id,
    required this.text,
    required this.tags,
    required this.baseWeight,
    this.priority = 1.0,
    this.cooldownTurns = 5,
    required this.effects,
  });

  factory EventDefinition.fromJson(Map<String, dynamic> json) {
    var effectsMap = <StatusMeterAction, EventEffect>{};
    (json['effects'] as Map<String, dynamic>).forEach((key, value) {
      effectsMap[StatusMeterAction.fromString(key)] =
          EventEffect.fromJson(value);
    });

    return EventDefinition(
      id: json['id'],
      text: json['text'],
      tags: (json['tags'] as List)
          .map((tag) => EventTag.fromString(tag))
          .toList(),
      baseWeight: (json['baseWeight'] as num).toDouble(),
      priority: (json['priority'] as num?)?.toDouble() ?? 1.0,
      cooldownTurns: (json['cooldownTurns'] as int?) ?? 5,
      effects: effectsMap,
    );
  }
}

class EventEffect {
  final int stress;
  final int institutionalTrust;
  final int teamCohesion;
  final int personalRisk;
  final int suspicion;
  final int momentum;
  final int fatigue;

  const EventEffect({
    this.stress = 0,
    this.institutionalTrust = 0,
    this.teamCohesion = 0,
    this.personalRisk = 0,
    this.suspicion = 0,
    this.momentum = 0,
    this.fatigue = 0,
  });

  factory EventEffect.fromJson(Map<String, dynamic> json) {
    return EventEffect(
      stress: json['stress'] ?? 0,
      institutionalTrust: json['institutionalTrust'] ?? 0,
      teamCohesion: json['teamCohesion'] ?? 0,
      personalRisk: json['personalRisk'] ?? 0,
      suspicion: json['suspicion'] ?? 0,
      momentum: json['momentum'] ?? 0,
      fatigue: json['fatigue'] ?? 0,
    );
  }
}
