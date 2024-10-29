import 'package:flutter/material.dart';
import 'package:leak_guard/features/home/screens/collumn_screen.dart';
import 'package:leak_guard/features/home/screens/list_view_builder.dart';
import 'package:leak_guard/features/home/screens/list_view_screen.dart';
import 'package:leak_guard/shared/utils/routes.dart';
import 'features/home/screens/home_screen.dart';
import 'features/settings/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.deepPurple[200],
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => const HomeScreen(),
        Routes.settings: (context) => const SettingsScreen(),
        Routes.columns: (context) => const CollumnScreen(),
        Routes.listView: (context) => const ListViewScreen(),
        Routes.listViewBuilder: (context) => const ListViewBuilderScreen(),
      },
    );
  }
}
