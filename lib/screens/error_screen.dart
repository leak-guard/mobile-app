import 'package:flutter/material.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: "Error",
      ),
      body: const Center(
        child: Text("Something went wrong. Go back and try again."),
      ),
    );
  }
}
