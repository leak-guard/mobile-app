import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/water_usage_data.dart';
import 'package:leak_guard/utils/colors.dart';

class WaterUsageChart extends StatelessWidget {
  final List<WaterUsageData> data;
  final double maxHeight;

  const WaterUsageChart({
    super.key,
    required this.data,
    this.maxHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final maxUsage = data.map((d) => d.usage).reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 32) / data.length - 8;

        return Column(
          children: [
            SizedBox(
              height: maxHeight + 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  final height = (item.usage / maxUsage) * maxHeight;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${(item.usage * 10).roundToDouble() / 10}',
                        style: TextStyle(
                          color: MyColors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Neumorphic(
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
                        child: SizedBox(
                          width: barWidth,
                          height: height,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.hour.toString(),
                        style: TextStyle(
                          color: MyColors.darkShadow,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
