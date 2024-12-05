import 'dart:math' as math;
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/block_schedule.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';

class ArcPathProvider extends NeumorphicPathProvider {
  final double startAngle;
  final double endAngle;
  final double radius;
  final double thickness;

  const ArcPathProvider({
    required this.startAngle,
    required this.endAngle,
    required this.radius,
    this.thickness = 40,
  });

  @override
  bool shouldReclip(NeumorphicPathProvider oldClipper) => false;

  @override
  bool get oneGradientPerPath => true;

  @override
  Path getPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    path.addArc(
      Rect.fromCircle(center: center, radius: radius + thickness / 2),
      startAngle,
      endAngle - startAngle,
    );

    path.arcTo(
      Rect.fromCircle(center: center, radius: radius - thickness / 2),
      endAngle,
      -(endAngle - startAngle),
      false,
    );

    path.close();
    return path;
  }
}

class BlockClockWidget extends StatefulWidget {
  final Group group;
  final BlockDayEnum targetDay;

  const BlockClockWidget({
    super.key,
    required this.group,
    required this.targetDay,
  });

  @override
  State<BlockClockWidget> createState() => _BlockClockWidgetState();
}

class _BlockClockWidgetState extends State<BlockClockWidget> {
  late BlockDay _blockDay;

  void _initializeBlockDay() {
    print("targetDay: ${widget.targetDay}");
    if (widget.targetDay == BlockDayEnum.monday) {
      _blockDay = widget.group.blockSchedule.monday;
    } else if (widget.targetDay == BlockDayEnum.tuesday) {
      _blockDay = widget.group.blockSchedule.tuesday;
    } else if (widget.targetDay == BlockDayEnum.wednesday) {
      _blockDay = widget.group.blockSchedule.wednesday;
    } else if (widget.targetDay == BlockDayEnum.thursday) {
      _blockDay = widget.group.blockSchedule.thursday;
    } else if (widget.targetDay == BlockDayEnum.friday) {
      _blockDay = widget.group.blockSchedule.friday;
    } else if (widget.targetDay == BlockDayEnum.saturday) {
      _blockDay = widget.group.blockSchedule.saturday;
    } else if (widget.targetDay == BlockDayEnum.sunday) {
      _blockDay = widget.group.blockSchedule.sunday;
    } else if (widget.targetDay == BlockDayEnum.all) {
      DateTime dateTime = DateTime.now();
      if (dateTime.weekday == DateTime.monday) {
        _blockDay = widget.group.blockSchedule.monday;
      } else if (dateTime.weekday == DateTime.tuesday) {
        _blockDay = widget.group.blockSchedule.tuesday;
      } else if (dateTime.weekday == DateTime.wednesday) {
        _blockDay = widget.group.blockSchedule.wednesday;
      } else if (dateTime.weekday == DateTime.thursday) {
        _blockDay = widget.group.blockSchedule.thursday;
      } else if (dateTime.weekday == DateTime.friday) {
        _blockDay = widget.group.blockSchedule.friday;
      } else if (dateTime.weekday == DateTime.saturday) {
        _blockDay = widget.group.blockSchedule.saturday;
      } else if (dateTime.weekday == DateTime.sunday) {
        _blockDay = widget.group.blockSchedule.sunday;
      }
    }
    print("blockday: $_blockDay");
  }

  @override
  void initState() {
    super.initState();
    _initializeBlockDay();
  }

  @override
  void didUpdateWidget(BlockClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeBlockDay();
  }

  void _applyChanges(bool isBlocked) {
    if (widget.targetDay == BlockDayEnum.all) {
      widget.group.blockSchedule.toggleBlockAll(isBlocked);
      widget.group.blockSchedule.applyBlockScheduleToAllDays(_blockDay);
    }
    _blockDay.enabled = isBlocked;
    widget.group.sendBlockSchedule();
  }

  void _toggleHour(int hour) {
    setState(() {
      if (_blockDay.enabled) {
        _applyChanges(false);
      }
      if (_blockDay.hours[hour]) {
        _blockDay.hours[hour] = false;
      } else {
        _blockDay.hours[hour] = true;
      }
    });
  }

  void _applyBlockedHours() {
    if (!(_blockDay.hours.any((hour) => hour = true))) return;

    setState(() {
      _applyChanges(!_blockDay.enabled);
    });
  }

