import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/strings.dart';
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

  double waterUsage = 2.5;

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
                    currentUsage: 600,
                    maxUsage: 1000,
                    flowRate: 2.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: WaterBlockButton(group: currentGroup),
                ),
              ],
            ),
            SizedBox(height: 10),
            Panel(
              name: "Water usage",
              child: WaterUsageChart(
                data: currentGroup.getWaterUsageData(12),
              ),
              onTap: () {},
            ),
            Panel(
              name: "Block time",
              child: Neumorphic(
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                ),
              ),
              onTap: () {},
            ),
            Panel(
              name: "Leak probes",
              child: Neumorphic(
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                ),
              ),
              onTap: () {},
            ),
            Panel(
              name: "Central units",
              child: Neumorphic(
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
