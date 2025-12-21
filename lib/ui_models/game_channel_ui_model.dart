enum GameChannelKind { general, development, incidents, leadership, dm }

class GameChannelUiModel {
  final String id;
  final String title;
  final GameChannelKind kind;
  final bool isSelected;
  final int unreadCount;

  const GameChannelUiModel({
    required this.id,
    required this.title,
    required this.kind,
    required this.isSelected,
    required this.unreadCount,
  });

  GameChannelUiModel copyWith({
    bool? isSelected,
    int? unreadCount,
  }) {
    return GameChannelUiModel(
      id: id,
      title: title,
      kind: kind,
      isSelected: isSelected ?? this.isSelected,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "kind": kind.name,
        "isSelected": isSelected,
        "unreadCount": unreadCount,
      };

  static GameChannelUiModel fromJson(Map<String, dynamic> json) {
    return GameChannelUiModel(
      id: json["id"] as String,
      title: json["title"] as String,
      kind: GameChannelKind.values.firstWhere((e) => e.name == json["kind"]),
      isSelected: json["isSelected"] as bool,
      unreadCount: (json["unreadCount"] as num).toInt(),
    );
  }
}
