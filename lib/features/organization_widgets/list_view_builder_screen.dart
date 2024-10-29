import 'package:flutter/material.dart';
import 'package:leak_guard/shared/widgets/drawer_menu.dart';

class ListViewBuilderScreen extends StatelessWidget {
  const ListViewBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List names = [
      'John',
      'Doe',
      'Smith',
      'Alex',
      'Max',
      'Janek',
      'Denis',
      'Kamil',
      'Krzysztof',
      'Marek',
      'Piotr',
      'Tomek',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ListView.builder",
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
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) => Container(
          color: Colors.deepPurple[100],
          height: 100,
          width: 100,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Center(
            child: Text(
              names[index],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
