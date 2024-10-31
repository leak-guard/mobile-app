import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:leak_guard/widgets/panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _buildTab(String text, {bool selected = false}) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        depth: selected ? -2 : 2, // Wciśnięty efekt dla wybranej zakładki
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.blue : Colors.grey,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150), // Zwiększona wysokość AppBara
        child: NeumorphicAppBar(
          titleSpacing: 0,
          actionSpacing: 0,
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Górny rząd z logo i przyciskami
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Rozłożenie elementów
                children: [
                  NeumorphicButton(
                    padding: EdgeInsets.all(8),
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
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(10)),
                      depth: 5,
                    ),
                    onPressed: () {},
                    child: Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: 8), // Odstęp między rzędami
              // Dolny rząd z zakładkami
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab("Kotłownia", selected: true),
                  _buildTab("Toplota"),
                  _buildTab("Drugie piętro"),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      backgroundColor: MyColors.background,
      body: BlurredTopEdge(
        height: 30,
        child: ListView(
          children: [
            SizedBox(height: 20),
            Panel(
              name: "Water usage",
              child: Neumorphic(
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                ),
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
