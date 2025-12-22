import 'dart:math';

import 'package:collection/collection.dart';
import 'package:no_updates_from_me/engine/status_meter/action.dart';
import 'package:no_updates_from_me/engine/status_meter/event_definition.dart';
import 'package:no_updates_from_me/engine/status_meter/status_meter_game_state.dart';

class StatusMeterEngine {
  final List<EventDefinition> _eventDefinitions;
  late Random _random;

  StatusMeterEngine({required List<EventDefinition> eventDefinitions})
      : _eventDefinitions = eventDefinitions;

  EventDefinition selectNextEvent(StatusMeterGameState state) {
    _random = Random(state.rngSeed + state.turnIndex);

    final eligibleEvents = _eventDefinitions.where((event) {
      if ((state.eventCooldowns[event.id] ?? 0) > state.turnIndex) {
        return false; // Event is on cooldown.
      }
      if ((state.eventSeenCounts[event.id] ?? 0) >= 3) {
        return false; // Cap non-core events at 3 appearances per run.
      }
      return true;
    }).toList();

    if (eligibleEvents.isEmpty) {
      return _eventDefinitions.firstWhere((e) => e.id == 'fallback_event');
    }

    // Score events and perform weighted random selection.
    final scoredEvents = eligibleEvents.map((event) {
      var weight = event.baseWeight;
      // Apply strong penalty for events seen in the last 5 turns.
      final lastSeen = state.history
              .lastWhereOrNull((h) => h.eventId == event.id)
              ?.turnIndex ??
          -100;
      if (state.turnIndex - lastSeen <= 5) {
        weight *= 0.1; // Reduce probability by 90%
      }
      return MapEntry(event, weight);
    }).toList();

    final totalWeight =
        scoredEvents.fold<double>(0.0, (sum, entry) => sum + entry.value);
    var pick = _random.nextDouble() * totalWeight;

    for (final entry in scoredEvents) {
      if (pick < entry.value) {
        return entry.key;
      }
      pick -= entry.value;
    }

    return eligibleEvents.first;
  }

  StatusMeterGameState handleAction(
    StatusMeterGameState currentState,
    String eventId,
    StatusMeterAction action,
  ) {
    final event = _eventDefinitions.firstWhere((e) => e.id == eventId);
    final effect = event.effects[action]!;

    var newState = _applyEffects(currentState, effect, event.tags);
    newState = newState.copyWith(turnIndex: currentState.turnIndex + 1);

    final newCooldowns = Map<String, int>.from(newState.eventCooldowns);
    newCooldowns[eventId] = newState.turnIndex + event.cooldownTurns;
    final newSeenCounts = Map<String, int>.from(newState.eventSeenCounts);
    newSeenCounts[eventId] = (newSeenCounts[eventId] ?? 0) + 1;

    newState = newState.copyWith(
      eventCooldowns: newCooldowns,
      eventSeenCounts: newSeenCounts,
    );

    newState = _checkUnlocks(newState);

    final historyEntry = HistoryEntry(
      turnIndex: currentState.turnIndex,
      eventId: event.id,
      eventText: event.text,
      action: action.label,
    );
    newState = newState.copyWith(history: [...newState.history, historyEntry]);

    newState = _checkEndCondition(newState);
    return newState;
  }

  StatusMeterGameState _applyEffects(
      StatusMeterGameState state, EventEffect effect, List<EventTag> tags) {
    int stressChange = effect.stress;
    int riskChange = effect.personalRisk;
    int suspicionChange = effect.suspicion;
    int trustChange = effect.institutionalTrust;

    // Rule Unlock 1: Stress as Currency
    if (state.isStressAsCurrencyUnlocked) {
      if (riskChange < 0) {
        stressChange += 5;
      }
      if (suspicionChange < 0) {
        stressChange += 5;
      }
    }

    // Rule Unlock 2: Trust Inversion
    if (state.isTrustInversionUnlocked &&
        tags.contains(EventTag.institutional)) {
      if (state.institutionalTrust > 60 && trustChange > 0) {
        riskChange += (trustChange * 0.5).round();
      }
    }

    return state.copyWith(
      stress: (state.stress + stressChange).clamp(0, 100),
      institutionalTrust:
          (state.institutionalTrust + trustChange).clamp(0, 100),
      teamCohesion: (state.teamCohesion + effect.teamCohesion).clamp(0, 100),
      personalRisk: (state.personalRisk + riskChange).clamp(0, 100),
      suspicion: (state.suspicion + suspicionChange).clamp(0, 100),
      momentum: (state.momentum + effect.momentum).clamp(0, 100),
      fatigue: (state.fatigue + effect.fatigue).clamp(0, 100),
    );
  }

  StatusMeterGameState _checkUnlocks(StatusMeterGameState state) {
    var history = List<HistoryEntry>.from(state.history);
    var newState = state;

    if (!newState.isStressAsCurrencyUnlocked && newState.minutesElapsed >= 20) {
      newState = newState.copyWith(isStressAsCurrencyUnlocked: true);
      history.add(HistoryEntry(
          // REMOVED const
          turnIndex: state.turnIndex,
          eventId: 'unlock',
          eventText:
              'Rule change: Stress can now be spent to reduce risk or suspicion.',
          action: 'System'));
    }
    if (!newState.isTrustInversionUnlocked && newState.minutesElapsed >= 40) {
      newState = newState.copyWith(isTrustInversionUnlocked: true);
      history.add(HistoryEntry(
          // REMOVED const
          turnIndex: state.turnIndex,
          eventId: 'unlock',
          eventText:
              'Rule change: High institutional trust now increases personal risk.',
          action: 'System'));
    }
    return newState.copyWith(history: history);
  }

  StatusMeterGameState _checkEndCondition(StatusMeterGameState state) {
    if (state.isRunFinished) return state;

    if (state.minutesElapsed >= 60) {
      return _computeEnding(state);
    }
    return state;
  }

  StatusMeterGameState _computeEnding(StatusMeterGameState state) {
    if (state.personalRisk > 80 && state.institutionalTrust > 50) {
      return state.copyWith(
          isRunFinished: true,
          endingId: 'scapegoat',
          endingSummary:
              'You took the fall for the project, lauded as a hero but privately blamed for the failures.');
    }
    if (state.teamCohesion > 80 && state.institutionalTrust < 30) {
      return state.copyWith(
          isRunFinished: true,
          endingId: 'collective_exit',
          endingSummary:
              'The team was strong, but faith in the institution was lost. You all left together.');
    }
    if (state.stress > 90 && state.momentum > 70) {
      return state.copyWith(
          isRunFinished: true,
          endingId: 'burnout_breakthrough',
          endingSummary:
              'The pressure was immense, but you pushed through, achieving a major breakthrough at great personal cost.');
    }
    if (state.institutionalTrust > 80 && state.personalRisk < 20) {
      return state.copyWith(
          isRunFinished: true,
          endingId: 'institutional_sacrifice',
          endingSummary:
              'You sacrificed your own ideas and towed the company line. You are safe, but the work is not your own.');
    }
    if (state.suspicion < 20 && state.stress < 20 && state.personalRisk < 20) {
      return state.copyWith(
          isRunFinished: true,
          endingId: 'quiet_survivor',
          endingSummary:
              'You kept your head down, did your work, and avoided all conflict. You survived, unnoticed.');
    }
    return state.copyWith(
        isRunFinished: true,
        endingId: 'drift_away',
        endingSummary:
            'The project fades into obscurity, another victim of corporate inertia. You move on.');
  }
}
