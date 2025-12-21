import '../engine/actor.dart';

abstract class ChatItemUiModel {
  final String id;

  const ChatItemUiModel({required this.id});
}

class ChatMessageUiModel extends ChatItemUiModel {
  final Actor actor;
  final String message;
  final String timeLabel;

  const ChatMessageUiModel({
    required super.id,
    required this.actor,
    required this.message,
    required this.timeLabel,
  });

  @override
  String toString() => 'ChatMessage: "$message"';
}

class ChatDecisionUiModel extends ChatItemUiModel {
  final String prompt;
  final List<DecisionOptionUiModel> options;
  final bool isResolved;

  const ChatDecisionUiModel({
    required super.id,
    required this.prompt,
    required this.options,
    this.isResolved = false,
  });

  ChatDecisionUiModel copyWith({bool? isResolved}) {
    return ChatDecisionUiModel(
      id: id,
      prompt: prompt,
      options: options,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

class DecisionOptionUiModel {
  final String id;
  final String label;
  final String hint;
  final int timeJumpMinutes;
  final List<String> outcomes;

  const DecisionOptionUiModel({
    required this.id,
    required this.label,
    required this.hint,
    required this.timeJumpMinutes,
    required this.outcomes,
  });
}
