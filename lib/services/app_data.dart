import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/group_central_relation.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/services/database_service.dart';

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

  //TODO: Optimise loading data from the database via group transaction

  Future<void> loadData() async {
    // await Future.delayed(const Duration(seconds: 2));
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

    for (var probe in leakProbes) {
      if (centralsMap.containsKey(probe.centralUnitID)) {
        centralsMap[probe.centralUnitID]!.leakProbes.add(probe);
      }
    }

    for (var group in groups) {
      group.centralUnits = relations
          .where((relation) => relation.groupId == group.groupdID)
          .map((relation) => centralsMap[relation.centralUnitId])
          .whereType<CentralUnit>()
          .toList();
    }

    await fetchDataFromApi();

    isLoaded = true;
  }

  //TODO: Implement fetching data from API:
  // - Fetch MAC address for each central unit - check if it's online
  // - Fetch leak probe data for each central unit
  // - Fetch water usage data for each central unit
  // - Fetch blockStatus for each central unit
  // - Fetch block schedule for each central unit
  // - Fetch Probes data for each central unit

  Future<void> fetchDataFromApi() async {
    List<Future<bool>> futures = [];
    for (var central in centralUnits) {
      futures.add(central.refreshData());
    }
    await Future.wait(futures);
  }

  void clearData() {
    groups.clear();
    centralUnits.clear();
    isLoaded = false;
  }
}
