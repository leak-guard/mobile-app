import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';

class WaterBlockWidget extends StatefulWidget {
  const WaterBlockWidget(
      {super.key, required this.group, required this.handleButtonPress});
  final Group group;
  final VoidCallback handleButtonPress;

  @override
  State<WaterBlockWidget> createState() => _WaterBlockWidgetState();
}

class _WaterBlockWidgetState extends State<WaterBlockWidget> {
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
      padding: const EdgeInsets.all(14),
      duration: const Duration(milliseconds: 200),
      style: NeumorphicStyle(
        shape: NeumorphicShape.convex,
        boxShape: const NeumorphicBoxShape.circle(),
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
