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

    final eligible = candidates.where((e) {
      if (!e.prereq.isMet(state)) {
        return false;
      }
      if (state.eventHistory.containsKey(e.id)) {
        final timeSince = state.time - state.eventHistory[e.id]!;
        if (timeSince < e.cooldown) {
          return false;
        }
      }
      return true;
    }).toList();

    if (eligible.isEmpty) {
      return null;
    }

    return weightedPick<Event>(
      eligible,
      (e) {
        final chaosBias = 1 + (state.chaos / 100);
        return (e.baseWeight * chaosBias).round();
      },
      state.rng,
    );
  }

  List<String> resolveChoice(GameState state, Event event, Choice choice) {
    state.time += choice.timeCost;
    state.eventHistory[event.id] = state.time;

    final outcome = weightedPick(
      choice.outcomes,
      (o) {
        final chaosBias = 1 + (state.chaos / 100);
        return (o.weight * chaosBias).round();
      },
      state.rng,
    );

    outcome.apply(state);
    return outcome.messages;
  }
}
