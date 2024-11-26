//TODO: to delete

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/widgets/app_bar.dart';

const Color _blue = Color(0xff3da8fc);
const Color _gray = Color(0xfff4f4f4);
const Color _orange = Color(0xfff6813a);
const Color _green = Color(0xff4ecca3);
const double _circularProgressSize = 0.3;

class ArcTestScreen extends StatefulWidget {
  const ArcTestScreen({super.key});

  @override
  State<ArcTestScreen> createState() => _ArcTestScreenState();
}

class _ArcTestScreenState extends State<ArcTestScreen> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: "Arc Test Screen",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Arc test screen"),
            const SizedBox(height: 20),
            CircularProgressWidget(
              progress: _progress,
            ),
          ],
        ),
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
          child: Icon(Icons.add),
          tooltip: 'Increment',
          onPressed: () {
            setState(() {
              _progress += 0.1;

              if (_progress > 1.0) {
                _progress = 0.0;
              }
              print(_progress);
            });
          }),
    );
  }
}

class CircularProgressWidget extends StatefulWidget {
  final double progress;
  const CircularProgressWidget({super.key, required this.progress});

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<double>? _progressTweenAnimation;
  final double _strokeWidth = 16;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _progressTweenAnimation = Tween<double>(begin: 0, end: widget.progress)
        .animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant CircularProgressWidget oldWidget) {
    _animationController.reset();
    _progressTweenAnimation =
        Tween<double>(begin: oldWidget.progress, end: widget.progress)
            .animate(_animationController)
          ..addListener(() {});

    _animationController.forward();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width * _circularProgressSize + _strokeWidth,
      height: size.width * _circularProgressSize + _strokeWidth,
      child: CustomPaint(
        painter: ArcProgressPainter(
            circularProgressSize: size.width * _circularProgressSize,
            progress: _progressTweenAnimation?.value ?? 0,
            strokeWidth: _strokeWidth),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CircularProgressPainter extends CustomPainter {
  final double circularProgressSize;
  final double progress;
  final double strokeWidth;
  double _onePercentageToRadian = 0.01 * 2 * pi;

  CircularProgressPainter(
      {required this.circularProgressSize,
      required this.progress,
      this.strokeWidth = 16});

  @override
  void paint(Canvas canvas, Size size) {
    double offSet = (circularProgressSize + strokeWidth) / 2;

    final paintBackground = Paint()
      ..strokeWidth = strokeWidth
      ..color = _gray
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..strokeWidth = strokeWidth
      ..color = _green
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
        Offset(offSet, offSet), circularProgressSize / 2, paintBackground);

    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(offSet, offSet),
            width: circularProgressSize,
            height: circularProgressSize),
        3 * pi / 2,
        _convertPercentageToRadian(),
        false,
        paintProgress);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _convertPercentageToRadian() {
    return _onePercentageToRadian * progress * 100;
  }
}

class ArcProgressPainter extends CustomPainter {
  final double circularProgressSize;
  final double progress;
  final double strokeWidth;
  double _onePercentageToRadian = (3 * pi / 2) / 100;

  ArcProgressPainter(
      {required this.circularProgressSize,
      required this.progress,
      this.strokeWidth = 16});

  @override
  void paint(Canvas canvas, Size size) {
    double offSet = (circularProgressSize + strokeWidth) / 2;

    final paintBackground = Paint()
      ..strokeWidth = strokeWidth
      ..color = _gray
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..strokeWidth = strokeWidth
      ..color = _orange
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(offSet, offSet),
            width: circularProgressSize,
            height: circularProgressSize),
        3 * pi / 4,
        3 * pi / 2,
        false,
        paintBackground);

    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(offSet, offSet),
            width: circularProgressSize,
            height: circularProgressSize),
        3 * pi / 4,
        _convertPercentageToRadian(),
        false,
        paintProgress);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _convertPercentageToRadian() {
    return _onePercentageToRadian * progress * 100;
  }
}
