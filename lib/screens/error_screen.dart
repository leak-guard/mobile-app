import 'package:flutter/material.dart';
import 'package:leak_guard/widgets/app_bar.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: "Error",
      ),
      body: Center(
        child: Text("Something went wrong. Go back and try again."),
      ),
    );
  }
}
