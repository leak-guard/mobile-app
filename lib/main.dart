import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  String name = "John Doe";
  int age = 30;
  double pi = 3.14;
  bool isBeginner = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.deepPurple[200],
        appBar: AppBar(
          title: const Text(
            "Epic App",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          elevation: 0,
          centerTitle: true,
          leading: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ))
          ],
        ),
        body: Center(
          child: Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(25),
            child:
                Icon(Icons.favorite, color: Colors.deepPurple[400], size: 100),
          ),
        ),
      ),
    );
  }
}
