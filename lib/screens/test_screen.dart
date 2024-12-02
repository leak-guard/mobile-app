import 'package:flutter/material.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/wifi_dropdown_widget.dart';

// TODO: to be removed

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _wifiController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _wifiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: MyStrings.manageProbes,
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WifiDropdown(
            controller: _wifiController,
            onNetworkSelected: (network) {
              // Obsługa wybranej sieci
              print('Selected network: ${network.ssid}');
              print('Signal strength: ${network.signalStrength}');
              print('Is secure: ${network.isSecure}');
            },
          )),
    );
  }
}
