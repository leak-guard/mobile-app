import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/central_unit_widget.dart';
import 'package:leak_guard/widgets/photo_widget.dart';

class DetailsGroupScreen extends StatefulWidget {
  const DetailsGroupScreen({super.key, required this.group});
  final Group group;

  @override
  State<DetailsGroupScreen> createState() => _DetailsGroupScreenState();
}

class _DetailsGroupScreenState extends State<DetailsGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _db = DatabaseService.instance;
  final _appData = AppData();
  bool _isValid = true;
  bool _centralChoosen = false;

  late String? _initialImagePath;
  late String _initialDescription;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description ?? '';

    for (var central in _appData.centralUnits) {
      central.chosen = widget.group.centralUnits.contains(central);
    }

    _initialImagePath = widget.group.imagePath;
    _initialDescription = widget.group.description ?? '';
  }

  bool _hasUnsavedChanges() {
    bool imagePathDif = widget.group.imagePath != _initialImagePath;
    bool nameDif = widget.group.name != _nameController.text.trim();
    bool descriptionDif =
        _initialDescription != _descriptionController.text.trim();
    bool centralUnitsDif =
        widget.group.centralUnits.length != chosenCentrals.length;
    bool centralUnitsContentDif =
        widget.group.centralUnits.any((c) => !chosenCentrals.contains(c));

    return imagePathDif ||
        nameDif ||
        descriptionDif ||
        centralUnitsDif ||
        centralUnitsContentDif;
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Unsaved Changes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'You have unsaved changes. Do you want to save them before leaving?',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            ),
            onPressed: () {
              widget.group.imagePath = _initialImagePath;
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Discard',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Save',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveChanges();
    }

    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

    for (var central in _appData.centralUnits) {
      central.chosen = false;
    }
    super.dispose();
  }

  List<CentralUnit> get chosenCentrals =>
      _appData.centralUnits.where((central) => central.chosen).toList();

  Future<void> _saveChanges() async {
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
      widget.group.name = _nameController.text.trim();
      widget.group.description = _descriptionController.text.trim();

      await _db.updateGroup(widget.group);

      final currentCentralIds =
          widget.group.centralUnits.map((c) => c.centralUnitID!).toSet();
      final newCentralIds = chosenCentrals.map((c) => c.centralUnitID!).toSet();

      for (var id in currentCentralIds.difference(newCentralIds)) {
        await _db.removeCentralUnitFromGroup(widget.group.groupdID!, id);
      }

      for (var id in newCentralIds.difference(currentCentralIds)) {
        await _db.addCentralUnitToGroup(widget.group.groupdID!, id);
      }

      widget.group.centralUnits = chosenCentrals;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating group: $e')),
        );
      }
    }
  }

  void _confirmDelete() async {
    await _db.deleteGroup(widget.group.groupdID!);
    _appData.groups.remove(widget.group);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _deleteGroup(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete group',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              color: Colors.red[300],
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (mounted) {
                Navigator.pop(context);
              }
              onConfirm();
            },
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: Text(message, style: Theme.of(context).textTheme.displaySmall),
        actions: [
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child:
                Text('Close', style: Theme.of(context).textTheme.displaySmall),
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
    final groupCentrals = _appData.centralUnits
        .where((c) => widget.group.centralUnits.contains(c))
        .toList();
    final otherCentrals = _appData.centralUnits
        .where((c) => !widget.group.centralUnits.contains(c))
        .toList();

    return [
      ...groupCentrals.map((central) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: CentralUnitWidget(
              central: central,
              onPressed: () => setState(() => central.chosen = !central.chosen),
              onLongPress: () async {
                if (_centralChoosen) return;
                _centralChoosen = true;
                await central.refreshConfig();

                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    Routes.detailsCentralUnit,
                    arguments: DetailsCentralUnitScreenArguments(
                      central,
                    ),
                  ).then((_) {
                    setState(() {
                      _centralChoosen = false;
                    });
                  });
                }
              },
            ),
          )),
      ...otherCentrals.map((central) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: CentralUnitWidget(
              central: central,
              onPressed: () => setState(() => central.chosen = !central.chosen),
              onLongPress: () async {
                if (_centralChoosen) return;
                _centralChoosen = true;
                central.refreshConfig();

                Navigator.pushNamed(
                  context,
                  Routes.detailsCentralUnit,
                  arguments: DetailsCentralUnitScreenArguments(
                    central,
                  ),
                ).then((_) {
                  setState(() {
                    _centralChoosen = false;
                  });
                });
              },
            ),
          )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () {
          _onWillPop().then((onValue) {
            if (onValue) {
              // ignore: use_build_context_synchronously
              if (mounted) Navigator.pop(context);
            }
          });
        },
        title: 'Edit ${widget.group.name}',
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: () {
          _saveChanges().then((_) {
            // ignore: use_build_context_synchronously
            if (mounted) Navigator.pop(context);
          });
        },
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
                      g.name.toLowerCase() == value.trim().toLowerCase() &&
                      g.groupdID != widget.group.groupdID)) {
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
                item: widget.group,
                size: MediaQuery.of(context).size.width - 32,
                onPhotoChanged: () {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Text('Central units',
                  style: Theme.of(context).textTheme.displayMedium),
              ..._buildCentralUnitsList(),
              const SizedBox(height: 12),
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: 5,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _deleteGroup(_confirmDelete),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Delete group',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.delete_outline),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
