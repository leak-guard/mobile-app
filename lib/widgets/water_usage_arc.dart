import 'dart:math' as math;
import 'package:flutter/material.dart';
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

    // Zewnętrzny łuk
    path.addArc(
      Rect.fromCircle(center: center, radius: radius + thickness),
      startAngleRad,
      sweepAngleRad,
    );

    // Wewnętrzny łuk (w przeciwnym kierunku)
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
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  final double _thickness = 16;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1005),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.currentUsage / widget.maxUsage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WaterUsageArc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUsage != widget.currentUsage) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.currentUsage / oldWidget.maxUsage,
        end: widget.currentUsage / widget.maxUsage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
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
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: 5,
                      intensity: 0.8,
                      color: MyColors.blue,
                      boxShape: NeumorphicBoxShape.path(
                        ArcPathProvider(
                          sweepAngle: 280 * _progressAnimation.value,
                          thickness: _thickness,
                        ),
                      ),
                    ),
                  ),
                );
              },
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
