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

  BlockSchedule.defaultSchedule()
      : sunday = BlockDay.defaultDay(),
        monday = BlockDay.defaultDay(),
        tuesday = BlockDay.defaultDay(),
        wednesday = BlockDay.defaultDay(),
        thursday = BlockDay.defaultDay(),
        friday = BlockDay.defaultDay(),
        saturday = BlockDay.defaultDay();

  void toggleBlockAll(bool value) {
    sunday.enabled = value;
    monday.enabled = value;
    tuesday.enabled = value;
    wednesday.enabled = value;
    thursday.enabled = value;
    friday.enabled = value;
    saturday.enabled = value;
  }

  void applyBlockScheduleToAllDays(BlockDay day) {
    sunday.hours = day.hours;
    monday.hours = day.hours;
    tuesday.hours = day.hours;
    wednesday.hours = day.hours;
    thursday.hours = day.hours;
    friday.hours = day.hours;
    saturday.hours = day.hours;
  }

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

  Map<String, dynamic> toJson() {
    return {
      'sunday': {
        'enabled': sunday.enabled,
        'hours': sunday.hours,
      },
      'monday': {
        'enabled': monday.enabled,
        'hours': monday.hours,
      },
      'tuesday': {
        'enabled': tuesday.enabled,
        'hours': tuesday.hours,
      },
      'wednesday': {
        'enabled': wednesday.enabled,
        'hours': wednesday.hours,
      },
      'thursday': {
        'enabled': thursday.enabled,
        'hours': thursday.hours,
      },
      'friday': {
        'enabled': friday.enabled,
        'hours': friday.hours,
      },
      'saturday': {
        'enabled': saturday.enabled,
        'hours': saturday.hours,
      },
    };
  }
}

class BlockDay {
  bool enabled;
  List<bool> hours;

  BlockDay({required this.enabled, required this.hours});

  BlockDay.defaultDay()
      : enabled = false,
        hours = List.generate(24, (index) => false);

  @override
  String toString() {
    return 'Enabled: $enabled\n$hours';
  }
}

enum BlockDayEnum {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  all,
}
