import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/floating_data_generator.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/block_time_clock.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:leak_guard/widgets/drawer_menu.dart';
import 'package:leak_guard/widgets/horizontal_group_list.dart';
import 'package:leak_guard/widgets/panel.dart';
import 'package:leak_guard/widgets/water_block_button.dart';
import 'package:leak_guard/widgets/water_usage_arc.dart';
import 'package:leak_guard/widgets/graph_water_usage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _appData = AppData();
  int groupIndex = 0;

  void _handleGroupChange(int newIndex) {
    setState(() {
      groupIndex = newIndex;
    });
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > 0) {
      if (groupIndex > 0) {
        _handleGroupChange(groupIndex - 1);
      }
    } else {
      if (groupIndex < _appData.groups.length - 1) {
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

  void _refreshData() async {
    setState(() {
      _appData.loadData();
    });
  }

  void _onBack() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_appData.groups.isEmpty) {
      return Scaffold(
        backgroundColor: MyColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 78),
              Image.asset('assets/icons/logo.png', width: 150),
              const SizedBox(height: 20),
              Text(MyStrings.appName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 50)),
              const SizedBox(height: 20),
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: 5,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.createGroup,
                  ).then((_) => _refreshData());
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create your first group',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (kDebugMode)
                NeumorphicButton(
                  style: NeumorphicStyle(
                    depth: 5,
                    intensity: 0.8,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    GenerateTestDataButton(
                      onComplete: _refreshData,
                    ).generateData(context);
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.science_outlined),
                      const SizedBox(width: 8),
                      Text(
                        'Generate test data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_appData.groups.length - 1 < groupIndex) {
      groupIndex = _appData.groups.length - 1;
    }

    Group currentGroup = _appData.groups[groupIndex];

    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: DrawerMenu(
          onBack: _onBack,
        ),
        appBar: CustomNeumorphicAppBar(
          leadingIcon: const Icon(Icons.menu),
          onLeadingTap: _openDrawer,
          title: MyStrings.appName,
          trailingIcon: const Icon(Icons.refresh),
          onTrailingTap: _refreshData,
          bottomWidgets: [
            HorizontalGroupList(
              groups: _appData.groups,
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
                cacheExtent: 1000,
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
                              for (Group group in _appData.groups) {
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
                    child: GraphWaterUsage(
                      data: data['waterUsageData'],
                      maxHeight: 150,
                    ),
                    onTap: () {},
                  ),
                  Panel(
                    name: "Block time",
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: BlockTimeClock(
                        group: currentGroup,
                      ),
                    ),
                    onTap: () {},
                  ),
                  Panel(
                    name: "Leak probes",
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              NeumorphicIcon(
                                CustomIcons.probe,
                                size: 30,
                                style: NeumorphicStyle(
                                  color: MyColors.lightThemeFont,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  'Leak probes count: ${currentGroup.leakProbeNumber()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              NeumorphicIcon(
                                size: 30,
                                CustomIcons.battery_low,
                                style: NeumorphicStyle(
                                  color: MyColors.lightThemeFont,
                                ),
                              ),
                              SizedBox(
                                width: 1,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  "Low battery count: ${currentGroup.leakProbeLowBatteryNumber()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              NeumorphicIcon(
                                CustomIcons.leak,
                                size: 30,
                                style: NeumorphicStyle(
                                  color: MyColors.lightThemeFont,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  "Detected leaks count: ${currentGroup.detectedLeaksCount()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                  Panel(
                    name: "Central units",
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              NeumorphicIcon(
                                CustomIcons.central_unit,
                                size: 30,
                                style: NeumorphicStyle(
                                  color: MyColors.lightThemeFont,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  'Central units count: ${currentGroup.centralUnitsNumber()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              NeumorphicIcon(
                                Icons.signal_cellular_alt,
                                size: 30,
                                style: NeumorphicStyle(
                                  color: MyColors.lightThemeFont,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  'Connected central units: ${currentGroup.connectedCentralUnits()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              NeumorphicIcon(
                                Icons.lock_outline,
                                size: 30,
                                style: NeumorphicStyle(
                                  color: MyColors.lightThemeFont,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  'Locked central units: ${currentGroup.lockedCentralUnitsCount()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!),
                            ],
                          ),
                        ],
                      ),
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
  }
}
