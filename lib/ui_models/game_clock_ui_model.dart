class GameClockUiModel {
  final int day; // starts at 1
  final int minutesSinceMidnight; // 0..1439

  const GameClockUiModel({
    required this.day,
    required this.minutesSinceMidnight,
  });

  String get hhmm {
    final h = (minutesSinceMidnight ~/ 60).toString().padLeft(2, "0");
    final m = (minutesSinceMidnight % 60).toString().padLeft(2, "0");
    return "$h:$m";
  }

  String get weekday {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[(day - 1) % 7];
  }

  GameClockUiModel addMinutes(int delta) {
    final total = minutesSinceMidnight + delta;
    if (total >= 0 && total < 1440) {
      return GameClockUiModel(day: day, minutesSinceMidnight: total);
    }
    final dayDelta = total ~/ 1440;
    final newDay = day + dayDelta;
    final newMinutes = total % 1440;
    return GameClockUiModel(day: newDay, minutesSinceMidnight: newMinutes);
  }

  Map<String, dynamic> toJson() => {
        "day": day,
        "minutesSinceMidnight": minutesSinceMidnight,
      };

  static GameClockUiModel fromJson(Map<String, dynamic> json) {
    return GameClockUiModel(
      day: (json["day"] as num).toInt(),
      minutesSinceMidnight: (json["minutesSinceMidnight"] as num).toInt(),
    );
  }
}
