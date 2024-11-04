import 'dart:math';

class WaterUsageData {
  final int year;
  final int month;
  final int day;
  final int hour;
  final double usage = Random().nextDouble() * 100;

  WaterUsageData(
    this.year,
    this.month,
    this.day,
    this.hour,
  );
}
