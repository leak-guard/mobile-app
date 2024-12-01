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

class _WifiDropdownState extends State<WifiDropdown> {
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();
  get _listHeight => widget.availableNetworks.length >= 3
      ? 150.0
      : widget.availableNetworks.length * 55.0;

  Widget _buildListContent() {
    if (widget.availableNetworks.isEmpty) {
      return SizedBox(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
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
          ],
        ),
      );
    }

    return SizedBox(
      height: _listHeight,
      child: RawScrollbar(
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
                widget.controller.text = network;
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
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isExpanded ? 158 : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
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
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
