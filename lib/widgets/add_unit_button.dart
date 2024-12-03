import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:leak_guard/utils/routes.dart';

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
          print("Current wifi name: ${_networkService.currentWifiName}");
          if ((_networkService.currentWifiName ?? "") == "LeakGuardConfig") {
            CentralUnit newCentral = CentralUnit(
              name: "",
              addressIP: "192.168.4.1",
              addressMAC: '',
              password: '',
              isValveNO: true,
              impulsesPerLiter: 477,
              timezoneId: 37,
            );
            Navigator.pushNamed(
              context,
              Routes.createCentralUnit,
              arguments: CreateCentralScreenArguments(newCentral),
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
