import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/add_unit_button.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/central_unit_widget.dart';
import 'package:leak_guard/widgets/photo_widget.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValid = true;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _db = DatabaseService.instance;
  final _appData = AppData();
  final newGroup = Group(name: '');

  List<CentralUnit> get chosenCentrals =>
      _appData.centralUnits.where((central) => central.chosen).toList();

  @override
  void dispose() {
    for (var central in _appData.centralUnits) {
      central.chosen = false;
    }
    _nameController.dispose();
    _descriptionController.dispose();
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
        'No central units',
        'Please select at least one central unit for the group',
      );
      return;
    }

    try {
      newGroup.name = _nameController.text.trim();
      newGroup.description = _descriptionController.text.trim();
      final groupId = await _db.addGroup(newGroup);
      _appData.groups.add(newGroup);
      newGroup.groupdID = groupId;

      for (var central in chosenCentrals) {
        await _db.addCentralUnitToGroup(groupId, central.centralUnitID!);
        central.leakProbes =
            await _db.getCentralUnitLeakProbes(central.centralUnitID!);
        newGroup.centralUnits.add(central);
      }
      newGroup.blockSchedule = chosenCentrals.first.blockSchedule;
      newGroup.updateBlockStatus();
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

  void _showValidationError(String title, String message) {
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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<Widget> _buildCentralUnitsList() {
    return _appData.centralUnits.map((central) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CentralUnitWidget(
          central: central,
          onPressed: () {
            setState(() {
              central.chosen = !central.chosen;
            });
          },
          onLongPress: () async {
            await central.refreshConfig();
            if (mounted) {
              Navigator.pushNamed(
                context,
                Routes.detailsCentralUnit,
                arguments: DetailsCentralUnitScreenArguments(
                  central,
                ),
              ).then((_) {
                setState(() {});
              });
            }
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () => Navigator.pop(context),
        title: MyStrings.createGroup,
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: _createGroup,
      ),
      body: BlurredTopWidget(
        height: 20,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Group name',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter group name...',
                validator: (value) {
                  String? errorMessage;
                  if (value == null || value.trim().isEmpty) {
                    errorMessage = 'Please enter a group name';
                  } else if (_appData.groups.any((g) =>
                      g.name.toLowerCase() == value.trim().toLowerCase())) {
                    errorMessage = 'Group name already exists';
                  }

                  if (errorMessage != null) {
                    Future.microtask(() {
                      setState(() => _isValid = false);
                      _showValidationError('Wrong group name', errorMessage!);
                    });
                  } else {
                    setState(() => _isValid = true);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Description',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Enter description...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Photo', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              PhotoWidget(
                item: newGroup,
                size: MediaQuery.of(context).size.width - 32,
                onPhotoChanged: () {
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
              Text('Chose central units',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              AddUnitButton(
                onBack: () => setState(() {}),
              ),
              const SizedBox(height: 8),
              ..._buildCentralUnitsList(),
            ],
          ),
        ),
      ),
    );
  }
}
