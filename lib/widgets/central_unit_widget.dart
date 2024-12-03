import 'dart:io';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/utils/colors.dart';

class CentralUnitWidget extends StatefulWidget {
  const CentralUnitWidget(
      {super.key,
      required this.central,
      required this.onPressed,
      this.onLongPress});
  final CentralUnit central;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  State<CentralUnitWidget> createState() => _CentralUnitWidgetState();
}

class _CentralUnitWidgetState extends State<CentralUnitWidget> {
  get _color => widget.central.chosen
      ? MyColors.lightThemeFont.withOpacity(0.7)
      : MyColors.lightThemeFont;

  Widget _createTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widget.central.name,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: _color,
                ),
          ),
        ),
        _createTitleLeadingIcons(),
      ],
    );
  }

  Widget _createTitleLeadingIcons() {
    return Row(
      children: [
        Icon(
          widget.central.isBlocked ? Icons.lock_outline : Icons.lock_open,
          color: _color,
          size: 30,
        ),
        const SizedBox(width: 7),
        Icon(
          widget.central.isOnline ? Icons.wifi : Icons.wifi_off,
          color: _color,
          size: 30,
        ),
      ],
    );
  }

  Widget _createIcon(IconData icon, num number, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        Icon(
          icon,
          size: 35,
          color: color,
        ),
        const SizedBox(
          width: 15,
        ),
        SizedBox(
          width: 60,
          child: Text(
              textAlign: TextAlign.center,
              number.toString(),
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: color,
                    fontSize: 25,
                  )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: NeumorphicButton(
        style: NeumorphicStyle(
          depth: widget.central.chosen ? -5 : 5,
          intensity: 0.8,
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
                      child: widget.central.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(widget.central.getPhoto()!),
                                fit: BoxFit.cover,
                                color: widget.central.chosen
                                    ? Colors.white.withOpacity(0.5)
                                    : null,
                                colorBlendMode: BlendMode.overlay,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                CustomIcons.central_unit,
                                color: Colors.white,
                                size: 70,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _createIcon(CustomIcons.probe,
                          widget.central.leakProbesCount(), _color),
                      _createIcon(CustomIcons.battery_low,
                          widget.central.leakProbeLowBatteryCount(), _color),
                      _createIcon(CustomIcons.leak,
                          widget.central.detectedLeaksCount(), _color),
                    ],
                  ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
