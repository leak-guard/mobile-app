import 'dart:math' as math;
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
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

  const BlockClockWidget({
    super.key,
    required this.group,
  });

  @override
  State<BlockClockWidget> createState() => _BlockClockWidgetState();
}

class _BlockClockWidgetState extends State<BlockClockWidget> {
  Set<int> _selectedHours = {};
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _selectedHours = Set.from(widget.group.blockedHours);
    _isLocked = widget.group.isTimeBlockSetted;
  }

  @override
  void didUpdateWidget(BlockClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.group != oldWidget.group) {
      _selectedHours = Set.from(widget.group.blockedHours);
      _isLocked = widget.group.isTimeBlockSetted;
    }
  }

  void _toggleHour(int hour) {
    setState(() {
      widget.group.isTimeBlockSetted = false;
      _isLocked = false;

      if (_selectedHours.contains(hour)) {
        widget.group.blockedHours.remove(hour);
        _selectedHours.remove(hour);
      } else {
        widget.group.blockedHours.add(hour);
        _selectedHours.add(hour);
      }
    });
  }

  void _applyBlockedHours() {
    if (_selectedHours.isEmpty) return;

    setState(() {
      _isLocked = !_isLocked;
      widget.group.isTimeBlockSetted = !widget.group.isTimeBlockSetted;
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
        color: _isLocked ? MyColors.red : MyColors.lightButtonClock,
        shape: NeumorphicShape.convex,
        boxShape: const NeumorphicBoxShape.circle(),
      ),
      onPressed: _applyBlockedHours,
      child: SizedBox(
        width: innerRadius,
        height: innerRadius,
        child: Center(
          child: NeumorphicIcon(
            _isLocked ? Icons.lock_outline : Icons.lock_open,
            size: 40,
            style: NeumorphicStyle(
              color: _isLocked ? Colors.white : Colors.black,
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
    final isOuter = hour <= 12;
    final baseAngle = isOuter
        ? (hour - 3) * (2 * math.pi / 12)
        : ((hour - 15) * (2 * math.pi / 12));

    final position = Offset(
      radius * math.cos(baseAngle),
      radius * math.sin(baseAngle),
    );

    final isSelected = _selectedHours.contains(hour);

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
    List<int> selectedList = _selectedHours.toList()..sort();

    for (int i = 0; i < selectedList.length; i++) {
      int currentHour = selectedList[i];

      bool isOuter = currentHour < 12;
      if (currentHour == 24) isOuter = true;
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
                    index + 1,
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