  Widget _buildCenterContent(double innerRadius) {
    return NeumorphicButton(
      key: const ValueKey('block_hours_button'),
      minDistance: 6,
      style: NeumorphicStyle(
        depth: 6,
        surfaceIntensity: 0.5,
        intensity: 0.5,
        color: _blockDay.enabled ? MyColors.red : MyColors.lightButtonClock,
        shape: NeumorphicShape.convex,
        boxShape: const NeumorphicBoxShape.circle(),
      ),
      onPressed: _applyBlockedHours,
      child: SizedBox(
        width: innerRadius,
        height: innerRadius,
        child: Center(
          child: NeumorphicIcon(
            _blockDay.enabled ? Icons.lock_outline : Icons.lock_open,
            size: 40,
            style: NeumorphicStyle(
              color: _blockDay.enabled ? Colors.white : Colors.black,
              depth: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(int hour, double buttonSize, bool isSelected) {
    return Center(
      key: ValueKey('button_content_${hour}_$isSelected'),
      child: Text(
        hour.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildHourButton(
      int hour, double center, double radius, double buttonSize) {
    final isOuter = hour < 12;
    final baseAngle = isOuter
        ? (hour - 3) * (2 * math.pi / 12)
        : ((hour - 15) * (2 * math.pi / 12));

    final position = Offset(
      radius * math.cos(baseAngle),
      radius * math.sin(baseAngle),
    );
    bool isSelected;
    isSelected = _blockDay.hours[hour];

    return Positioned(
      key: ValueKey('hour_button_position_$hour'),
      left: center + position.dx - buttonSize / 2,
      top: center + position.dy - buttonSize / 2,
      child: RepaintBoundary(
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: NeumorphicButton(
            key: ValueKey('hour_button_$hour'),
            onPressed: () => _toggleHour(hour),
            padding: const EdgeInsets.all(0),
            style: NeumorphicStyle(
              shape:
                  isSelected ? NeumorphicShape.convex : NeumorphicShape.concave,
              depth: isSelected ? 0 : -2,
              intensity: 1,
              surfaceIntensity: 0.7,
              color: isSelected
                  ? MyColors.red.withOpacity(0.9)
                  : MyColors.lightButtonClock,
              boxShape: const NeumorphicBoxShape.circle(),
            ),
            child: _buildButtonContent(hour, buttonSize, isSelected),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundArcs(double size) {
    return RepaintBoundary(
      child: Stack(
        key: const ValueKey('background_arcs'),
        children: [
          Positioned.fill(
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: -2,
                intensity: 0.7,
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.path(
                  ArcPathProvider(
                    startAngle: 0,
                    endAngle: 1.99999 * math.pi,
                    radius: size * 0.4,
                    thickness: size * 0.105,
                  ),
                ),
                color: MyColors.lightButtonClock,
              ),
            ),
          ),
          Positioned.fill(
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: -2,
                intensity: 0.7,
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.path(
                  ArcPathProvider(
                    startAngle: 0,
                    endAngle: 1.99999 * math.pi,
                    radius: size * 0.25,
                    thickness: size * 0.105,
                  ),
                ),
                color: MyColors.lightButtonClock,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConnectionArcs(double size) {
    List<Widget> arcs = [];
    List<int> selectedHours = [];
    for (int i = 0; i < _blockDay.hours.length; i++) {
      if (_blockDay.hours[i]) {
        selectedHours.add(i);
      }
    }
    List<int> selectedList = selectedHours..sort();

    for (int i = 0; i < selectedList.length; i++) {
      int currentHour = selectedList[i];

      bool isOuter = currentHour < 12;
      final radius = isOuter ? size * 0.4 : size * 0.25;

      double startAngle = isOuter
          ? (currentHour - 3) * (2 * math.pi / 12)
          : ((currentHour - 15) * (2 * math.pi / 12));
      double endAngle = isOuter
          ? (currentHour - 2) * (2 * math.pi / 12)
          : ((currentHour - 14) * (2 * math.pi / 12));

      arcs.add(
        Positioned.fill(
          key: ValueKey('connection_arc_$currentHour'),
          child: RepaintBoundary(
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: 3,
                intensity: 0.7,
                boxShape: NeumorphicBoxShape.path(
                  ArcPathProvider(
                    startAngle: startAngle,
                    endAngle: endAngle,
                    radius: radius,
                    thickness: size * 0.105,
                  ),
                ),
                color: MyColors.red.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }
    return arcs;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          final center = size / 2;
          final outerRadius = size * 0.4;
          final innerRadius = size * 0.25;
          final buttonSize = size * 0.1;

          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      depth: 10,
                      intensity: 0.5,
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.circle(),
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildBackgroundArcs(size),
                ..._buildConnectionArcs(size),
                ...List.generate(
                  24,
                  (index) => _buildHourButton(
                    index,
                    center,
                    index < 12 ? outerRadius : innerRadius,
                    buttonSize,
                  ),
                ),
                Center(
                  child: _buildCenterContent(innerRadius * 0.7),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
