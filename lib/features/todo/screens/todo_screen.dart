import 'package:flutter/material.dart';
import 'package:leak_guard/shared/utils/routes.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // * text editing controller to get access to what the user typed
  TextEditingController myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Todo",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.settings);
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 70,
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple[300]!,
              ),
              BoxShadow(
                color: Colors.deepPurple[200]!,
                spreadRadius: -2.0,
                blurRadius: 10.0,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Center(
              child: TextField(
            controller: myController,
            decoration: const InputDecoration.collapsed(
              hintText: 'Type group name',
            ),
          )),
        ),
      ),
    );
  }
}
