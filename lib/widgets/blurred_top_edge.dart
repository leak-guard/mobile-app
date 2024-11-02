import 'package:flutter/material.dart';
import 'package:leak_guard/utils/colors.dart';

class BlurredTopEdge extends StatelessWidget {
  final Widget child;
  final double height;

  const BlurredTopEdge({
    required this.child,
    this.height = 50.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MyColors.background,
                MyColors.background.withOpacity(0.9),
                MyColors.background.withOpacity(0.6),
                MyColors.background.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
