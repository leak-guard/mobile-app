import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/services/api_service.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/custom_text_filed_decorator.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/photo_widget.dart';

class DetailsCentralUnitScreen extends StatefulWidget {
  const DetailsCentralUnitScreen({super.key, required this.central});
  final CentralUnit central;

  @override
  State<DetailsCentralUnitScreen> createState() =>
      _DetailsCentralUnitScreenState();
}

class _DetailsCentralUnitScreenState extends State<DetailsCentralUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ipController = TextEditingController();
  final _passwordController = TextEditingController();
  final _impulsesController = TextEditingController();

  final _db = DatabaseService.instance;
  final _appData = AppData();
  final _api = CustomApi();
  late String? _initialImagePath;
  late String _initialDescription;

  bool _isValid = true;
  bool _isCentralFound = false;
  bool _isValveNO = false;
  bool _isConfigurationChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.central.name;
    _descriptionController.text = widget.central.description ?? '';
    _ipController.text = widget.central.addressIP;
    _passwordController.text = widget.central.password;
    _impulsesController.text = widget.central.impulsesPerLiter.toString();
    _isValveNO = widget.central.isValveNO;
    _initialImagePath = widget.central.imagePath;
    _initialDescription = widget.central.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ipController.dispose();
    _passwordController.dispose();
    _impulsesController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    bool imagePathDif = widget.central.imagePath != _initialImagePath;
    bool nameDif = widget.central.name != _nameController.text.trim();
    bool descriptionDif =
        _initialDescription != _descriptionController.text.trim();

    return imagePathDif || nameDif || descriptionDif;
  }

  Future<void> _checkCentralUnit(String ip) async {
    setState(() {
      _isCentralFound = true;
    });
    final (macAddress, success) = await _api.getCentralMacAddress(ip);

    if (mounted) {
      if (success) {
        _showDialog(
            'Success', 'Connected to central unit with MAC:\n$macAddress');
      } else {
        _showDialog('Error', 'Could not connect to central unit at IP:\n$ip');
        setState(() {
          _isCentralFound = false;
        });
      }
    }
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
              widget.central.imagePath = _initialImagePath;
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
      widget.central.name = _nameController.text.trim();
      widget.central.description = _descriptionController.text.trim();

      await _db.updateCentralUnit(widget.central);

      if (_isConfigurationChanged) {
        // TODO: Implement sending configuration to central unit
        // here we will send the configuration to the central unit
        // if the configuration is changed
        // and save the new configuration in the database
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating central unit: $e')),
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

  Future<void> _sendConfiguration() async {
    //TODO: Implement sending configuration to central unit
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Central Unit Information',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Name',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        _buildNeumorphicTextField(
          controller: _nameController,
          hintText: 'Enter central unit name...',
          validator: (value) {
            String? errorMessage;
            if (value == null || value.trim().isEmpty) {
              errorMessage = 'Please enter a name';
            } else if (_appData.centralUnits.any((c) =>
                c.name.toLowerCase() == value.trim().toLowerCase() &&
                c.centralUnitID != widget.central.centralUnitID)) {
              errorMessage = 'Central unit with this name already exists';
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
        _buildNeumorphicTextField(
          controller: _descriptionController,
          hintText: 'Enter description...',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Text('Photo', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 12),
        PhotoWidget(
          item: widget.central,
          size: MediaQuery.of(context).size.width - 32,
          onPhotoChanged: () {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildHardwareConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hardware Configuration',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'IP Address',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNeumorphicTextField(
                controller: _ipController,
                hintText: 'IP Address',
                enabled: !_isCentralFound,
              ),
            ),
            const SizedBox(width: 8),
            NeumorphicButton(
              padding: const EdgeInsets.all(8),
              style: NeumorphicStyle(
                depth: !_isCentralFound ? 5 : 0,
                intensity: 0.8,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(8),
                ),
              ),
              onPressed: !_isCentralFound
                  ? () => _checkCentralUnit(_ipController.text)
                  : null,
              child: const Icon(
                Icons.search,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Impulses Per Liter',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNeumorphicTextField(
                controller: _impulsesController,
                hintText: 'Impulses per liter',
                keyboardType: TextInputType.number,
                onChanged: (_) =>
                    setState(() => _isConfigurationChanged = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Electrovalve Type',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Normally Closed",
                style: Theme.of(context).textTheme.displaySmall),
            NeumorphicSwitch(
              value: _isValveNO,
              style: NeumorphicSwitchStyle(
                trackDepth: 2,
                thumbDepth: 4,
                activeTrackColor: MyColors.lightThemeFont,
                inactiveTrackColor: MyColors.lightThemeFont.withOpacity(0.7),
                disableDepth: true,
              ),
              onChanged: (value) {
                setState(() {
                  _isValveNO = value;
                  _isConfigurationChanged = true;
                });
              },
            ),
            Text("Normally Open",
                style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
        const SizedBox(height: 16),
        Text('MAC Address', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(widget.central.addressMAC,
            style: Theme.of(context).textTheme.displaySmall),
      ],
    );
  }

  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    int? maxLines,
    bool enabled = true,
  }) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -5,
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CustomTextFiledDecorator(
        textFormField: TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines ?? 1,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.normal,
              ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(
              color: MyColors.lightThemeFont.withOpacity(0.5),
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _confirmDelete() async {
    for (var group in _appData.groups) {
      if (group.centralUnits.contains(widget.central) &&
          group.centralUnits.length == 1) {
        _canNotDelete();
        return;
      }
    }

    for (var group in _appData.groups) {
      if (group.centralUnits.contains(widget.central)) {
        group.centralUnits.remove(widget.central);
      }
    }

    await _db.deleteCentralUnit(widget.central.centralUnitID!);
    _appData.centralUnits.remove(widget.central);

    for (LeakProbe leakProbe in widget.central.leakProbes) {
      _appData.leakProbes.remove(leakProbe);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _canNotDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Cannot delete central unit',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'This central unit is the only one in some groups. Please delete the groups first.',
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
              'Close',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCentralUnit(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete central unit',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete this central unit? This action cannot be undone.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () async {
          if (await _onWillPop()) {
            Navigator.pop(context);
          }
        },
        title: 'Edit ${widget.central.name}',
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: () async {
          await _saveChanges();
          Navigator.pop(context);
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
              const SizedBox(height: 32),
              _buildHardwareConfigSection(),
              const SizedBox(height: 24),
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: 5,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _deleteCentralUnit(_confirmDelete);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Delete central unit',
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
