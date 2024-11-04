import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/arc_path_provider.dart';
import 'package:leak_guard/utils/colors.dart';

class WaterUsageArc extends StatefulWidget {
  final double currentUsage;
  final double maxUsage;
  final double flowRate;

  const WaterUsageArc({
    super.key,
    required this.currentUsage,
    required this.maxUsage,
    required this.flowRate,
  });

  @override
  State<WaterUsageArc> createState() => _WaterUsageArcState();
}

class _WaterUsageArcState extends State<WaterUsageArc>
    with SingleTickerProviderStateMixin {
  final double _thickness = 16;

  Color _arcColor() {
    if (widget.currentUsage / widget.maxUsage <= 0.9) {
      return MyColors.blue;
    } else if (widget.currentUsage / widget.maxUsage <= 1) {
      return MyColors.yellow;
    } else {
      return MyColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: -5,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.path(
                    ArcPathProvider(thickness: _thickness),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 0,
                  intensity: 0.8,
                  surfaceIntensity: 0.5,
                  color: _arcColor(),
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.path(
                    ArcPathProvider(
                      sweepAngle: widget.currentUsage / widget.maxUsage < 1
                          ? 280 * widget.currentUsage / widget.maxUsage
                          : 280,
                      thickness: _thickness,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 52,
                      ),
                      Text(
                        '${widget.currentUsage.toStringAsFixed(1)} l',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Container(
                        width: 70,
                        height: 2,
                        color: MyColors.lightThemeFont,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      Text(
                        '${widget.maxUsage.toStringAsFixed(1)} l',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${widget.flowRate.toStringAsFixed(1)}\nl/min',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
