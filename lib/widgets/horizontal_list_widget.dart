import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/colors.dart';

class HorizontalListWidget extends StatefulWidget {
  const HorizontalListWidget({
    super.key,
    required this.groups,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final List<String> groups;
  final int selectedIndex;
  final Function(int) onIndexChanged;

  @override
  State<HorizontalListWidget> createState() => _HorizontalListWidgetState();
}

class _HorizontalListWidgetState extends State<HorizontalListWidget> {
  late ScrollController _scrollController;
  final List<GlobalKey> _keys = [];

  static const double ITEM_HORIZONTAL_PADDING = 8.0;
  static const double BUTTON_HORIZONTAL_PADDING = 20.0;
  static const double ITEM_VERTICAL_PADDING = 10.0;
  static const double BUTTON_VERTICAL_PADDING = 5.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(widget.selectedIndex);
    });
  }

  @override
  void didUpdateWidget(HorizontalListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groups.length != oldWidget.groups.length) {
      _initializeKeys();
    }
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollToIndex(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeKeys() {
    _keys.clear();
    for (int i = 0; i < widget.groups.length; i++) {
      _keys.add(GlobalKey());
    }
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      double itemOffset = ITEM_HORIZONTAL_PADDING * 2;

      for (int i = 0; i <= index; i++) {
        final RenderBox? box =
            _keys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          if (i < index) {
            itemOffset += box.size.width + (ITEM_HORIZONTAL_PADDING * 2);
          } else if (i == index) {
            itemOffset += box.size.width / 2;
          }
        }
      }

      final offset = itemOffset - (screenWidth / 2);

      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _initializeKeys();

    return SizedBox(
      height: 50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: ITEM_HORIZONTAL_PADDING),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.groups.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ITEM_HORIZONTAL_PADDING,
                          vertical: ITEM_VERTICAL_PADDING,
                        ),
                        child: NeumorphicButton(
                          key: _keys[index],
                          onPressed: () {
                            widget.onIndexChanged(index);
                            _scrollToIndex(index);
                          },
                          style: NeumorphicStyle(
                            depth: widget.selectedIndex == index ? 4 : -4,
                            intensity: 0.6,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12),
                            ),
                            lightSource: LightSource.topLeft,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: BUTTON_HORIZONTAL_PADDING,
                            vertical: BUTTON_VERTICAL_PADDING,
                          ),
                          child: Text(
                            widget.groups[index],
                            style: TextStyle(
                              color: widget.selectedIndex == index
                                  ? MyColors.lightThemeFont
                                  : MyColors.darkShadow,
                              fontWeight: widget.selectedIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
