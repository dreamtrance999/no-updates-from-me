import "../ui_models/chat_item_ui_model.dart";
import "../ui_models/game_channel_ui_model.dart";
import "../ui_models/game_clock_ui_model.dart";

class GameSave {
  final GameClockUiModel clock;
  final List<GameChannelUiModel> channels;

  /// chat items by channelId
  final Map<String, List<ChatItemUiModel>> chatByChannel;

  final int morale;
  final int stress;

  const GameSave({
    required this.clock,
    required this.channels,
    required this.chatByChannel,
    required this.morale,
    required this.stress,
  });

  Map<String, dynamic> toJson() => {
        "clock": clock.toJson(),
        "channels": channels.map((c) => c.toJson()).toList(),
        "chatByChannel": chatByChannel.map(
          (k, v) => MapEntry(k, v.map((i) => i.toJson()).toList()),
        ),
        "morale": morale,
        "stress": stress,
      };

  static GameSave fromJson(Map<String, dynamic> json) {
    final clock = GameClockUiModel.fromJson(
        (json["clock"] as Map).cast<String, dynamic>());

    final channels = (json["channels"] as List)
        .cast<Map>()
        .map((m) => GameChannelUiModel.fromJson(m.cast<String, dynamic>()))
        .toList();

    final chatByChannelRaw =
        (json["chatByChannel"] as Map).cast<String, dynamic>();
    final chatByChannel = <String, List<ChatItemUiModel>>{};
    for (final entry in chatByChannelRaw.entries) {
      final list = (entry.value as List)
          .cast<Map>()
          .map((m) => ChatItemUiModel.fromJson(m.cast<String, dynamic>()))
          .toList();
      chatByChannel[entry.key] = list;
    }

    return GameSave(
      clock: clock,
      channels: channels,
      chatByChannel: chatByChannel,
      morale: (json["morale"] as num).toInt(),
      stress: (json["stress"] as num).toInt(),
    );
  }
}
