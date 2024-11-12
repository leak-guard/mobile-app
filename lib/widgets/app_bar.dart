import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/strings.dart';

class CustomNeumorphicAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Widget? leadingIcon;
  final VoidCallback? onLeadingTap;
  final Widget? trailingIcon;
  final VoidCallback? onTrailingTap;
  final List<Widget>? bottomWidgets;
  final double height;

  const CustomNeumorphicAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.onLeadingTap,
    this.trailingIcon,
    this.onTrailingTap,
    this.bottomWidgets,
    this.height = 120,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return NeumorphicAppBar(
      padding: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      actionSpacing: 0,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeumorphicButton(
                  padding: const EdgeInsets.all(8),
                  minDistance: -3,
                  style: NeumorphicStyle(
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                    depth: 5,
                  ),
                  onPressed: onLeadingTap,
                  child: leadingIcon ?? const Icon(Icons.arrow_back),
                ),
                Text(
                  title ?? MyStrings.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                NeumorphicButton(
                  padding: const EdgeInsets.all(8),
                  minDistance: -3,
                  style: NeumorphicStyle(
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                    depth: 5,
                  ),
                  onPressed: onTrailingTap,
                  child: trailingIcon ??
                      const SizedBox(
                        height: 30,
                        width: 30,
                      ),
                ),
              ],
            ),
          ),
          if (bottomWidgets != null) ...bottomWidgets!,
        ],
      ),
    );
  }
}
