import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/add_new_unit_button.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:leak_guard/widgets/central_unit_button.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValid = true;
  final _nameController = TextEditingController();
  final _db = DatabaseService.instance;
  final _appData = AppData();

  List<CentralUnit> get chosenCentrals =>
      _appData.centralUnits.where((central) => central.chosen).toList();

  @override
  void dispose() {
    for (var central in _appData.centralUnits) {
      central.chosen = false;
    }
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    bool? isFormValid = _formKey.currentState?.validate();

    await Future.microtask(() => null);

    if (isFormValid != true || !_isValid) {
      return;
    }

    if (chosenCentrals.isEmpty) {
      _showValidationError(
        context,
        'No central units',
        'Please select at least one central unit for the group',
      );
      return;
    }

    try {
      final newGroup = Group(name: _nameController.text.trim());
      final groupId = await _db.addGroup(newGroup);
      newGroup.groupdID = groupId;

      for (var central in chosenCentrals) {
        await _db.addCentralUnitToGroup(groupId, central.centralUnitID!);
        central.leakProbes =
            await _db.getCentralUnitLeakProbes(central.centralUnitID!);
        newGroup.centralUnits.add(central);
      }

      _appData.groups.add(newGroup);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  void _showValidationError(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () => Navigator.pop(context),
        title: MyStrings.createGroup,
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: _createGroup,
      ),
      body: BlurredTopEdge(
        height: 20,
        child: Form(
          key: _formKey,
          child: ListView.builder(
            itemCount: _appData.centralUnits.length + 4,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text('Group name',
                      style: Theme.of(context).textTheme.displayMedium),
                );
              }

              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                      controller: _nameController,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter group name...',
                        hintStyle: TextStyle(
                            color: MyColors.lightThemeFont.withOpacity(0.5)),
                      ),
                      validator: (value) {
                        String? errorMessage;
                        if (value == null || value.trim().isEmpty) {
                          errorMessage = 'Please enter a group name';
                        } else if (_appData.groups.any((g) =>
                            g.name.toLowerCase() ==
                            value.trim().toLowerCase())) {
                          errorMessage = 'Group name already exists';
                        }

                        if (errorMessage != null) {
                          Future.microtask(() {
                            setState(() => _isValid = false);
                            _showValidationError(
                                context, 'Wrong group name', errorMessage!);
                          });
                        } else {
                          setState(() => _isValid = true);
                        }
                        return null;
                      },
                    ),
                  ),
                );
              }

              if (index == 2) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text('Chose central units',
                      style: Theme.of(context).textTheme.displayMedium),
                );
              }

              if (index == 3) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: AddNewUnitButton(
                    onBack: () => setState(() {}),
                  ),
                );
              }

              final central = _appData.centralUnits[index - 4];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: CentralUnitButton(
                  central: central,
                  onPressed: () {
                    setState(() {
                      central.chosen = !central.chosen;
                    });
                  },
                  onLongPress: () {
                    Navigator.pushNamed(
                      context,
                      Routes.detailsCentral,
                      arguments: DetailsCentralcreenArguments(
                        central,
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
