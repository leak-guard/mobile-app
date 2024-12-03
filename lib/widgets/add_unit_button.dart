import 'dart:io';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:nsd/nsd.dart';

class AddUnitButton extends StatelessWidget {
  AddUnitButton({
    super.key,
    required this.onBack,
  });
  final VoidCallback onBack;

  final _networkService = NetworkService();

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      padding: const EdgeInsets.all(15),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: -10,
        intensity: 0.8,
        lightSource: LightSource.topLeft,
        color: MyColors.background,
      ),
      child: NeumorphicButton(
        style: NeumorphicStyle(
          depth: 5,
          intensity: 0.8,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          await _networkService.getCurrentWifiName();
          if ((_networkService.currentWifiName ?? "") == "LeakGuardConfig") {
            Service service = Service(
              name: "LeakGuardConfig",
              type: "_leakguard._tcp",
              port: 80,
              addresses: [InternetAddress("192.168.4.1")],
            );
            Navigator.pushNamed(
              context,
              Routes.createCentralUnit,
              arguments: CreateCentralScreenArguments(service),
            ).then((_) {
              onBack();
            });
            CustomToast.toast("Connected to LeakGuardConfig!");
            return;
          }
          Navigator.pushNamed(
            context,
            Routes.findCentralUnit,
          ).then((_) {
            onBack();
          });
        },
        child: Center(
          child: Text('Add new central unit',
              style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }
}
