import "../persistence/game_database.dart";
import "../persistence/game_save.dart";

class GameRepository {
  final GameDatabase _db;

  const GameRepository(this._db);

  Future<void> save(GameSave save) => _db.saveJson(save.toJson());

  GameSave? load() {
    final json = _db.loadJson();
    if (json == null) return null;
    return GameSave.fromJson(json);
  }

  Future<void> reset() => _db.clear();
}
