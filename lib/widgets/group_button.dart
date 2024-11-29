import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';

class GroupButton extends StatefulWidget {
  const GroupButton({
    super.key,
    required this.group,
    required this.onPressed,
    this.onLongPress,
  });

  final Group group;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  State<GroupButton> createState() => _GroupButtonState();
}

class _GroupButtonState extends State<GroupButton> {
  @override
  Widget build(BuildContext context) {
    Color color = MyColors.lightThemeFont;

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: NeumorphicButton(
        style: NeumorphicStyle(
          depth: 5,
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
                  widget.group.name,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: color,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 123.2,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Probe information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CustomIcons.leak_probe,
                                color: color, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              widget.group.leakProbeNumber().toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(color: color),
                            ),
                            const SizedBox(width: 16),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                              child: Icon(
                                CustomIcons.battery_low,
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              widget.group
                                  .leakProbeLowBatteryNumber()
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(color: color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Central units information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CustomIcons.central_unit,
                              color: color,
                              size: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.group.centralUnitsNumber().toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(color: color),
                            ),
                            const SizedBox(width: 16),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(1, 6, 0, 0),
                              child: Icon(
                                CustomIcons.broken_pipe,
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                              child: Text(
                                widget.group
                                    .centralUnitsLeaksNumber()
                                    .toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(color: color),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
