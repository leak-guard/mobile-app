import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/floating_data_generator.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/block_time_clock.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
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
    // Pobierz grupy
    groups = await _db.getGroups();

    // Załaduj dane dla każdej grupy
    for (var group in groups) {
      await group.loadCentralUnits();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
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
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: NeumorphicAppBar(
                padding: 0,
                titleSpacing: 0,
                actionSpacing: 0,
                centerTitle: true,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          NeumorphicButton(
                            padding: EdgeInsets.all(8),
                            minDistance: -3,
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(10)),
                              depth: 5,
                            ),
                            onPressed: () {},
                            child: Icon(Icons.menu),
                          ),
                          Text(
                            MyStrings.appName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          NeumorphicButton(
                            padding: EdgeInsets.all(8),
                            minDistance: -3,
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(10)),
                              depth: 5,
                            ),
                            onPressed: _refreshData,
                            child: Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                    HorizontalGroupList(
                      groups: groups,
                      selectedIndex: groupIndex,
                      onIndexChanged: _handleGroupChange,
                    )
                  ],
                ),
              ),
            ),
            backgroundColor: MyColors.background,
            body: BlurredTopEdge(
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
                        child: FutureBuilder<List<double>>(
                          future: Future.wait([
                            currentGroup.todaysWaterUsage(),
                            currentGroup.yesterdayWaterUsage(),
                            currentGroup.flowRate(),
                          ]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return WaterUsageArc(
                              currentUsage: snapshot.data![0],
                              maxUsage: snapshot.data![1],
                              flowRate: snapshot.data![2],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                        child: WaterBlockButton(
                          group: currentGroup,
                          handleButtonPress: () =>
                              _handleBlockButtonTap(currentGroup),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Panel(
                    name: "Water usage",
                    child: FutureBuilder<List<WaterUsageData>>(
                      future: currentGroup.getWaterUsageData(12),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                            height: 150,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return WaterUsageChart(
                          data: snapshot.data!,
                          maxHeight: 150,
                        );
                      },
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
                                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
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
                              currentGroup.centralUnitsLeaksNumber().toString(),
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
            ),
          ),
        );
      },
    );
  }
}
