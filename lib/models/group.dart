import 'package:leak_guard/models/block_schedule.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/photographable.dart';
import 'package:leak_guard/models/water_usage_data.dart';

class BlockStatus {
  static const noBlocked = BlockStatus._(0);
  static const allBlocked = BlockStatus._(1);
  static const someBlocked = BlockStatus._(2);

  final int value;
  const BlockStatus._(this.value);
}

class Group implements Photographable {
  int? groupdID;
  String name;
  int position = 0;
  String? imagePath;
  String? description;
  BlockStatus status = BlockStatus.noBlocked;
  List<CentralUnit> centralUnits = [];
  BlockSchedule blockSchedule = BlockSchedule.defaultSchedule();

  Group({required this.name});

  get leakProbes => centralUnits.fold<List<dynamic>>([], (acc, unit) {
        acc.addAll(unit.leakProbes);
        return acc;
      });

  int centralUnitsNumber() => centralUnits.length;

  int detectedLeaksCount() =>
      centralUnits.fold(0, (sum, unit) => sum + unit.detectedLeaksCount());

  int leakProbeNumber() =>
      centralUnits.fold(0, (sum, unit) => sum + unit.leakProbesCount());

  int leakProbeLowBatteryNumber() => centralUnits.fold(
      0, (sum, unit) => sum + unit.leakProbeLowBatteryCount());

  int connectedCentralUnits() {
    return centralUnits.where((unit) => unit.isOnline).length;
  }

  int lockedCentralUnitsCount() =>
      centralUnits.fold(0, (sum, unit) => sum + (unit.isBlocked ? 1 : 0));

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

  double flowRate() {
    double total = 0.0;
    for (var unit in centralUnits) {
      total += unit.flowRate;
    }
    return total;
  }

  Future<double> todaysWaterUsage() async {
    double total = 0.0;
    List<Future<double?>> futures = [];

    for (var unit in centralUnits) {
      futures.add(unit.getTodaysWaterUsage());
    }

    return Future.wait(futures).then((value) {
      for (var usage in value) {
        total += usage ?? 0.0;
      }
      return total;
    });
  }

  Future<double> yesterdayWaterUsage() async {
    double total = 0.0;
    List<Future<double?>> futures = [];

    for (var unit in centralUnits) {
      futures.add(unit.getYesterdayWaterUsage());
    }

    return Future.wait(futures).then((value) {
      for (var usage in value) {
        total += usage ?? 0.0;
      }
      return total;
    });
  }

  Future<List<WaterUsageData>> getWaterUsageDataThisHour(int portions) async {
    final now = DateTime.now();
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);

    List<WaterUsageData> result = [];
    for (int i = 0; i < portions; i++) {
      final time = currentHour.add(Duration(minutes: 60 * i ~/ portions));
      result.add(WaterUsageData(
        time,
        0.0,
      ));
    }

    List<Future<List<WaterUsageData>>> futures = [];
    for (var unit in centralUnits) {
      futures.add(unit.getWaterUsageDataThisHour(portions));
    }

    return Future.wait(futures).then((value) {
      for (var data in value) {
        for (int i = 0; i < portions; i++) {
          result[i].usage += data[i].usage;
        }
      }
      return result;
    });
  }

  Future<List<WaterUsageData>> getWaterUsageDataThisDay(int portions) async {
    final now = DateTime.now();
    final currentDay = DateTime(now.year, now.month, now.day);

    List<WaterUsageData> result = [];
    for (int i = 0; i < portions; i++) {
      final time = currentDay.add(Duration(hours: 24 * i ~/ portions));
      result.add(WaterUsageData(
        time,
        0.0,
      ));
    }

    List<Future<List<WaterUsageData>>> futures = [];
    for (var unit in centralUnits) {
      futures.add(unit.getWaterUsageDataThisDay(portions));
    }

    return Future.wait(futures).then((value) {
      for (var data in value) {
        for (int i = 0; i < portions; i++) {
          result[i].usage += data[i].usage;
        }
      }
      return result;
    });
  }

  Future<List<WaterUsageData>> getWaterUsageData(int hoursToFetch) async {
    final now = DateTime.now();
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);

    List<WaterUsageData> result = [];
    for (int i = hoursToFetch - 1; i >= 0; i--) {
      final time = currentHour.subtract(Duration(hours: i));
      result.add(WaterUsageData(
        time,
        0.0,
      ));
    }

    List<Future<List<WaterUsageData>>> futures = [];
    for (var unit in centralUnits) {
      futures.add(unit.getWaterUsageData(hoursToFetch));
    }

    return Future.wait(futures).then((value) {
      for (var data in value) {
        for (int i = 0; i < hoursToFetch; i++) {
          result[i].usage += data[i].usage;
        }
      }
      return result;
    });
  }

  @override
  String toString() {
    return 'Group{id: $groupdID, name: $name, position: $position, imagePath: $imagePath, description: $description';
  }

  @override
  String? getPhoto() => imagePath;

  @override
  void setPhoto(String? path) {
    imagePath = path;
  }

  Future<bool> refreshData() async {
    //TODO: Refresh
    // current flow - DONE via main screen refresh
    // todays usgae - DONE via main screen refresh
    // block status
    // new flows info (get from api and to database)
    // probe status

    List<Future<bool>> futures = [];
    for (var unit in centralUnits) {
      futures.add(unit.refreshBlockStatus());
    }
    final result = await Future.wait(futures);
    updateBlockStatus();
    if (result.contains(false)) {
      return false;
    }
    return true;
  }

  Future<bool> sendBlockSchedule() {
    List<Future<void>> futures = [];
    for (var central in centralUnits) {
      futures.add(central.sendBlockSchedule(blockSchedule));
    }
    return Future.wait(futures).then((value) {
      return !value.contains(false);
    });
  }

  Future refreshFlowAndTodaysUsage() async {
    List<Future<bool>> futures = [];
    for (var unit in centralUnits) {
      futures.add(unit.refreshFlowAndTodaysUsage());
    }
    return Future.wait(futures);
  }
}
