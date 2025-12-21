import '../repository/event_repository.dart';
import 'choice.dart';
import 'event.dart';
import 'game_state.dart';
import 'weighted_random.dart';

class DecisionEngine {
  final EventRepository repo;

  DecisionEngine(this.repo);

  Event? pickEvent(GameState state, String channel) {
    final candidates = repo.getByChannel(channel);

    bool isEligible(Event e) {
      if (!e.prereq.isMet(state)) {
        return false;
      }
      if (state.eventHistory.containsKey(e.id)) {
        if (e.oneTime) {
          return false; // Never repeat one-time events
        }
        final timeSince = state.time - state.eventHistory[e.id]!;
        if (timeSince < e.cooldown) {
          return false; // Event is on cooldown
        }
      }
      return true;
    }

    final normalEvents =
        candidates.where((e) => !e.isFiller && isEligible(e)).toList();

    if (normalEvents.isNotEmpty) {
      return weightedPick<Event>(
        normalEvents,
        (e) {
          final chaosBias = 1 + (state.chaos / 100);
          return (e.baseWeight * chaosBias).round();
        },
        state.rng,
      );
    }

    // If no normal events are available, fall back to filler events.
    final fillerEvents =
        candidates.where((e) => e.isFiller && isEligible(e)).toList();

    if (fillerEvents.isNotEmpty) {
      return weightedPick<Event>(
        fillerEvents,
        (e) => e.baseWeight,
        state.rng,
      );
    }

    return null; // Only if no events (normal or filler) are eligible
  }

  List<String> resolveChoice(GameState state, Event event, Choice choice) {
    state.time += choice.timeCost;
    state.eventHistory[event.id] = state.time;

    final outcome = weightedPick(
      choice.outcomes,
      (o) {
        final stressBias = 1 + (state.stress / 100);
        return (o.weight * stressBias).round();
      },
      state.rng,
    );

    outcome.apply(state);
    return outcome.messages;
  }
}
