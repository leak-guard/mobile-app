import 'dart:io';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';

class GroupWidget extends StatefulWidget {
  const GroupWidget({
    super.key,
    required this.group,
    required this.onPressed,
  });

  final Group group;
  final VoidCallback onPressed;

  @override
  State<GroupWidget> createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  final Color _color = MyColors.lightThemeFont;

  Widget _createIcon(IconData icon, num number) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30,
        ),
        const SizedBox(
          width: 5,
        ),
        SizedBox(
          width: 35,
          child: Text(
              textAlign: TextAlign.center,
              number.toString(),
              style: Theme.of(context).textTheme.displayMedium!),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
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
            Row(
              children: [
                Text(
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  widget.group.name,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: _color,
                      ),
                ),
              ],
            ),
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
                    child: widget.group.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(widget.group.getPhoto()!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              CustomIcons.group,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 3),
                          _createIcon(CustomIcons.central_unit,
                              widget.group.centralUnitsNumber()),
                          const SizedBox(width: 7),
                          _createIcon(
                              CustomIcons.probe, widget.group.leakProbeNumber())
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 3),
                          _createIcon(Icons.signal_cellular_alt,
                              widget.group.connectedCentralUnits()),
                          const SizedBox(width: 7),
                          _createIcon(CustomIcons.battery_low,
                              widget.group.leakProbeLowBatteryNumber())
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 3),
                          _createIcon(Icons.lock_outline,
                              widget.group.lockedCentralUnitsCount()),
                          const SizedBox(width: 7),
                          _createIcon(CustomIcons.leak,
                              widget.group.detectedLeaksCount())
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
    );
  }
}
