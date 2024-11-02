import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'dart:math' as math;

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
