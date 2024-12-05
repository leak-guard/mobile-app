import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/models/time_zone.dart';
import 'package:leak_guard/utils/time_zone_helper.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';

class TimeZoneDropdown extends StatefulWidget {
  final Function(TimeZone) onTimeZoneSelected;
  final CentralUnit? centralUnit;

  const TimeZoneDropdown({
    super.key,
    required this.onTimeZoneSelected,
    this.centralUnit,
  });

  @override
  State<TimeZoneDropdown> createState() => _TimeZoneDropdownState();
}

class _TimeZoneDropdownState extends State<TimeZoneDropdown> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  late TimeZone _selectedTimeZone;

  @override
  void initState() {
    super.initState();
    if (widget.centralUnit != null) {
      _selectedTimeZone = TimeZoneHelper.getCurrentTimeZonebyId(
          widget.centralUnit!.timezoneId ?? 37);
    } else {
      _selectedTimeZone = TimeZoneHelper.getCurrentTimeZone();
    }

    _controller.text = _selectedTimeZone.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildListContent() {
    final timeZones = TimeZoneHelper.timeZones;
    timeZones.sort((a, b) => a.compareTo(b));
    return SizedBox(
      height: 150,
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
          itemCount: timeZones.length,
          itemBuilder: (context, index) {
            final timeZone = timeZones[index];
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
                  _selectedTimeZone = timeZone;
                  _controller.text = timeZone.toString();
                  _isExpanded = false;
                });
                widget.onTimeZoneSelected(timeZone);
              },
              child: Text(
                timeZone.toString(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _controller,
                readOnly: true,
                hintText: 'Select timezone...',
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
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
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
}
