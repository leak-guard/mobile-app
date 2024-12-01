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
              child: Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            ),
          ],
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: -5,
                intensity: 0.8,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              child: ListView.builder(
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
            ),
          ),
      ],
    );
  }
}
