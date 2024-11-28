import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'dart:math' as math;

class ArcPathProvider extends NeumorphicPathProvider {
  final double startAngle;
  final double sweepAngle;
  final double thickness;

  ArcPathProvider({
    this.startAngle = 3 * pi / 4,
    this.sweepAngle = 3 * pi / 2,
    this.thickness = 30,
  });

  @override
  bool shouldReclip(NeumorphicPathProvider oldClipper) => true;

  @override
  Path getPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - thickness;

    final path = Path();

    path.addArc(
      Rect.fromCircle(center: center, radius: radius + thickness),
      startAngle,
      sweepAngle,
    );

    Offset centerEnd = Offset(
        center.dx +
            (radius + thickness / 2.0) * math.cos(startAngle + sweepAngle),
        center.dy +
            (radius + thickness / 2.0) * math.sin(startAngle + sweepAngle));

    path.arcTo(
      Rect.fromCircle(center: centerEnd, radius: thickness / 2.0),
      startAngle + sweepAngle,
      math.pi,
      false,
    );

    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle,
      -sweepAngle,
      false,
    );

    Offset centerStart = Offset(
        center.dx + (radius + thickness / 2.0) * math.cos(startAngle),
        center.dy + (radius + thickness / 2.0) * math.sin(startAngle));

    path.arcTo(
      Rect.fromCircle(center: centerStart, radius: thickness / 2.0),
      startAngle,
      -math.pi,
      false,
    );

    path.close();
    return path;
  }

  @override
  bool get oneGradientPerPath => true;
}
