class StatusMeterGameState {
  final int turnIndex;
  final int rngSeed;
  final int stress;
  final int institutionalTrust;
  final int teamCohesion;
  final int personalRisk;
  final int suspicion;
  final int momentum;
  final int fatigue;
  final bool isStressAsCurrencyUnlocked;
  final bool isTrustInversionUnlocked;
  final Map<String, int> eventCooldowns;
  final Map<String, int> eventSeenCounts;
  final List<HistoryEntry> history;
  final String? endingId;
  final String? endingSummary;
  final bool isRunFinished;

  int get minutesElapsed => turnIndex * 2;

  const StatusMeterGameState({
    required this.turnIndex,
    required this.rngSeed,
    this.stress = 10,
    this.institutionalTrust = 50,
    this.teamCohesion = 50,
    this.personalRisk = 0,
    this.suspicion = 0,
    this.momentum = 20,
    this.fatigue = 0,
    this.isStressAsCurrencyUnlocked = false,
    this.isTrustInversionUnlocked = false,
    this.eventCooldowns = const {},
    this.eventSeenCounts = const {},
    this.history = const [],
    this.endingId,
    this.endingSummary,
    this.isRunFinished = false,
  });

  factory StatusMeterGameState.initial({required int seed}) {
    return StatusMeterGameState(turnIndex: 0, rngSeed: seed);
  }

  StatusMeterGameState copyWith({
    int? turnIndex,
    int? rngSeed,
    int? stress,
    int? institutionalTrust,
    int? teamCohesion,
    int? personalRisk,
    int? suspicion,
    int? momentum,
    int? fatigue,
    bool? isStressAsCurrencyUnlocked,
    bool? isTrustInversionUnlocked,
    Map<String, int>? eventCooldowns,
    Map<String, int>? eventSeenCounts,
    List<HistoryEntry>? history,
    String? endingId,
    String? endingSummary,
    bool? isRunFinished,
  }) {
    return StatusMeterGameState(
      turnIndex: turnIndex ?? this.turnIndex,
      rngSeed: rngSeed ?? this.rngSeed,
      stress: stress ?? this.stress,
      institutionalTrust: institutionalTrust ?? this.institutionalTrust,
      teamCohesion: teamCohesion ?? this.teamCohesion,
      personalRisk: personalRisk ?? this.personalRisk,
      suspicion: suspicion ?? this.suspicion,
      momentum: momentum ?? this.momentum,
      fatigue: fatigue ?? this.fatigue,
      isStressAsCurrencyUnlocked:
          isStressAsCurrencyUnlocked ?? this.isStressAsCurrencyUnlocked,
      isTrustInversionUnlocked:
          isTrustInversionUnlocked ?? this.isTrustInversionUnlocked,
      eventCooldowns: eventCooldowns ?? this.eventCooldowns,
      eventSeenCounts: eventSeenCounts ?? this.eventSeenCounts,
      history: history ?? this.history,
      endingId: endingId ?? this.endingId,
      endingSummary: endingSummary ?? this.endingSummary,
      isRunFinished: isRunFinished ?? this.isRunFinished,
    );
  }
}

class HistoryEntry {
  final int turnIndex;
  final String eventId;
  final String eventText;
  final String action;

  const HistoryEntry({
    required this.turnIndex,
    required this.eventId,
    required this.eventText,
    required this.action,
  });
}
