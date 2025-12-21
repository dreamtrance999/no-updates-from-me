class EventLine {
  final String? actorId;
  final String line;

  EventLine({this.actorId, required this.line});

  factory EventLine.fromJson(dynamic json) {
    if (json is String) {
      return EventLine(line: json);
    }
    if (json is Map<String, dynamic>) {
      return EventLine(
        actorId: json['actor'],
        line: json['line'],
      );
    }
    throw ArgumentError('Invalid EventLine format');
  }
}
