import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/colors.dart';

class WifiDropdown extends StatefulWidget {
  final TextEditingController controller;
  final List<String> availableNetworks;
  final Function(String)? onSSIDSelected;

  const WifiDropdown({
    super.key,
    required this.controller,
    required this.availableNetworks,
    this.onSSIDSelected,
  });

  @override
  State<WifiDropdown> createState() => _WifiDropdownState();
}

class _WifiDropdownState extends State<WifiDropdown>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _heightAnimation = Tween<double>(
      begin: 0,
      end: 150,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildListContent() {
    if (widget.availableNetworks.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 32,
                  color: MyColors.lightThemeFont.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No WiFi networks found',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: MyColors.lightThemeFont.withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      padding: const EdgeInsets.all(8),
      thickness: 4,
      radius: const Radius.circular(2),
      thumbColor: MyColors.lightThemeFont.withOpacity(0.3),
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: widget.availableNetworks.length,
        itemBuilder: (context, index) {
          final network = widget.availableNetworks[index];
          return NeumorphicButton(
            style: NeumorphicStyle(
              depth: 0,
              intensity: 0,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(0),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            onPressed: () {
              setState(() {
                widget.controller.text = network;
              });
              widget.onSSIDSelected?.call(network);
            },
            child: Row(
              children: [
                const Icon(Icons.wifi),
                const SizedBox(width: 12),
                Text(
                  network,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: -5,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Select WiFi network...',
                    hintStyle: TextStyle(
                      color: MyColors.lightThemeFont.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            NeumorphicButton(
              padding: const EdgeInsets.all(8),
              style: NeumorphicStyle(
                depth: 5,
                intensity: 0.8,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isExpanded ? 0.5 : 0.0,
                child: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _heightAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: BoxConstraints(
                maxHeight: _heightAnimation.value,
              ),
              child: child,
            );
          },
          child: Neumorphic(
            style: NeumorphicStyle(
              depth: -5,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(12),
              ),
            ),
            child: _buildListContent(),
          ),
        ),
      ],
    );
  }
}
