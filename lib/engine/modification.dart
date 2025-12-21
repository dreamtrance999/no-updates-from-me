import 'game_state.dart';

const _npc = 'npc';

abstract class Modification {
  void apply(GameState state);

  factory Modification.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('stat')) {
      return StatModification.fromJson(json);
    }
    if (json.containsKey('addFlag')) {
      return AddFlagModification.fromJson(json);
    }
    if (json.containsKey('removeFlag')) {
      return RemoveFlagModification.fromJson(json);
    }
    if (json.containsKey(_npc)) {
      return NpcModification.fromJson(json);
    }
    throw ArgumentError('Unknown modification type: $json');
  }
}

class MultiModification implements Modification {
  final List<Modification> modifications;

  MultiModification({required this.modifications});

  @override
  void apply(GameState state) {
    for (final m in modifications) {
      m.apply(state);
    }
  }

  factory MultiModification.fromJson(List<dynamic> json) {
    final mods = json.map((j) => Modification.fromJson(j)).toList();
    return MultiModification(modifications: mods);
  }
}

class StatModification implements Modification {
  final String stat;
  final int? increment;
  final int? set;

  StatModification({required this.stat, this.increment, this.set});

  @override
  void apply(GameState state) {
    int? value;
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
    }

    if (value == null) {
      return;
    }

    if (increment != null) {
      value += increment!;
    }
    if (set != null) {
      value = set!;
    }

    switch (stat) {
      case 'time':
        state.time = value;
        break;
      case 'stress':
        state.stress = value;
        break;
      case 'morale':
        state.morale = value;
        break;
      case 'chaos':
        state.chaos = value;
        break;
    }
  }

  factory StatModification.fromJson(Map<String, dynamic> json) {
    return StatModification(
      stat: json['stat'],
      increment: json['increment'],
      set: json['set'],
    );
  }
}

class AddFlagModification implements Modification {
  final String flag;

  AddFlagModification({required this.flag});

  @override
  void apply(GameState state) {
    state.flags.add(flag);
  }

  factory AddFlagModification.fromJson(Map<String, dynamic> json) {
    return AddFlagModification(flag: json['addFlag']);
  }
}

class RemoveFlagModification implements Modification {
  final String flag;

  RemoveFlagModification({required this.flag});

  @override
  void apply(GameState state) {
    state.flags.remove(flag);
  }

  factory RemoveFlagModification.fromJson(Map<String, dynamic> json) {
    return RemoveFlagModification(flag: json['removeFlag']);
  }
}

class NpcModification implements Modification {
  final String npcId;
  final int? moodIncrement;

  NpcModification({required this.npcId, this.moodIncrement});

  @override
  void apply(GameState state) {
    final npcState = state.npcStates[npcId];
    if (npcState == null) {
      return;
    }

    if (moodIncrement != null) {
      npcState.mood += moodIncrement!;
    }
  }

  factory NpcModification.fromJson(Map<String, dynamic> json) {
    final data = json[_npc];
    return NpcModification(
      npcId: data['id'],
      moodIncrement: data['mood'],
    );
  }
}
