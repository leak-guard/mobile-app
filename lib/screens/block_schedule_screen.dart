import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/block_schedule.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:leak_guard/widgets/block_clock_widget.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';

class BlockScheduleScreen extends StatefulWidget {
  const BlockScheduleScreen({super.key, required this.group});
  final Group group;

  @override
  State<BlockScheduleScreen> createState() => _BlockScheduleScreenState();
}

class _BlockScheduleScreenState extends State<BlockScheduleScreen> {
  late Map<String, BlockDay> _blockSchedule;
  int scheduleDayIndex = 0;

  @override
  void initState() {
    BlockDay blockDayForAll;
    DateTime dateTime = DateTime.now();
    if (dateTime.weekday == DateTime.monday) {
      blockDayForAll = widget.group.blockSchedule.monday;
      scheduleDayIndex = 1;
    } else if (dateTime.weekday == DateTime.tuesday) {
      blockDayForAll = widget.group.blockSchedule.tuesday;
      scheduleDayIndex = 2;
    } else if (dateTime.weekday == DateTime.wednesday) {
      blockDayForAll = widget.group.blockSchedule.wednesday;
      scheduleDayIndex = 3;
    } else if (dateTime.weekday == DateTime.thursday) {
      blockDayForAll = widget.group.blockSchedule.thursday;
      scheduleDayIndex = 4;
    } else if (dateTime.weekday == DateTime.friday) {
      blockDayForAll = widget.group.blockSchedule.friday;
      scheduleDayIndex = 5;
    } else if (dateTime.weekday == DateTime.saturday) {
      blockDayForAll = widget.group.blockSchedule.saturday;
      scheduleDayIndex = 6;
    } else {
      blockDayForAll = widget.group.blockSchedule.sunday;
      scheduleDayIndex = 0;
    }

    _blockSchedule = {
      'Sun': widget.group.blockSchedule.sunday,
      'Mon': widget.group.blockSchedule.monday,
      'Tue': widget.group.blockSchedule.tuesday,
      'Wed': widget.group.blockSchedule.wednesday,
      'Thu': widget.group.blockSchedule.thursday,
      'Fri': widget.group.blockSchedule.friday,
      'Sat': widget.group.blockSchedule.saturday,
      'All': blockDayForAll,
    };
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    BlockDayEnum targetDay = BlockDayEnum.values[scheduleDayIndex];

    List<NeumorphicButton> buttons = _blockSchedule.keys.map((entry) {
      return NeumorphicButton(
        padding: const EdgeInsets.all(8),
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          depth:
              entry == _blockSchedule.keys.elementAt(scheduleDayIndex) ? -6 : 6,
        ),
        child: SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child: Text(entry,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall),
            )),
        onPressed: () {
          setState(() {
            scheduleDayIndex = _blockSchedule.keys.toList().indexOf(entry);
            if (scheduleDayIndex == 7) {
              CustomToast.toast('Changes will be applied to all days');
            }
          });
        },
      );
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: widget.group.name,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons.sublist(0, 4),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons.sublist(4),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: BlockClockWidget(group: widget.group, targetDay: targetDay),
          )
        ],
      ),
    );
  }
}
