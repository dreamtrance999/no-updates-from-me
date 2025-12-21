sealed class ChatItemUiModel {
  const ChatItemUiModel();

  Map<String, dynamic> toJson();

  static ChatItemUiModel fromJson(Map<String, dynamic> json) {
    final type = json["type"] as String;
    return switch (type) {
      "message" => ChatMessageUiModel.fromJson(json),
      "decision" => ChatDecisionUiModel.fromJson(json),
      _ => throw StateError("Unknown ChatItemUiModel type: $type"),
    };
  }
}

class ChatMessageUiModel extends ChatItemUiModel {
  final String id;
  final String name; // "Emily" or "[SYSTEM]"
  final String message;
  final String timeLabel; // "09:43" etc
  final String? avatarAssetPath;

  const ChatMessageUiModel({
    required this.id,
    required this.name,
    required this.message,
    required this.timeLabel,
    this.avatarAssetPath,
  });

  @override
  Map<String, dynamic> toJson() => {
        "type": "message",
        "id": id,
        "name": name,
        "message": message,
        "timeLabel": timeLabel,
        "avatarAssetPath": avatarAssetPath,
      };

  static ChatMessageUiModel fromJson(Map<String, dynamic> json) {
    return ChatMessageUiModel(
      id: json["id"] as String,
      name: json["name"] as String,
      message: json["message"] as String,
      timeLabel: json["timeLabel"] as String,
      avatarAssetPath: json["avatarAssetPath"] as String?,
    );
  }
}

class ChatDecisionUiModel extends ChatItemUiModel {
  final String id;
  final String prompt;
  final bool isResolved;
  final List<DecisionOptionUiModel> options;

  const ChatDecisionUiModel({
    required this.id,
    required this.prompt,
    required this.isResolved,
    required this.options,
  });

  ChatDecisionUiModel copyWith({bool? isResolved}) => ChatDecisionUiModel(
        id: id,
        prompt: prompt,
        isResolved: isResolved ?? this.isResolved,
        options: options,
      );

  @override
  Map<String, dynamic> toJson() => {
        "type": "decision",
        "id": id,
        "prompt": prompt,
        "isResolved": isResolved,
        "options": options.map((o) => o.toJson()).toList(),
      };

  static ChatDecisionUiModel fromJson(Map<String, dynamic> json) {
    return ChatDecisionUiModel(
      id: json["id"] as String,
      prompt: json["prompt"] as String,
      isResolved: json["isResolved"] as bool,
      options: (json["options"] as List)
          .cast<Map>()
          .map((m) => DecisionOptionUiModel.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class DecisionOptionUiModel {
  final String id;
  final String label;
  final String hint; // "Safe", "Risky"
  final int timeJumpMinutes;
  final List<WeightedOutcomeUiModel> outcomes;

  const DecisionOptionUiModel({
    required this.id,
    required this.label,
    required this.hint,
    required this.timeJumpMinutes,
    required this.outcomes,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "hint": hint,
        "timeJumpMinutes": timeJumpMinutes,
        "outcomes": outcomes.map((o) => o.toJson()).toList(),
      };

  static DecisionOptionUiModel fromJson(Map<String, dynamic> json) {
    return DecisionOptionUiModel(
      id: json["id"] as String,
      label: json["label"] as String,
      hint: json["hint"] as String,
      timeJumpMinutes: (json["timeJumpMinutes"] as num).toInt(),
      outcomes: (json["outcomes"] as List)
          .cast<Map>()
          .map(
              (m) => WeightedOutcomeUiModel.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class WeightedOutcomeUiModel {
  final int weight;
  final List<ChatMessageUiModel> messagesToAppend;
  final int moraleDelta;
  final int stressDelta;

  const WeightedOutcomeUiModel({
    required this.weight,
    required this.messagesToAppend,
    this.moraleDelta = 0,
    this.stressDelta = 0,
  });

  Map<String, dynamic> toJson() => {
        "weight": weight,
        "messagesToAppend": messagesToAppend.map((m) => m.toJson()).toList(),
        "moraleDelta": moraleDelta,
        "stressDelta": stressDelta,
      };

  static WeightedOutcomeUiModel fromJson(Map<String, dynamic> json) {
    return WeightedOutcomeUiModel(
      weight: (json["weight"] as num).toInt(),
      moraleDelta: (json["moraleDelta"] as num?)?.toInt() ?? 0,
      stressDelta: (json["stressDelta"] as num?)?.toInt() ?? 0,
      messagesToAppend: (json["messagesToAppend"] as List)
          .cast<Map>()
          .map((m) => ChatMessageUiModel.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }
}
