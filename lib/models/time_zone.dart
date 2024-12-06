class TimeZone {
  final int timeZoneId;
  final double offset;
  final String? town;

  const TimeZone({
    required this.timeZoneId,
    required this.offset,
    this.town,
  });

  @override
  String toString() {
    String offsetString = offset < 0 ? "-" : "+";
    if (offset.abs() < 10) offsetString += "0";
    offsetString += offset.abs().floor().toString();
    offsetString += ":";

    double minutes = (offset.abs() - offset.abs().floor()) * 60;
    offsetString +=
        minutes == 0 ? "00" : minutes.toStringAsFixed(0).padLeft(2, '0');

    return town != null ? "$offsetString $town" : offsetString;
  }

  static TimeZone fromString(String str, int id) {
    final pattern = RegExp(r'UTC \[([+-])(\d{2}):(\d{2})\] (.+)');
    final match = pattern.firstMatch(str);

    if (match != null) {
      final sign = match.group(1) == '-' ? -1 : 1;
      final hours = int.parse(match.group(2)!);
      final minutes = int.parse(match.group(3)!);
      final town = match.group(4);

      return TimeZone(
        timeZoneId: id,
        offset: sign * (hours + minutes / 60),
        town: town,
      );
    }

    throw const FormatException('Invalid timezone string format');
  }

  compareTo(TimeZone b) {
    return offset.compareTo(b.offset);
  }
}
