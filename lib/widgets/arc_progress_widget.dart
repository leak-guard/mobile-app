import 'dart:math';

import 'package:flutter/widgets.dart';

class ArcProgressWidget extends StatefulWidget {
  final double progress;
  final double size;
  final Color color;
  const ArcProgressWidget(
      {super.key,
      required this.progress,
      required this.size,
      required this.color});

  @override
  State<ArcProgressWidget> createState() => _ArcProgressWidgetState();
}

class _ArcProgressWidgetState extends State<ArcProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationProgressController;
  late AnimationController _animationColorController;
  Animation<double>? _progressTweenAnimation;
  Animation<Color?>? _colorTweenAnimation; // Dodajemy animację koloru
  final double _strokeWidth = 16;

  @override
  void initState() {
    _animationProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animationColorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _progressTweenAnimation = Tween<double>(begin: 0, end: widget.progress)
        .animate(_animationProgressController)
      ..addListener(() {
        setState(() {});
      });

    _colorTweenAnimation = ColorTween(
      begin: widget.color,
      end: widget.color,
    ).animate(_animationColorController);

    _animationProgressController.forward();
    _animationColorController.forward();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ArcProgressWidget oldWidget) {
    _animationProgressController.reset();
    _animationColorController.reset();

    _progressTweenAnimation =
        Tween<double>(begin: oldWidget.progress, end: widget.progress)
            .animate(_animationProgressController)
          ..addListener(() {
            setState(() {});
          });

    _colorTweenAnimation = ColorTween(
      begin: oldWidget.color,
      end: widget.color,
    ).animate(_animationColorController);

    _animationProgressController.forward();
    _animationColorController.forward();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcProgressPainter(
        circularProgressSize: widget.size,
        progress: _progressTweenAnimation?.value ?? 0,
        strokeWidth: _strokeWidth,
        color: _colorTweenAnimation?.value ?? widget.color,
      ),
    );
  }

  @override
  void dispose() {
    _animationProgressController.dispose();
    _animationColorController.dispose();
    super.dispose();
  }
}

class ArcProgressPainter extends CustomPainter {
  final double circularProgressSize;
  final double progress;
  final double strokeWidth;
  final Color color;
  double _onePercentageToRadian = (3 * pi / 2) / 100;

  ArcProgressPainter({
    required this.circularProgressSize,
    required this.progress,
    required this.color,
    this.strokeWidth = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double offSet = (circularProgressSize + strokeWidth) / 2;

    final paintProgress = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

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
