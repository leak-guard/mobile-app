import 'package:leak_guard/models/water_usage_data.dart';

class BlockStatus {
  static const noBlocked = BlockStatus._(0);
  static const allBlocked = BlockStatus._(1);
  static const someBlocked = BlockStatus._(2);

  final int value;
  const BlockStatus._(this.value);
}

class Group {
  String name;
  BlockStatus status = BlockStatus.noBlocked;

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
      WaterUsageData(2021, 10, 1, 0, 6),
      WaterUsageData(2021, 10, 1, 1, 1),
      WaterUsageData(2021, 10, 1, 2, 3),
      WaterUsageData(2021, 10, 1, 3, 1),
      WaterUsageData(2021, 10, 1, 4, 2),
      WaterUsageData(2021, 10, 1, 5, 3),
      WaterUsageData(2021, 10, 1, 6, 6),
      WaterUsageData(2021, 10, 1, 7, 3),
      WaterUsageData(2021, 10, 1, 8, 4),
      WaterUsageData(2021, 10, 1, 9, 5),
      WaterUsageData(2021, 10, 1, 10, 10),
      WaterUsageData(2021, 10, 1, 11, 5),
      WaterUsageData(2021, 10, 1, 12, 4),
      WaterUsageData(2021, 10, 1, 13, 3),
      WaterUsageData(2021, 10, 1, 14, 2),
      WaterUsageData(2021, 10, 1, 15, 1),
      WaterUsageData(2021, 10, 1, 16, 0),
      WaterUsageData(2021, 10, 1, 17, 1),
      WaterUsageData(2021, 10, 1, 18, 2),
      WaterUsageData(2021, 10, 1, 19, 3),
      WaterUsageData(2021, 10, 1, 20, 4),
      WaterUsageData(2021, 10, 1, 21, 5.0),
      WaterUsageData(2021, 10, 1, 22, 7.5),
      WaterUsageData(2021, 10, 1, 23, 2.5),
    ];
    return waterUsageData.sublist(waterUsageData.length - lastHours);
  }
}
