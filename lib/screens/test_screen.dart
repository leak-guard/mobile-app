import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/services/api_service.dart';
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
  final _api = CustomApi();
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
      body: Center(
        child: NeumorphicButton(
          onPressed: () {
            _api.registerCentralUnit("this-is-my-id");
          },
          child: const Text('Register central'),
        ),
      ),
    );
  }
}
