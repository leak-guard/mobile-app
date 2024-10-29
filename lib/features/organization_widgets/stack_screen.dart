import 'package:flutter/material.dart';
import 'package:leak_guard/shared/widgets/drawer_menu.dart';

class StackScreen extends StatelessWidget {
  const StackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stack",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.deepPurple[100],
              width: 400,
              height: 200,
            ),
            Container(
              color: Colors.deepPurple[200],
              width: 300,
              height: 150,
            ),
            Container(
              color: Colors.deepPurple[300],
              width: 200,
              height: 100,
            ),
            Container(
              color: Colors.deepPurple[400],
              width: 100,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
