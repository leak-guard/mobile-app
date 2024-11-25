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
  int position = 0;
  BlockStatus status = BlockStatus.noBlocked;
  bool isTimeBlockSetted = false;
  List<int> blockedHours = [];
  List<CentralUnit> centralUnits = [];

  Group({required this.name});

  int centralUnitsNumber() => centralUnits.length;

  int centralUnitsLeaksNumber() => centralUnits.fold(
      0,
      (sum, unit) =>
          sum + unit.leakProbes.where((probe) => probe.leakDetected).length);

  int leakProbeNumber() =>
      centralUnits.fold(0, (sum, unit) => sum + unit.leakProbeNumber());

  int leakProbeLowBatteryNumber() => centralUnits.fold(
      0, (sum, unit) => sum + unit.leakProbeLowBatteryNumber());

  // Update block status based on central units
  void updateBlockStatus() {
    if (centralUnits.isEmpty) {
      status = BlockStatus.noBlocked;
      return;
    }

    bool allBlocked = centralUnits.every((unit) => unit.isBlocked);
    bool someBlocked = centralUnits.any((unit) => unit.isBlocked);

    if (allBlocked) {
      status = BlockStatus.allBlocked;
    } else if (someBlocked) {
      status = BlockStatus.someBlocked;
    } else {
      status = BlockStatus.noBlocked;
    }
  }

  void block() {
    for (var unit in centralUnits) {
      unit.isBlocked = true;
    }
    status = BlockStatus.allBlocked;
  }

  void unBlock() {
    for (var unit in centralUnits) {
      unit.isBlocked = false;
    }
    status = BlockStatus.noBlocked;
  }

  void blockHours(List<int> hours) {
    blockedHours = hours;
    isTimeBlockSetted = hours.isNotEmpty;
  }

  Future<double> flowRate() async {
    double total = 0.0;
    for (var unit in centralUnits) {
      final usage = await unit.getCurrentFlowRate();
      total += usage;
    }
    return total;
  }

  Future<double> todaysWaterUsage() async {
    double total = 0.0;
    for (var unit in centralUnits) {
      final usage = await unit.getTodaysWaterUsage();
      total += usage;
    }
    return total;
  }

  Future<double> yesterdayWaterUsage() async {
    double total = 0.0;
    for (var unit in centralUnits) {
      final usage = await unit.getYesterdayWaterUsage();
      total += usage;
    }
    return total;
  }

  Future<List<WaterUsageData>> getWaterUsageData(int hoursToFetch) async {
    final now = DateTime.now();
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);

    // Create initial list with zero usage
    List<WaterUsageData> result = [];
    for (int i = hoursToFetch - 1; i >= 0; i--) {
      final time = currentHour.subtract(Duration(hours: i));
      result.add(WaterUsageData(
        time.year,
        time.month,
        time.day,
        time.hour,
        time.minute,
        0.0,
      ));
    }

    // Sum up usage from all central units
    for (var unit in centralUnits) {
      final unitData = await unit.getWaterUsageData(hoursToFetch);
      for (int i = 0; i < hoursToFetch; i++) {
        result[i].usage += unitData[i].usage;
      }
    }

    return result;
  }
}
