import 'package:flutter/material.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/strings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(MyStrings.appName),
      ),
      backgroundColor: MyColors.background,
      body: Center(
        child: Text("Panel"),
      ),
    );
  }
}
