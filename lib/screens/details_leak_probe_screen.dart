import 'dart:async';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/widgets/blinking_icon_widget.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/photo_widget.dart';

class DetailsLeakProbeScreen extends StatefulWidget {
  const DetailsLeakProbeScreen({super.key, required this.leakProbe});
  final LeakProbe leakProbe;

  @override
  State<DetailsLeakProbeScreen> createState() => _DetailsLeakProbeScreenState();
}

class _DetailsLeakProbeScreenState extends State<DetailsLeakProbeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _db = DatabaseService.instance;
  final _appData = AppData();
  late String? _initialImagePath;
  late String _initialDescription;

  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.leakProbe.name;
    _descriptionController.text = widget.leakProbe.description ?? '';
    _initialImagePath = widget.leakProbe.imagePath;
    _initialDescription = widget.leakProbe.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    bool imagePathDif = widget.leakProbe.imagePath != _initialImagePath;
    bool nameDif = widget.leakProbe.name != _nameController.text.trim();
    bool descriptionDif =
        _initialDescription != _descriptionController.text.trim();

    return imagePathDif || nameDif || descriptionDif;
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
              widget.leakProbe.imagePath = _initialImagePath;
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

  Future<void> _saveChanges() async {
    bool? isFormValid = _formKey.currentState?.validate();

    await Future.microtask(() => null);

    if (isFormValid != true || !_isValid) {
      return;
    }

    try {
      widget.leakProbe.name = _nameController.text.trim();
      widget.leakProbe.description = _descriptionController.text.trim();

      await _db.updateLeakProbe(widget.leakProbe);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating leak probe: $e')),
        );
      }
    }
  }

  void _showDialog(String title, String message) {
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
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
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

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _nameController,
          hintText: 'Enter leak probe unit name...',
          validator: (value) {
            String? errorMessage;
            if (value == null || value.trim().isEmpty) {
              errorMessage = 'Please enter a name';
            } else if (_appData.leakProbes.any((l) =>
                l.name.toLowerCase() == value.trim().toLowerCase() &&
                l.leakProbeID != widget.leakProbe.leakProbeID)) {
              errorMessage = 'Leak probe with this name already exists';
            }

            if (errorMessage != null) {
              Future.microtask(() {
                setState(() => _isValid = false);
                _showDialog('Invalid name', errorMessage!);
              });
            } else {
              setState(() => _isValid = true);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Description',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _descriptionController,
          hintText: 'Enter description...',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Text('Photo', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 12),
        PhotoWidget(
          item: widget.leakProbe,
          size: MediaQuery.of(context).size.width - 32,
          onPhotoChanged: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHardwareSection() {
    String stmId = "";
    for (var id in widget.leakProbe.stmId) {
      stmId += id.toRadixString(16).toUpperCase();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leak probe number',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          widget.leakProbe.address.toString(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Hardware unic ID',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          stmId,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.leakProbe.blocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (context) {
              Timer(const Duration(seconds: 2), () {
                Navigator.of(context).pop();
              });
              return const Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: BlinkingIconWidget(
                    icon: CustomIcons.leak,
                    size: 120,
                    duration: Duration(milliseconds: 500),
                  ),
                ),
              );
            });
      });
    }
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () async {
          if (await _onWillPop()) {
            // ignore: use_build_context_synchronously
            if (mounted) Navigator.pop(context);
          }
        },
        title: 'Edit ${widget.leakProbe.name}',
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: () async {
          await _saveChanges();
          // ignore: use_build_context_synchronously
          if (mounted) Navigator.pop(context);
        },
      ),
      body: BlurredTopWidget(
        height: 20,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoSection(),
              _buildHardwareSection(),
            ],
          ),
        ),
      ),
    );
  }
}
