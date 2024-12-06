class Flow {
  int? flowID;
  int? centralUnitID;
  num volume;
  DateTime date;

  Flow(
      {this.flowID,
      required this.centralUnitID,
      required this.volume,
      required this.date});

  int unixTime() {
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  String toString() {
    return 'Flow {volume: $volume, date: $date}';
  }
}
