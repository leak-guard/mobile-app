import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        centerTitle: true,
        title: Text(
          MyStrings.appName,
          style: Theme.of(context).textTheme!.titleLarge,
        ),
      ),
      backgroundColor: MyColors.background,
      body: ListView(
        children: [
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
    );
  }
}
