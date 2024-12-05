import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/add_group_button.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/group_widget.dart';

enum GroupManageMode {
  view,
  editPosition,
}

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  GroupManageMode _currentMode = GroupManageMode.view;
  final _appData = AppData();
  final _db = DatabaseService.instance;

  Widget _buildGroupTile(Group group) {
    switch (_currentMode) {
      case GroupManageMode.view:
        return _buildViewTile(group);
      case GroupManageMode.editPosition:
        return _buildPositionTile(group);
    }
  }

  Widget _buildViewTile(Group group) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GroupWidget(
        group: group,
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.detailsGroup,
            arguments: DetailsGroupScreenArguments(
              group,
            ),
          ).then((_) {
            setState(() {});
          });
        },
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget _buildAddGroupButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: AddGroupButton(
        onBack: () => setState(() {}),
      ),
    );
  }

  Widget _buildPositionTile(Group group) {
    final currentIndex = _appData.groups.indexOf(group);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 5,
          intensity: 0.8,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.displayMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: currentIndex > 0 ? 5 : 2,
                  intensity: 0.8,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                ),
                onPressed: currentIndex > 0
                    ? () => _moveGroupUp(group, currentIndex)
                    : null,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_upward,
                  color: currentIndex > 0
                      ? MyColors.lightThemeFont
                      : MyColors.lightThemeFont.withOpacity(0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: currentIndex < _appData.groups.length - 1 ? 5 : 2,
                  intensity: 0.8,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                ),
                onPressed: currentIndex < _appData.groups.length - 1
                    ? () => _moveGroupDown(group, currentIndex)
                    : null,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_downward,
                  color: currentIndex < _appData.groups.length - 1
                      ? MyColors.lightThemeFont
                      : MyColors.lightThemeFont.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _moveGroupUp(Group group, int currentIndex) async {
    if (currentIndex <= 0) return;

    try {
      final previousGroup = _appData.groups[currentIndex - 1];

      await _db.swapGroupsPositions(
        group.groupdID!,
        previousGroup.groupdID!,
      );

      final tempPosition = group.position;
      group.position = previousGroup.position;
      previousGroup.position = tempPosition;

      setState(() {
        _appData.groups[currentIndex] = previousGroup;
        _appData.groups[currentIndex - 1] = group;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error moving group: $e')),
        );
      }
    }
  }

  Future<void> _moveGroupDown(Group group, int currentIndex) async {
    if (currentIndex >= _appData.groups.length - 1) return;

    try {
      final nextGroup = _appData.groups[currentIndex + 1];

      await _db.swapGroupsPositions(
        group.groupdID!,
        nextGroup.groupdID!,
      );

      final tempPosition = group.position;
      group.position = nextGroup.position;
      nextGroup.position = tempPosition;

      setState(() {
        _appData.groups[currentIndex] = nextGroup;
        _appData.groups[currentIndex + 1] = group;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error moving group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: MyStrings.manageGroups,
        onTrailingTap: () {
          setState(() {
            _currentMode = _currentMode == GroupManageMode.editPosition
                ? GroupManageMode.view
                : GroupManageMode.editPosition;
          });
        },
        trailingIcon: const Icon(Icons.swap_vert),
        trailingDepth: _currentMode == GroupManageMode.editPosition ? -3 : 5,
      ),
      body: BlurredTopWidget(
        height: 20,
        child: ListView.builder(
          itemCount: _appData.groups.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  _buildAddGroupButton(),
                ],
              );
            }
            return _buildGroupTile(_appData.groups[index - 1]);
          },
        ),
      ),
    );
  }
}
