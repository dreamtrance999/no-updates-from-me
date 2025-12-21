import 'game_state.dart';

const _npc = 'npc';

abstract class Prerequisite {
  bool isMet(GameState state);

  factory Prerequisite.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('anyOf')) {
      return AnyOfPrerequisite.fromJson(json);
    }
    if (json.containsKey('allOf')) {
      return AllOfPrerequisite.fromJson(json);
    }
    if (json.containsKey('stat')) {
      return StatPrerequisite.fromJson(json);
    }
    if (json.containsKey('hasFlag')) {
      return HasFlagPrerequisite.fromJson(json);
    }
    if (json.containsKey('not')) {
      return NotPrerequisite.fromJson(json);
    }
    if (json.containsKey(_npc)) {
      return NpcPrerequisite.fromJson(json);
    }
    // A prerequisite that is always met.
    return AllOfPrerequisite(prerequisites: []);
  }
}

class AllOfPrerequisite implements Prerequisite {
  final List<Prerequisite> prerequisites;

  AllOfPrerequisite({required this.prerequisites});

  @override
  bool isMet(GameState state) => prerequisites.every((p) => p.isMet(state));

  factory AllOfPrerequisite.fromJson(Map<String, dynamic> json) {
    final prereqs =
        (json['allOf'] as List).map((j) => Prerequisite.fromJson(j)).toList();
    return AllOfPrerequisite(prerequisites: prereqs);
  }
}

class AnyOfPrerequisite implements Prerequisite {
  final List<Prerequisite> prerequisites;

  AnyOfPrerequisite({required this.prerequisites});

  @override
  bool isMet(GameState state) => prerequisites.any((p) => p.isMet(state));

  factory AnyOfPrerequisite.fromJson(Map<String, dynamic> json) {
    final prereqs =
        (json['anyOf'] as List).map((j) => Prerequisite.fromJson(j)).toList();
    return AnyOfPrerequisite(prerequisites: prereqs);
  }
}

class NotPrerequisite implements Prerequisite {
  final Prerequisite prerequisite;

  NotPrerequisite({required this.prerequisite});

  @override
  bool isMet(GameState state) => !prerequisite.isMet(state);

  factory NotPrerequisite.fromJson(Map<String, dynamic> json) {
    final prereq = Prerequisite.fromJson(json['not']);
    return NotPrerequisite(prerequisite: prereq);
  }
}

class StatPrerequisite implements Prerequisite {
  final String stat;
  final int? greaterThan;
  final int? lessThan;
  final int? equalTo;

  StatPrerequisite({
    required this.stat,
    this.greaterThan,
    this.lessThan,
    this.equalTo,
  });

  @override
  bool isMet(GameState state) {
    int value;
    switch (stat) {
      case 'time':
        value = state.time;
        break;
      case 'stress':
        value = state.stress;
        break;
      case 'morale':
        value = state.morale;
        break;
      case 'chaos':
        value = state.chaos;
        break;
      default:
        return false;
    }

    if (greaterThan != null && value <= greaterThan!) {
      return false;
    }
    if (lessThan != null && value >= lessThan!) {
      return false;
    }
    if (equalTo != null && value != equalTo!) {
      return false;
    }
    return true;
  }

  factory StatPrerequisite.fromJson(Map<String, dynamic> json) {
    return StatPrerequisite(
      stat: json['stat'],
      greaterThan: json['greaterThan'],
      lessThan: json['lessThan'],
      equalTo: json['equalTo'],
    );
  }
}

class HasFlagPrerequisite implements Prerequisite {
  final String flag;

  HasFlagPrerequisite({required this.flag});

  @override
  bool isMet(GameState state) => state.flags.contains(flag);

  factory HasFlagPrerequisite.fromJson(Map<String, dynamic> json) {
    return HasFlagPrerequisite(flag: json['hasFlag']);
  }
}

class NpcPrerequisite implements Prerequisite {
  final String npcId;
  final int? moodGreaterThan;
  final int? moodLessThan;

  NpcPrerequisite({
    required this.npcId,
    this.moodGreaterThan,
    this.moodLessThan,
  });

  @override
  bool isMet(GameState state) {
    final npcState = state.npcStates[npcId];
    if (npcState == null) {
      return false;
    }

    if (moodGreaterThan != null && npcState.mood <= moodGreaterThan!) {
      return false;
    }
    if (moodLessThan != null && npcState.mood >= moodLessThan!) {
      return false;
    }
    return true;
  }

  factory NpcPrerequisite.fromJson(Map<String, dynamic> json) {
    final data = json[_npc];
    return NpcPrerequisite(
      npcId: data['id'],
      moodGreaterThan: data['moodGreaterThan'],
      moodLessThan: data['moodLessThan'],
    );
  }
}
