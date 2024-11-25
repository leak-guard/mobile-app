import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/add_new_group_button.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:leak_guard/widgets/group_button.dart';

enum GroupManageMode {
  view,
  editName,
  editPosition,
  delete,
}

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  GroupManageMode _currentMode = GroupManageMode.view;
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, bool> _nameButtonStates = {};
  final _appData = AppData();
  final _db = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    for (var group in _appData.groups) {
      _nameControllers[group.groupdID!] =
          TextEditingController(text: group.name)
            ..addListener(() {
              setState(() {
                _nameButtonStates[group.groupdID!] = _confirmNameState(
                  group.name,
                  _nameControllers[group.groupdID!]!.text,
                );
              });
            });
      _nameButtonStates[group.groupdID!] = false;
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _confirmNameState(String name, String controllerText) {
    if (name == controllerText || controllerText.isEmpty) {
      return false;
    }
    return true;
  }

  Widget _buildManageButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: _currentMode == GroupManageMode.editName ? -3 : 3,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == GroupManageMode.editName
                    ? GroupManageMode.view
                    : GroupManageMode.editName;
              });
            },
            padding: const EdgeInsets.all(13),
            child: Icon(
              Icons.edit,
              color: MyColors.lightThemeFont,
              size: 25,
            ),
          ),
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: _currentMode == GroupManageMode.editPosition ? -3 : 3,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == GroupManageMode.editPosition
                    ? GroupManageMode.view
                    : GroupManageMode.editPosition;
              });
            },
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.swap_vert,
              color: MyColors.lightThemeFont,
              size: 30,
            ),
          ),
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: _currentMode == GroupManageMode.delete ? -3 : 3,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == GroupManageMode.delete
                    ? GroupManageMode.view
                    : GroupManageMode.delete;
              });
            },
            padding: const EdgeInsets.all(13),
            child: Icon(
              Icons.delete_outline,
              color: MyColors.lightThemeFont,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(Group group) {
    switch (_currentMode) {
      case GroupManageMode.view:
        return _buildViewTile(group);
      case GroupManageMode.editName:
        return _buildEditNameTile(group);
      case GroupManageMode.editPosition:
        return _buildPositionTile(group);
      case GroupManageMode.delete:
        return _buildDeleteTile(group);
    }
  }

  Widget _buildViewTile(Group group) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GroupButton(group: group, onPressed: () {}),
      // TODO: delete this
      // Neumorphic(
      //   style: NeumorphicStyle(
      //     depth: 5,
      //     intensity: 0.8,
      //     boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      //   ),
      //   child: Padding(
      //     padding: const EdgeInsets.all(16),
      //     child: Column(
      //       children: [
      //         Text(
      //           group.name,
      //           style: Theme.of(context).textTheme.displayMedium,
      //           maxLines: 1,
      //           overflow: TextOverflow.ellipsis,
      //         ),
      //         const SizedBox(height: 8),
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             _buildInfoColumn(
      //               CustomIcons.leak_probe,
      //               group.leakProbeNumber().toString(),
      //               24,
      //             ),
      //             _buildInfoColumn(CustomIcons.battery_low,
      //                 group.leakProbeLowBatteryNumber().toString(), 18,
      //                 iconVerticalMargin: 3),
      //             _buildInfoColumn(CustomIcons.central_unit,
      //                 group.centralUnitsNumber().toString(), 24),
      //             _buildInfoColumn(CustomIcons.broken_pipe,
      //                 group.centralUnitsLeaksNumber().toString(), 20,
      //                 iconVerticalMargin: 2),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, double iconSize,
      {double iconVerticalMargin = 0}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: iconVerticalMargin),
          child: NeumorphicIcon(
            icon,
            size: iconSize,
            style: NeumorphicStyle(color: MyColors.blue),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: MyColors.blue,
              ),
        ),
      ],
    );
  }

  Widget _buildEditNameTile(Group group) {
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
                child: SizedBox(
                  height: 36,
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: -5,
                      intensity: 0.8,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(8)),
                    ),
                    child: TextFormField(
                      controller: _nameControllers[group.groupdID!],
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(fontSize: 16),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: 5,
                  intensity: 0.8,
                  disableDepth: !_nameButtonStates[group.groupdID]!,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                ),
                onPressed: _nameButtonStates[group.groupdID]!
                    ? () {
                        setState(() {
                          group.name = _nameControllers[group.groupdID]!.text;
                          _db.updateGroup(group);
                          _nameButtonStates[group.groupdID!] = false;
                        });
                      }
                    : null,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.check,
                  color: _nameButtonStates[group.groupdID]!
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

  Widget _buildDeleteTile(Group group) {
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
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: 5,
                  intensity: 0.8,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() {
                    _db.deleteGroup(group.groupdID!);
                    _appData.groups.remove(group);
                  });
                },
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.delete_outline,
                  color: MyColors.lightThemeFont,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddGroupButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: AddNewGroupButton(
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
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: MyStrings.manageGroups,
      ),
      body: BlurredTopEdge(
        height: 20,
        child: ListView.builder(
          itemCount: _appData.groups.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  SizedBox(height: 8),
                  _buildAddGroupButton(),
                ],
              );
            }
            if (index == 1) {
              return _buildManageButtons();
            }
            return _buildGroupTile(_appData.groups[index - 2]);
          },
        ),
      ),
    );
  }
}
