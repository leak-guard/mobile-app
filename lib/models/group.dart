import 'dart:math';

import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/water_usage_data.dart';

class BlockStatus {
  static const noBlocked = BlockStatus._(0);
  static const allBlocked = BlockStatus._(1);
  static const someBlocked = BlockStatus._(2);

  final int value;
  const BlockStatus._(this.value);
}

class Group {
  int? groupdID;
  String name;
  BlockStatus status = BlockStatus.noBlocked;
  bool isTimeBlockSetted = false;
  List<int> blockedHours = [];
  List<CentralUnit> centralUnits = [];

  Group({required this.name});

  void block() {
    status = BlockStatus.allBlocked;
  }

  void unBlock() {
    status = BlockStatus.noBlocked;
  }

  double todaysWaterUsage() {
    return 16;
  }

  double yesterdayWaterUsage() {
    return 32;
  }

  double actWaterUsage() {
    return 2.5;
  }

  List<WaterUsageData> getWaterUsageData(int lastHours) {
    List<WaterUsageData> waterUsageData = [
      WaterUsageData(2021, 10, 1, 0),
      WaterUsageData(2021, 10, 1, 1),
      WaterUsageData(2021, 10, 1, 2),
      WaterUsageData(2021, 10, 1, 3),
      WaterUsageData(2021, 10, 1, 4),
      WaterUsageData(2021, 10, 1, 5),
      WaterUsageData(2021, 10, 1, 6),
      WaterUsageData(2021, 10, 1, 7),
      WaterUsageData(2021, 10, 1, 8),
      WaterUsageData(2021, 10, 1, 9),
      WaterUsageData(2021, 10, 1, 10),
      WaterUsageData(2021, 10, 1, 11),
      WaterUsageData(2021, 10, 1, 12),
      WaterUsageData(2021, 10, 1, 13),
      WaterUsageData(2021, 10, 1, 14),
      WaterUsageData(2021, 10, 1, 15),
      WaterUsageData(2021, 10, 1, 16),
      WaterUsageData(2021, 10, 1, 17),
      WaterUsageData(2021, 10, 1, 18),
      WaterUsageData(2021, 10, 1, 19),
      WaterUsageData(2021, 10, 1, 20),
      WaterUsageData(2021, 10, 1, 21),
      WaterUsageData(2021, 10, 1, 22),
      WaterUsageData(2021, 10, 1, 23),
    ];
    return waterUsageData.sublist(waterUsageData.length - lastHours);
  }

  void blockHours(List<int> hours) {
    print('Block for hours: $hours');
    blockedHours = hours;
  }

  int centralUnitsNumber() {
    return Random().nextInt(10) + 1;
  }

  int centralUnitsLeaksNumber() {
    return Random().nextInt(10) + 1;
  }

  int leakProbeNumber() {
    return Random().nextInt(10) + 1;
  }

  int leakProbeLowBatteryNumber() {
    return Random().nextInt(10) + 1;
  }

  double todaysUsage() {
    return Random().nextDouble() * 1100;
  }

  double maxUsage() {
    return 1000;
  }

  double flowRate() {
    if (status == BlockStatus.allBlocked) {
      return 0;
    }
    return Random().nextDouble() * 10;
  }
}
