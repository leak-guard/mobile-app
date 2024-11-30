import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/water_usage_data.dart';
import 'package:leak_guard/utils/colors.dart';

class GraphWaterUsage extends StatefulWidget {
  final List<WaterUsageData> data;
  final double maxHeight;
  final Duration animationDuration;

  const GraphWaterUsage({
    super.key,
    required this.data,
    this.maxHeight = 200,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<GraphWaterUsage> createState() => _GraphWaterUsageState();
}

class _GraphWaterUsageState extends State<GraphWaterUsage> {
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _shouldAnimate = true;
      });
    });
  }

  double getFontSize(double waterUsage) {
    if (waterUsage < 100) {
      return 9;
    } else if (waterUsage < 1000) {
      return 8;
    } else if (waterUsage < 10000) {
      return 7;
    } else {
      return 6;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox();

    double maxUsage =
        widget.data.map((d) => d.usage).reduce((a, b) => a > b ? a : b);
    if (maxUsage == 0) maxUsage = 12;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 32) / widget.data.length - 8;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Max usage: ${(maxUsage * 100).roundToDouble() / 100}l",
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: widget.maxHeight + 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.data.map((item) {
                  final targetHeight =
                      (item.usage / maxUsage) * widget.maxHeight;
                  final currentHeight = _shouldAnimate ? targetHeight : 0.0;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          duration: widget.animationDuration,
                          opacity: _shouldAnimate ? 1.0 : 0.0,
                          child: Text(
                            '${(item.usage * 10).roundToDouble() / 10}',
                            style: TextStyle(
                              color: MyColors.blue,
                              fontSize: getFontSize(item.usage),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: widget.animationDuration,
                          curve: Curves.easeInOut,
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              depth: 1,
                              intensity: 0.7,
                              surfaceIntensity: 0.5,
                              shadowLightColorEmboss: Colors.white,
                              color: MyColors.blue,
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(16),
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: widget.animationDuration,
                              curve: Curves.easeInOut,
                              width: barWidth,
                              height: currentHeight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          duration: widget.animationDuration,
                          opacity: _shouldAnimate ? 1.0 : 0.0,
                          child: Text(
                            item.hour.toString(),
                            style: TextStyle(
                              color: MyColors.darkShadow,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
