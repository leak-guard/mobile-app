class WaterUsageData {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  double usage;

  WaterUsageData(
      this.year, this.month, this.day, this.hour, this.minute, this.usage);

  String getHourKey() {
    return '$year-$month-$day-$hour';
  }
}
