import "dart:convert";

import "package:hive_flutter/hive_flutter.dart";

class GameDatabase {
  static const _boxName = "game_db";
  static const _saveKey = "save_blob";

  Box<String>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> saveJson(Map<String, dynamic> json) async {
    final box = _requireBox();
    await box.put(_saveKey, jsonEncode(json));
  }

  Map<String, dynamic>? loadJson() {
    final box = _requireBox();
    final raw = box.get(_saveKey);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  Future<void> clear() async {
    final box = _requireBox();
    await box.delete(_saveKey);
  }

  Box<String> _requireBox() {
    final box = _box;
    if (box == null) {
      throw StateError("GameDatabase not initialized. Call init().");
    }
    return box;
  }
}
