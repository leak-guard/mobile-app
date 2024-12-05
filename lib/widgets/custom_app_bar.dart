import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/strings.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leadingIcon;
  final VoidCallback? onLeadingTap;
  final Widget? trailingIcon;
  final VoidCallback? onTrailingTap;
  final VoidCallback? onTrailingLongPress;
  final VoidCallback? onUncollapse;
  final List<Widget>? bottomWidgets;
  final double height;
  final double trailingDepth;

  const CustomAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.onLeadingTap,
    this.trailingIcon,
    this.onTrailingTap,
    this.trailingDepth = 5,
    this.bottomWidgets,
    this.height = 120,
    this.onTrailingLongPress,
    this.onUncollapse,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isTrailingCollapsed = false;

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
                  onPressed: widget.onLeadingTap,
                  child: widget.leadingIcon ?? const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      textAlign: TextAlign.center,
                      widget.title ?? MyStrings.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                GestureDetector(
                  onLongPress: () {
                    if (widget.onTrailingLongPress != null) {
                      widget.onTrailingLongPress!();
                      _isTrailingCollapsed = true;
                    }
                  },
                  child: NeumorphicButton(
                    padding: const EdgeInsets.all(8),
                    minDistance: -3,
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(10)),
                      depth: _isTrailingCollapsed
                          ? -widget.trailingDepth
                          : widget.trailingDepth,
                    ),
                    onPressed: widget.onTrailingTap == null
                        ? null
                        : () {
                            if (_isTrailingCollapsed) {
                              if (widget.onUncollapse != null) {
                                widget.onUncollapse!();
                                _isTrailingCollapsed = false;
                              }
                              return;
                            }

                            if (widget.onTrailingTap != null) {
                              widget.onTrailingTap!();
                            }
                          },
                    child: widget.trailingIcon ??
                        const SizedBox(
                          height: 30,
                          width: 30,
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.bottomWidgets != null) ...widget.bottomWidgets!,
        ],
      ),
    );
  }
}
