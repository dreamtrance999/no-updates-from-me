import 'package:flutter_test/flutter_test.dart';
import 'package:no_updates_from_me/engine/status_meter/action.dart';
import 'package:no_updates_from_me/engine/status_meter/event_definition.dart';
import 'package:no_updates_from_me/engine/status_meter/status_meter_engine.dart';
import 'package:no_updates_from_me/engine/status_meter/status_meter_game_state.dart';

void main() {
  // A minimal set of event definitions for testing.
  final testEvents = [
    EventDefinition(
      id: 'event_1',
      text: 'Test event 1',
      tags: [EventTag.operational],
      baseWeight: 1.0,
      cooldownTurns: 2,
      effects: {
        StatusMeterAction.comply: const EventEffect(stress: 10),
      },
    ),
    EventDefinition(
      id: 'event_2',
      text: 'Test event 2',
      tags: [EventTag.personal],
      baseWeight: 1.0,
      effects: {
        StatusMeterAction.comply: const EventEffect(personalRisk: 10),
      },
    ),
  ];

  group('StatusMeterEngine', () {
    test('handleAction applies effects and advances turn', () {
      final engine = StatusMeterEngine(eventDefinitions: testEvents);
      final initialState = StatusMeterGameState.initial(seed: 123);

      final newState = engine.handleAction(
        initialState,
        'event_1',
        StatusMeterAction.comply,
      );

      expect(newState.turnIndex, 1);
      expect(newState.stress, initialState.stress + 10);
      expect(newState.history, isNotEmpty);
      expect(newState.history.first.eventId, 'event_1');
    });

    test('event selection is deterministic with the same seed', () {
      final engine = StatusMeterEngine(eventDefinitions: testEvents);
      final state1 = StatusMeterGameState.initial(seed: 42);
      final state2 = StatusMeterGameState.initial(seed: 42);

      final event1 = engine.selectNextEvent(state1);
      final event2 = engine.selectNextEvent(state2);

      expect(event1.id, event2.id);
    });

    test('unlocks are triggered at the correct time', () {
      final engine = StatusMeterEngine(eventDefinitions: testEvents);
      var state = StatusMeterGameState.initial(seed: 1);

      // Simulate turns until minute 20
      for (var i = 0; i < 10; i++) {
        // 10 turns * 2 min/turn = 20 min
        state = engine.handleAction(state, 'event_1', StatusMeterAction.comply);
      }

      expect(state.minutesElapsed, 20);
      expect(state.isStressAsCurrencyUnlocked, isTrue);
      expect(state.isTrustInversionUnlocked, isFalse);

      // Simulate turns until minute 40
      for (var i = 0; i < 10; i++) {
        // 20 turns * 2 min/turn = 40 min
        state = engine.handleAction(state, 'event_1', StatusMeterAction.comply);
      }

      expect(state.minutesElapsed, 40);
      expect(state.isTrustInversionUnlocked, isTrue);
    });

    test('ending is triggered after 60 minutes', () {
      final engine = StatusMeterEngine(eventDefinitions: testEvents);
      var state = StatusMeterGameState.initial(seed: 1);

      // 30 turns * 2 min/turn = 60 min
      for (var i = 0; i < 30; i++) {
        state = engine.handleAction(state, 'event_2', StatusMeterAction.comply);
      }

      expect(state.minutesElapsed, 60);
      expect(state.isRunFinished, isTrue);
      expect(state.endingId, isNotNull);
      expect(state.endingSummary, isNotNull);
    });
  });
}
