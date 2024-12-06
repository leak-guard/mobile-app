class WaterUsageData {
  final DateTime date;
  double usage;

  WaterUsageData(this.date, this.usage);

  @override
  String toString() {
    return "Date: $date, Usage: $usage";
  }
}
