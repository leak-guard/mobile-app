import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';
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
  final groups = [
    Group(name: 'KotłowniaKotłowniaKotłowniaKotłowniaKotłowniaKotłownia'),
    Group(name: 'Toaleta'),
    Group(name: 'Duży salon'),
    Group(name: 'Mały salon'),
    Group(name: 'Kuchnia'),
    Group(name: 'Sypialnia'),
    Group(name: 'Łazienka'),
    Group(name: 'Garaż'),
    Group(name: "Piwnica"),
    Group(name: "Taras"),
    Group(name: "Ogród"),
    Group(name: "Kotłownia"),
  ];

  List<double> waterUsages = [
    2.5,
    0.2,
    12.2,
    133.2,
  ];

  void _getWaterUsage() {
    setState(() {
      waterUsage = waterUsages.elementAt(Random().nextInt(waterUsages.length));
    });
  }

  double waterUsage = 2222.5;

  @override
  Widget build(BuildContext context) {
    Group currentGroup = groups[1];

    return Scaffold(
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
                      onPressed: _getWaterUsage,
                      child: Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              HorizontalGroupList(groups: groups)
            ],
          ),
        ),
      ),
      backgroundColor: MyColors.background,
      body: BlurredTopEdge(
        height: 30,
        child: ListView(
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: WaterUsageArc(
                    currentUsage: currentGroup.todaysUsage(),
                    maxUsage: currentGroup.maxUsage(),
                    flowRate: currentGroup.flowRate(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: WaterBlockButton(group: currentGroup),
                ),
              ],
            ),
            SizedBox(height: 10),
            Panel(
              name: "Water usage",
              child: WaterUsageChart(
                data: currentGroup.getWaterUsageData(
                  12,
                ),
                maxHeight: 150,
              ),
              onTap: () {},
            ),
            Panel(
              name: "Block time",
              child: BlockTimeClock(
                currentGroup: currentGroup,
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
                          // "9999",
                          currentGroup.leakProbeNumber().toString(),
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
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
                        currentGroup.leakProbeLowBatteryNumber().toString(),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                        // "9999",
                        currentGroup.centralUnitsNumber().toString(),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
    );
  }
}
