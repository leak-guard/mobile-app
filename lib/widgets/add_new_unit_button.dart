import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';

class AddNewUnitButton extends StatelessWidget {
  const AddNewUnitButton({
    super.key,
    required this.onBack,
  });
  final VoidCallback onBack;

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
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.findCentral,
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
