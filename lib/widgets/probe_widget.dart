import 'dart:io';
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/widgets/blinking_icon_widget.dart';

class ProbeWidget extends StatefulWidget {
  const ProbeWidget({
    super.key,
    required this.probe,
    required this.onPressed,
  });

  final LeakProbe probe;
  final VoidCallback onPressed;

  @override
  State<ProbeWidget> createState() => _ProbeWidgetState();
}

class _ProbeWidgetState extends State<ProbeWidget> {
  Color get _color {
    return MyColors.lightThemeFont;
  }

  Widget _batteryInfo() {
    const double size = 60;
    Icon icon = const Icon(
      Icons.battery_full,
      size: size,
    );

    if (widget.probe.batteryLevel <= 12.5) {
      icon = const Icon(
        Icons.battery_0_bar,
        size: size,
      );
    } else if (widget.probe.batteryLevel <= 25) {
      icon = const Icon(
        Icons.battery_1_bar,
        size: size,
      );
    } else if (widget.probe.batteryLevel < 37.5) {
      icon = const Icon(
        Icons.battery_2_bar,
        size: size,
      );
    } else if (widget.probe.batteryLevel < 50) {
      icon = const Icon(
        Icons.battery_3_bar,
        size: size,
      );
    } else if (widget.probe.batteryLevel < 62.5) {
      icon = const Icon(
        Icons.battery_4_bar,
        size: size,
      );
    } else if (widget.probe.batteryLevel < 75) {
      icon = const Icon(
        Icons.battery_5_bar,
        size: size,
      );
    } else if (widget.probe.batteryLevel < 87.5) {
      icon = const Icon(
        Icons.battery_6_bar,
        size: size,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        Transform.rotate(
          angle: 90 * pi / 180,
          child: icon,
        ),
        const SizedBox(
          width: 5,
        ),
        SizedBox(
          width: 80,
          child: Text(
              textAlign: TextAlign.center,
              "${widget.probe.batteryLevel}%",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: _color,
                    fontSize: 25,
                  )),
        ),
      ],
    );
  }

  Widget _createTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widget.probe.name,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: _color,
                ),
          ),
        ),
        if (widget.probe.blocked)
          BlinkingIconWidget(
            icon: CustomIcons.leak,
            size: 30,
            duration: Duration(milliseconds: 500),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        depth: 5,
        intensity: 0.8,
        color: MyColors.background,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(12),
        ),
      ),
      onPressed: widget.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: [
            _createTitle(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.probe.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(widget.probe.getPhoto()!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              CustomIcons.probe,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _batteryInfo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
