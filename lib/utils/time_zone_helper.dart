import 'package:leak_guard/models/time_zone.dart';

class TimeZoneHelper {
  static final List<TimeZone> timeZones = [
    TimeZone.fromString("UTC [-11:00] Midway", 45),
    TimeZone.fromString("UTC [-10:00] Honolulu", 44),
    TimeZone.fromString("UTC [-09:00] Anchorage", 4),
    TimeZone.fromString("UTC [-08:00] Los Angeles", 9),
    TimeZone.fromString("UTC [-07:00] Denver", 7),
    TimeZone.fromString("UTC [-07:00] Phoenix", 13),
    TimeZone.fromString("UTC [-06:00] Chicago", 6),
    TimeZone.fromString("UTC [-06:00] Mexico City", 11),
    TimeZone.fromString("UTC [-06:00] Regina", 14),
    TimeZone.fromString("UTC [-05:00] Atlanta", 12),
    TimeZone.fromString("UTC [-04:00] Halifax", 8),
    TimeZone.fromString("UTC [-04:00] Manaus", 10),
    TimeZone.fromString("UTC [-03:30] St Johns", 17),
    TimeZone.fromString("UTC [-03:00] Belo Horizonte", 16),
    TimeZone.fromString("UTC [-03:00] Buenos Aires", 5),
    TimeZone.fromString("UTC [-03:00] Santiago", 15),
    TimeZone.fromString("UTC [+00:00] London", 40),
    TimeZone.fromString("UTC [+01:00] Warsaw", 37),
    TimeZone.fromString("UTC [+01:00] Brazzaville", 1),
    TimeZone.fromString("UTC [+02:00] Cairo", 0),
    TimeZone.fromString("UTC [+02:00] Harare", 2),
    TimeZone.fromString("UTC [+02:00] Helsinki", 38),
    TimeZone.fromString("UTC [+03:00] Ankara", 39),
    TimeZone.fromString("UTC [+03:00] Jerusalem", 21),
    TimeZone.fromString("UTC [+03:00] Kuwait", 25),
    TimeZone.fromString("UTC [+03:00] Moscow", 41),
    TimeZone.fromString("UTC [+03:00] Nairobi", 3),
    TimeZone.fromString("UTC [+03:30] Tehran", 28),
    TimeZone.fromString("UTC [+04:00] Dubai", 19),
    TimeZone.fromString("UTC [+05:00] Karachi", 22),
    TimeZone.fromString("UTC [+05:30] Ahmedabad", 24),
    TimeZone.fromString("UTC [+05:45] Katmandu", 23),
    TimeZone.fromString("UTC [+06:30] Rangoon", 30),
    TimeZone.fromString("UTC [+07:00] Bangkok", 18),
    TimeZone.fromString("UTC [+08:00] Beijing", 27),
    TimeZone.fromString("UTC [+08:00] Hong Kong", 20),
    TimeZone.fromString("UTC [+08:00] Perth", 35),
    TimeZone.fromString("UTC [+09:00] Nagoya", 29),
    TimeZone.fromString("UTC [+09:00] Seoul", 26),
    TimeZone.fromString("UTC [+09:30] Adelaide", 31),
    TimeZone.fromString("UTC [+09:30] Darwin", 33),
    TimeZone.fromString("UTC [+10:00] Brisbane", 32),
    TimeZone.fromString("UTC [+10:00] Guam", 43),
    TimeZone.fromString("UTC [+10:00] Hobart", 34),
    TimeZone.fromString("UTC [+10:00] Sydney", 36),
    TimeZone.fromString("UTC [+13:00] Auckland", 42),
  ];

  static TimeZone getCurrentTimeZone() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset.inMinutes / 60;

    return timeZones.firstWhere((tz) => tz.offset == offset,
        orElse: () => timeZones.firstWhere((tz) => tz.town == "Warsaw",
            orElse: () => timeZones.first));
  }

  static TimeZone getCurrentTimeZonebyId(int timezoneId) {
    return timeZones.firstWhere((tz) => tz.timeZoneId == timezoneId,
        orElse: () => timeZones.firstWhere((tz) => tz.town == "Warsaw",
            orElse: () => timeZones.first));
  }
}
