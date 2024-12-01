import 'package:flutter/material.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/wifi_dropdown_widget.dart';

// TODO: to be removed

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _ssidController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ssidController.dispose();
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
          controller: _ssidController,
          availableNetworks: [
            'WiFi_1',
            'WiFi_2',
            'WiFi_3',
            'WiFi_1',
            'WiFi_2',
            'WiFi_3',
            'WiFi_1',
            'WiFi_2',
            'WiFi_3'
          ],
          onSSIDSelected: (String ssid) {
            print('Selected network: $ssid');
          },
        ),
      ),
    );
  }
}
