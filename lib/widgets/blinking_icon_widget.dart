import 'package:flutter/material.dart';

class BlinkingIconWidget extends StatefulWidget {
  final IconData icon;
  final double size;
  final Duration duration;
  final Color color;

  const BlinkingIconWidget({
    super.key,
    required this.icon,
    required this.size,
    this.color = Colors.red,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<BlinkingIconWidget> createState() => _BlinkingIconWidgetState();
}

class _BlinkingIconWidgetState extends State<BlinkingIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: widget.color,
      end: widget.color.withRed(255),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12),
              shape: BoxShape.rectangle,
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
