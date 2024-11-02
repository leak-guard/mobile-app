import 'dart:math' as math;
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/colors.dart';

class ArcPathProvider extends NeumorphicPathProvider {
  final double startAngle;
  final double sweepAngle;
  final double thickness;

  ArcPathProvider({
    this.startAngle = 130,
    this.sweepAngle = 280,
    this.thickness = 30,
  });

  @override
  bool shouldReclip(NeumorphicPathProvider oldClipper) => true;

  @override
  Path getPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - thickness;

    final startAngleRad = startAngle * math.pi / 180;
    final sweepAngleRad = sweepAngle * math.pi / 180;

    final path = Path();

    path.addArc(
      Rect.fromCircle(center: center, radius: radius + thickness),
      startAngleRad,
      sweepAngleRad,
    );

    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngleRad + sweepAngleRad,
      -sweepAngleRad,
      false,
    );

    path.close();
    return path;
  }

  @override
  bool get oneGradientPerPath => true;
}

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
                  depth: 5,
                  intensity: 0.8,
                  color: MyColors.blue,
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
                  const SizedBox(height: 5),
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
