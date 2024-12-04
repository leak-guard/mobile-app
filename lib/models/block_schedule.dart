class BlockSchedule {
  BlockDay sunday;
  BlockDay monday;
  BlockDay tuesday;
  BlockDay wednesday;
  BlockDay thursday;
  BlockDay friday;
  BlockDay saturday;

  BlockSchedule({
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  @override
  String toString() {
    String result = "Sunday:\n$sunday\n";
    result += "Monday:\n$monday\n";
    result += "Tuesday:\n$tuesday\n";
    result += "Wednesday:\n$wednesday\n";
    result += "Thursday:\n$thursday\n";
    result += "Friday:\n$friday\n";
    result += "Saturday:\n$saturday";
    return result;
  }
}

class BlockDay {
  bool enabled;
  List<bool> hours;

  BlockDay({required this.enabled, required this.hours});

  @override
  String toString() {
    return 'Enabled: $enabled\n$hours';
  }
}
