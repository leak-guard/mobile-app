import 'package:leak_guard/utils/colors.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class Panel extends StatelessWidget {
  final String name;
  final Widget child;
  final VoidCallback onTap;

  const Panel({
    Key? key,
    required this.name,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(20),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(41)),
        depth: -10,
        intensity: 0.8,
        lightSource: LightSource.topLeft,
        color: MyColors.background,
      ),
      child: Column(
        children: [
          NeumorphicButton(
            onPressed: onTap,
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            minDistance: -3,
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
              depth: 0,
              intensity: 0.8,
              lightSource: LightSource.topLeft,
              color: MyColors.background,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge!),
                Icon(
                  Icons.arrow_forward_ios,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          )
        ],
      ),
    );
  }
}
