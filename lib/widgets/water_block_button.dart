import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';

class WaterBlockButton extends StatefulWidget {
  const WaterBlockButton(
      {super.key, required this.group, required this.handleButtonPress});
  final Group group;
  final Function handleButtonPress;

  @override
  State<WaterBlockButton> createState() => _WaterBlockButtonState();
}

class _WaterBlockButtonState extends State<WaterBlockButton> {
  Color _getButtonColor() {
    if (widget.group.status == BlockStatus.noBlocked) {
      return MyColors.blue;
    } else if (widget.group.status == BlockStatus.allBlocked) {
      return MyColors.red;
    } else if (widget.group.status == BlockStatus.someBlocked) {
      return MyColors.yellow;
    }
    return MyColors.blue;
  }

  IconData _getButtonIcon() {
    if (widget.group.status == BlockStatus.noBlocked) {
      return Icons.lock_open;
      // return CustomIcons.leak_probe;
    } else if (widget.group.status == BlockStatus.allBlocked) {
      return Icons.lock_outline;
    } else if (widget.group.status == BlockStatus.someBlocked) {
      return Icons.lock_outline;
    }
    return Icons.lock_open;
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: EdgeInsets.all(14),
      duration: Duration(milliseconds: 200),
      style: NeumorphicStyle(
        shape: NeumorphicShape.convex,
        boxShape: NeumorphicBoxShape.circle(),
        depth: 8,
        intensity: 5,
        surfaceIntensity: 0.5,
        color: _getButtonColor(),
      ),
      onPressed: () => widget.handleButtonPress(),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: NeumorphicIcon(
          _getButtonIcon(),
          size: 80,
          style: NeumorphicStyle(
            color: widget.group.status == BlockStatus.noBlocked
                ? MyColors.background
                : Colors.white,
            depth: widget.group.status == BlockStatus.someBlocked ? 2 : 1,
          ),
        ),
      ),
    );
  }
}
