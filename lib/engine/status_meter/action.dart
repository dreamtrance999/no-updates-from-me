/// Represents the five possible actions a player can take in response to an alert.
enum StatusMeterAction {
  comply,
  deflect,
  escalate,
  align,
  withdraw;

  String get label {
    switch (this) {
      case StatusMeterAction.comply:
        return 'Comply';
      case StatusMeterAction.deflect:
        return 'Deflect';
      case StatusMeterAction.escalate:
        return 'Escalate';
      case StatusMeterAction.align:
        return 'Align';
      case StatusMeterAction.withdraw:
        return 'Withdraw';
    }
  }

  static StatusMeterAction fromString(String value) {
    return StatusMeterAction.values.firstWhere((e) => e.name == value);
  }
}
