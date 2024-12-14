import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/group_central_relation.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/custom_toast.dart';

class AppData {
  static final AppData _instance = AppData._internal();
  final _db = DatabaseService.instance;

  List<Group> groups = [];
  List<CentralUnit> centralUnits = [];
  List<LeakProbe> leakProbes = [];
  bool isLoaded = false;

  factory AppData() {
    return _instance;
  }

  AppData._internal();

  Future<void> loadData() async {
    final futures = await Future.wait([
      _db.getGroups(),
      _db.getCentralUnitsAndIDs(),
      _db.getAllGroupCentralRelations(),
      _db.getAllLeakProbes(),
    ]);

    groups = futures[0] as List<Group>;
    final centralsMap = futures[1] as Map<int, CentralUnit>;
    final relations = futures[2] as List<GroupCentralRelation>;
    leakProbes = futures[3] as List<LeakProbe>;

    centralUnits = centralsMap.values.toList();

    for (var group in groups) {
      group.centralUnits = relations
          .where((relation) => relation.groupId == group.groupdID)
          .map((relation) => centralsMap[relation.centralUnitId])
          .whereType<CentralUnit>()
          .toList();
    }

    for (var probe in leakProbes) {
      if (centralsMap.containsKey(probe.centralUnitID)) {
        centralsMap[probe.centralUnitID]!.leakProbes.add(probe);
      }
    }

    List<bool> fetchResults = await fetchDataFromApi();
    int successCount = fetchResults.fold(0, (previousValue, element) {
      if (element) {
        return previousValue + 1;
      }
      return previousValue;
    });

    for (int i = leakProbes.length - 1; i >= 0; i--) {
      bool toDelete = true;
      for (CentralUnit cu in centralUnits) {
        if (cu.leakProbes.contains(leakProbes[i])) {
          toDelete = false;
          break;
        }
      }
      if (toDelete) {
        await _db.deleteLeakProbe(leakProbes[i].leakProbeID!);
        leakProbes.removeAt(i);
      }
    }

    if (centralUnits.isNotEmpty) {
      CustomToast.toast(
          '$successCount of ${fetchResults.length} central units loaded');
    }

    for (var group in groups) {
      group.updateBlockStatus();
      if (group.centralUnits.isNotEmpty) {
        group.blockSchedule = group.centralUnits.first.blockSchedule;
      }
    }
    isLoaded = true;
  }

  Future<List<bool>> fetchDataFromApi() {
    List<Future<bool>> futures = [];
    for (var central in centralUnits) {
      futures.add(central.refreshData());
    }
    return Future.wait(futures).then((results) {
      return results;
    });
  }

  void clearData() {
    groups.clear();
    centralUnits.clear();
    isLoaded = false;
  }
}
