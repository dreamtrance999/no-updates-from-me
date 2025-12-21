import 'engine/decision_engine.dart';
import 'engine/event.dart';
import 'engine/game_state.dart';

class GameController {
  final GameState state;
  final DecisionEngine engine;

  GameController(this.state, this.engine);

  Event? nextEvent(String channel) {
    return engine.pickEvent(state, channel);
  }

  List<String> choose(Event event, String choiceId) {
    final choice = event.choices.firstWhere((c) => c.id == choiceId);
    return engine.resolveChoice(state, event, choice);
  }
}
