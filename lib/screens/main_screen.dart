import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/group_central_relation.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/floating_data_generator.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/block_time_clock.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:leak_guard/widgets/drawer_menu.dart';
import 'package:leak_guard/widgets/horizontal_group_list.dart';
import 'package:leak_guard/widgets/panel.dart';
import 'package:leak_guard/widgets/water_block_button.dart';
import 'package:leak_guard/widgets/water_usage_arc.dart';
import 'package:leak_guard/widgets/water_usage_graph.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int groupIndex = 0;
  List<Group> groups = [];
  final _db = DatabaseService.instance;
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final futures = await Future.wait([
      _db.getGroups(),
      _db.getCentralUnitsAndIDs(),
      _db.getAllGroupCentralRelations(),
      _db.getAllLeakProbes(),
    ]);

    groups = futures[0] as List<Group>;
    final centrals = futures[1] as Map<int, CentralUnit>;
    final relations = futures[2] as List<GroupCentralRelation>;
    final leakProbes = futures[3] as List<LeakProbe>;

    for (var probe in leakProbes) {
      if (centrals.containsKey(probe.centralUnitID)) {
        centrals[probe.centralUnitID]!.leakProbes.add(probe);
      }
    }

    for (var group in groups) {
      group.centralUnits = relations
          .where((relation) => relation.groupId == group.groupdID)
          .map((relation) => centrals[relation.centralUnitId])
          .whereType<CentralUnit>()
          .toList();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadDataFuture = _loadData();
    });
  }

  void _handleGroupChange(int newIndex) {
    setState(() {
      groupIndex = newIndex;
    });
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > 0) {
      // Swipe w prawo
      if (groupIndex > 0) {
        _handleGroupChange(groupIndex - 1);
      }
    } else {
      // Swipe w lewo
      if (groupIndex < groups.length - 1) {
        _handleGroupChange(groupIndex + 1);
      }
    }
  }

  void _handleBlockButtonTap(Group group) {
    setState(() {
      if (group.status == BlockStatus.noBlocked) {
        group.block();
      } else {
        group.unBlock();
      }
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: MyColors.background,
            body: const Center(child: SizedBox()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: MyColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (groups.isEmpty) {
          return Scaffold(
            backgroundColor: MyColors.background,
            body: Center(
              child: Text('No groups found'),
            ),
            floatingActionButton: GenerateTestDataButton(
              onComplete: _refreshData,
            ),
          );
        }

        Group currentGroup = groups[groupIndex];

        return GestureDetector(
          onHorizontalDragEnd: _handleSwipe,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: DrawerMenu(groups: groups),
            appBar: CustomNeumorphicAppBar(
              leadingIcon: const Icon(Icons.menu),
              onLeadingTap: _openDrawer,
              title: MyStrings.appName,
              trailingIcon: const Icon(Icons.refresh),
              onTrailingTap: _refreshData,
              bottomWidgets: [
                HorizontalGroupList(
                  groups: groups,
                  selectedIndex: groupIndex,
                  onIndexChanged: _handleGroupChange,
                ),
              ],
              height: 120,
            ),
            backgroundColor: MyColors.background,
            body: FutureBuilder<Map<String, dynamic>>(
              future: Future.wait([
                currentGroup.todaysWaterUsage(),
                currentGroup.yesterdayWaterUsage(),
                currentGroup.flowRate(),
                currentGroup.getWaterUsageData(12),
              ]).then((results) => {
                    'todaysUsage': results[0],
                    'maxUsage': results[1],
                    'flowRate': results[2],
                    'waterUsageData': results[3],
                  }),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                return BlurredTopEdge(
                  height: 20,
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: WaterUsageArc(
                              currentUsage: data['todaysUsage'],
                              maxUsage: data['maxUsage'],
                              flowRate: data['flowRate'],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                            child: WaterBlockButton(
                              group: currentGroup,
                              handleButtonPress: () {
                                _handleBlockButtonTap(currentGroup);
                                setState(() {
                                  for (Group group in groups) {
                                    group.updateBlockStatus();
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Panel(
                        name: "Water usage",
                        child: WaterUsageChart(
                          data: data['waterUsageData'],
                          maxHeight: 150,
                        ),
                        onTap: () {},
                      ),
                      Panel(
                        name: "Block time",
                        child: BlockTimeClock(
                          group: currentGroup,
                        ),
                        onTap: () {},
                      ),
                      Panel(
                        name: "Leak probes",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 70,
                                    child: Center(
                                      child: NeumorphicIcon(
                                        CustomIcons.leak_probe,
                                        size: 80,
                                        style: NeumorphicStyle(
                                          color: MyColors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    currentGroup.leakProbeNumber().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: MyColors.blue,
                                          fontSize: 50,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 80,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                    child: Center(
                                      child: NeumorphicIcon(
                                        CustomIcons.battery_low,
                                        size: 50,
                                        style: NeumorphicStyle(
                                          color: MyColors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  currentGroup
                                      .leakProbeLowBatteryNumber()
                                      .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: MyColors.blue,
                                        fontSize: 50,
                                      ),
                                ),
                              ],
                            )
                          ],
                        ),
                        onTap: () {},
                      ),
                      Panel(
                        name: "Central units",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 70,
                                  child: Center(
                                    child: NeumorphicIcon(
                                      CustomIcons.central_unit,
                                      size: 70,
                                      style: NeumorphicStyle(
                                        color: MyColors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  currentGroup.centralUnitsNumber().toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: MyColors.blue,
                                        fontSize: 50,
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 80,
                                  child: Center(
                                    child: NeumorphicIcon(
                                      CustomIcons.broken_pipe,
                                      size: 50,
                                      style: NeumorphicStyle(
                                        color: MyColors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  currentGroup
                                      .centralUnitsLeaksNumber()
                                      .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: MyColors.blue,
                                        fontSize: 50,
                                      ),
                                ),
                              ],
                            )
                          ],
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
