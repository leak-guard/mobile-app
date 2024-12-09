import 'dart:async';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/block_schedule.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/water_usage_data.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/services/shared_preferences.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/block_clock_widget.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/custom_drawer.dart';
import 'package:leak_guard/widgets/horizontal_list_widget.dart';
import 'package:leak_guard/widgets/loading_widget.dart';
import 'package:leak_guard/widgets/panel_widget.dart';
import 'package:leak_guard/widgets/water_block_widget.dart';
import 'package:leak_guard/widgets/water_usage_arc_widget.dart';
import 'package:leak_guard/widgets/graph_water_usage_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _appData = AppData();
  final _networkService = NetworkService();
  final _prefs = PreferencesService.I;
  int groupIndex = 0;
  bool _isLoading = false;
  bool _swipeLoading = false;

  late Timer timer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void autoRefresh() {
    setState(() {});
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => setState(() {}),
    );
  }

  void cancelAutoRefresh() {
    setState(() {
      timer.cancel();
    });
  }

  void _handleGroupChange(int newIndex) {
    setState(() {
      _swipeLoading = true;
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

  Future<List<bool>> _handleBlockButtonTap(Group group) async {
    setState(() {
      _isLoading = true;
    });

    if (group.status == BlockStatus.noBlocked) {
      return group.toggleBlock(true);
    } else {
      return group.toggleBlock(false);
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _refreshDataRefreshIndicator(Group group) async {
    if (mounted) {
      if (await group.refreshData()) {
        setState(() {
          for (Group group in _appData.groups) {
            group.updateBlockStatus();
          }
        });
      } else {
        setState(() {
          CustomToast.toast("Failed to refresh data");
        });
      }
    }
  }

  Future<void> _refreshDataForCentrals(Group group) async {
    setState(() {
      _isLoading = true;
    });
    if (mounted) {
      if (await group.refreshData()) {
        setState(() {
          _isLoading = false;
          for (Group group in _appData.groups) {
            group.updateBlockStatus();
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          CustomToast.toast("Failed to refresh data");
        });
      }
    }
  }

  void _onBack() {
    setState(() {});
  }

  Widget _buildScreen(Map<String, dynamic> data, Group currentGroup) {
    BlockDayEnum currentDay;
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.sunday) {
      currentDay = BlockDayEnum.sunday;
    } else if (now.weekday == DateTime.monday) {
      currentDay = BlockDayEnum.monday;
    } else if (now.weekday == DateTime.tuesday) {
      currentDay = BlockDayEnum.tuesday;
    } else if (now.weekday == DateTime.wednesday) {
      currentDay = BlockDayEnum.wednesday;
    } else if (now.weekday == DateTime.thursday) {
      currentDay = BlockDayEnum.thursday;
    } else if (now.weekday == DateTime.friday) {
      currentDay = BlockDayEnum.friday;
    } else {
      currentDay = BlockDayEnum.saturday;
    }

    List<WaterUsageData> waterUsageData =
        data['waterUsageData'] as List<WaterUsageData>;

    return BlurredTopWidget(
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
                child: WaterUsageArcWidget(
                  currentUsage: data['todaysUsage'],
                  maxUsage: data['maxUsage'],
                  flowRate: data['flowRate'],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: WaterBlockWidget(
                  group: currentGroup,
                  handleButtonPress: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _handleBlockButtonTap(currentGroup).then((result) {
                      setState(() {
                        _isLoading = false;
                        if (result.contains(false)) {
                          int blockedCount = 0;
                          for (bool b in result) {
                            if (!b) {
                              blockedCount++;
                            }
                          }
                          CustomToast.toast(
                              "Failed to block $blockedCount central units");
                        }
                        for (Group group in _appData.groups) {
                          group.updateBlockStatus();
                        }
                      });
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PanelWidget(
            name: "Water usage",
            child: GraphWaterUsageWidget(
              labels:
                  waterUsageData.map((e) => e.date.hour.toString()).toList(),
              data: waterUsageData,
              maxHeight: 150,
            ),
            onTap: () {
              Navigator.pushNamed(context, Routes.waterUsage,
                      arguments: WaterUsageScreenArguments(currentGroup))
                  .then((_) {
                setState(() {});
              });
            },
          ),
          PanelWidget(
            name: "Block time",
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: BlockClockWidget(
                group: currentGroup,
                targetDay: currentDay,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, Routes.blockSchedule,
                      arguments: BlockScheduleScreenArguments(currentGroup))
                  .then((_) {
                setState(() {});
              });
            },
          ),
          PanelWidget(
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
                          style: Theme.of(context).textTheme.displaySmall!),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      NeumorphicIcon(
                        size: 30,
                        CustomIcons.betteryLow,
                        style: NeumorphicStyle(
                          color: MyColors.lightThemeFont,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          "Low battery count: ${currentGroup.leakProbeLowBatteryNumber()}",
                          style: Theme.of(context).textTheme.displaySmall!),
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
                          style: Theme.of(context).textTheme.displaySmall!),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.groupLeakProbes,
                arguments: GroupLeakProbesScreenArguments(
                  currentGroup,
                ),
              ).then((_) {
                setState(() {});
              });
            },
          ),
          PanelWidget(
            name: "Central units",
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      NeumorphicIcon(
                        CustomIcons.centralUnit,
                        size: 30,
                        style: NeumorphicStyle(
                          color: MyColors.lightThemeFont,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          'Central units count: ${currentGroup.centralUnitsNumber()}',
                          style: Theme.of(context).textTheme.displaySmall!),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      NeumorphicIcon(
                        Icons.wifi,
                        size: 30,
                        style: NeumorphicStyle(
                          color: MyColors.lightThemeFont,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          'Connected central units: ${currentGroup.connectedCentralUnits()}',
                          style: Theme.of(context).textTheme.displaySmall!),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      NeumorphicIcon(
                        Icons.lock,
                        size: 30,
                        style: NeumorphicStyle(
                          color: MyColors.lightThemeFont,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          'Locked central units: ${currentGroup.lockedCentralUnitsCount()}',
                          style: Theme.of(context).textTheme.displaySmall!),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.groupCentralUnits,
                arguments: GroupCentralUnitsScreenArguments(
                  currentGroup,
                ),
              ).then((_) {
                setState(() {
                  for (Group group in _appData.groups) {
                    group.updateBlockStatus();
                  }
                });
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String addLabel =
        _prefs.isFirstTime ? 'Add your first device' : 'Add your device';

    if (_appData.centralUnits.isNotEmpty) {
      addLabel = 'Create a group';
    }

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
                onPressed: () async {
                  if (_appData.centralUnits.isNotEmpty) {
                    Navigator.pushNamed(context, Routes.createGroup).then((_) {
                      setState(() {});
                    });
                    return;
                  }

                  await _networkService.getCurrentWifiName();
                  await _prefs.setFirstTime(false);
                  Permission.locationWhenInUse.serviceStatus.isEnabled
                      .then((isEnable) {
                    if (!isEnable) {
                      CustomToast.toast(
                          'Please turn on location on your phone');
                    }
                  });

                  if ((_networkService.currentWifiName ?? "") ==
                      "LeakGuardConfig") {
                    CentralUnit newCentral = CentralUnit(
                      name: "",
                      addressIP: "192.168.4.1",
                      addressMAC: '',
                      password: '',
                      isValveNO: true,
                      impulsesPerLiter: 477,
                      timezoneId: 37,
                      isRegistered: false,
                      isDeleted: false,
                      hardwareID: "",
                    );
                    if (mounted) {
                      Navigator.pushNamed(
                        // ignore: use_build_context_synchronously
                        context,
                        Routes.createCentralUnit,
                        arguments: CreateCentralScreenArguments(newCentral),
                      ).then((_) {
                        _networkService.startServiceDiscovery();
                        setState(() {});
                      });

                      CustomToast.toast("Connected to LeakGuardConfig!");
                      return;
                    }
                  }

                  Navigator.pushNamed(
                    // ignore: use_build_context_synchronously
                    context,
                    Routes.createCentralUnit,
                  ).then((_) {
                    _networkService.startServiceDiscovery();
                    setState(() {});
                  });
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      addLabel,
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

    return FutureBuilder<Map<String, dynamic>>(
        future: Future.wait([
          currentGroup.todaysWaterUsage(),
          currentGroup.yesterdayWaterUsage(),
          currentGroup.refreshFlowAndTodaysUsage().then((_) {
            return currentGroup.getWaterUsageData(11);
          }),
        ]).then((results) => {
              'todaysUsage': results[0],
              'maxUsage': results[1],
              'waterUsageData': results[2],
              'flowRate': currentGroup.flowRate(),
            }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: MyColors.background,
              appBar: CustomAppBar(
                leadingIcon: const Icon(Icons.menu),
                onLeadingTap: () {},
                title: MyStrings.appName,
                trailingIcon: const Icon(Icons.refresh),
                onTrailingTap: () {},
                bottomWidgets: [
                  HorizontalListWidget(
                    items: _appData.groups.map((e) => e.name).toList(),
                    selectedIndex: groupIndex,
                    onIndexChanged: (index) {},
                  ),
                ],
                height: 120,
              ),
              body: Center(
                child: CircularProgressIndicator(
                  color: MyColors.lightThemeFont,
                ),
              ),
            );
          }

          Map<String, dynamic> data = snapshot.data!;
          if (snapshot.connectionState == ConnectionState.done) {
            _isLoading = false;
            _swipeLoading = false;
          } else {
            if (_swipeLoading) {
              _isLoading = true;
            }
          }
          return LoadingWidget(
            isLoading: _isLoading,
            child: GestureDetector(
              onHorizontalDragEnd: _handleSwipe,
              child: Scaffold(
                key: _scaffoldKey,
                drawer: CustomDrawer(
                  onBack: _onBack,
                ),
                appBar: CustomAppBar(
                  leadingIcon: const Icon(Icons.menu),
                  onLeadingTap: _openDrawer,
                  title: MyStrings.appName,
                  trailingIcon: const Icon(Icons.refresh),
                  onTrailingTap: () => _refreshDataForCentrals(currentGroup),
                  onTrailingLongPress: autoRefresh,
                  onUncollapse: cancelAutoRefresh,
                  bottomWidgets: [
                    HorizontalListWidget(
                      items: _appData.groups.map((e) => e.name).toList(),
                      selectedIndex: groupIndex,
                      onIndexChanged: _handleGroupChange,
                    ),
                  ],
                  height: 120,
                ),
                backgroundColor: MyColors.background,
                body: RefreshIndicator(
                  color: MyColors.lightThemeFont,
                  backgroundColor: MyColors.background,
                  onRefresh: () => _refreshDataRefreshIndicator(currentGroup),
                  child: _buildScreen(data, currentGroup),
                ),
              ),
            ),
          );
        });
  }
}
