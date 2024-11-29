import 'dart:io';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/utils/colors.dart';

class CentralUnitButton extends StatefulWidget {
  const CentralUnitButton(
      {super.key,
      required this.central,
      required this.onPressed,
      this.onLongPress});
  final CentralUnit central;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  State<CentralUnitButton> createState() => _CentralUnitButtonState();
}

class _CentralUnitButtonState extends State<CentralUnitButton> {
  @override
  Widget build(BuildContext context) {
    Color _color = !widget.central.chosen
        ? MyColors.lightThemeFont
        : MyColors.lightThemeFont.withOpacity(0.7);
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
              Center(
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widget.central.name,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: _color,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 130,
                      decoration: BoxDecoration(
                        color: MyColors.lightThemeFont,
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
                          : Center(
                              child: Icon(
                                CustomIcons.central_unit,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CustomIcons.leak_probe, color: _color, size: 50),
                          const SizedBox(
                            width: 24,
                          ),
                          Text(
                            widget.central.leakProbeNumber().toString(),
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  color: _color,
                                ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 3,
                          ),
                          Icon(
                            CustomIcons.battery_low,
                            color: _color,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 42,
                          ),
                          Text(
                            widget.central
                                .leakProbeLowBatteryNumber()
                                .toString(),
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  color: _color,
                                ),
                          )
                        ],
                      ),
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
