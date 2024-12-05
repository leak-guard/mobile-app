import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/models/time_zone.dart';
import 'package:leak_guard/models/wifi_network.dart';
import 'package:leak_guard/services/api_service.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/utils/time_zone_helper.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/password_widget.dart';
import 'package:leak_guard/widgets/photo_widget.dart';
import 'package:leak_guard/widgets/probe_widget.dart';
import 'package:leak_guard/widgets/timezone_dropdown_widget.dart';
import 'package:leak_guard/widgets/wifi_dropdown_widget.dart';

class DetailsCentralUnitScreen extends StatefulWidget {
  const DetailsCentralUnitScreen({super.key, required this.central});
  final CentralUnit central;

  @override
  State<DetailsCentralUnitScreen> createState() =>
      _DetailsCentralUnitScreenState();
}
//TODO: add updating configuration via API

class _DetailsCentralUnitScreenState extends State<DetailsCentralUnitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ipController = TextEditingController();
  final _wifiSsidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  final _impulsesController = TextEditingController();

  final _db = DatabaseService.instance;
  final _appData = AppData();
  final _api = CustomApi();
  late String? _initialImagePath;
  late String _initialDescription;

  WifiNetwork? _selectedNetwork;
  late TimeZone _selectedTimeZone;

  bool _isValid = true;
  bool _isValveNO = false;
  bool _isConfigurationChanged = false;

  @override
  void initState() {
    super.initState();
    if (!widget.central.isOnline) {
      CustomToast.toast("Central unit is offline");
    }

    _nameController.text = widget.central.name;
    _descriptionController.text = widget.central.description ?? '';
    _ipController.text = widget.central.addressIP;
    _wifiSsidController.text = widget.central.wifiSSID ?? "";
    _wifiPasswordController.text = widget.central.wifiPassword ?? "";
    _impulsesController.text = widget.central.impulsesPerLiter.toString();
    _selectedTimeZone =
        TimeZoneHelper.getCurrentTimeZonebyId(widget.central.timezoneId ?? 37);

    _isValveNO = widget.central.isValveNO;
    _initialImagePath = widget.central.imagePath;
    _initialDescription = widget.central.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ipController.dispose();
    _wifiSsidController.dispose();
    _impulsesController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    bool imagePathDif = widget.central.imagePath != _initialImagePath;
    bool nameDif = widget.central.name != _nameController.text.trim();
    bool descriptionDif =
        _initialDescription != _descriptionController.text.trim();

    bool ipDif = widget.central.addressIP != _ipController.text;

    bool wifiSsidDif;
    if (widget.central.wifiSSID == null) {
      wifiSsidDif = false;
    } else {
      wifiSsidDif = widget.central.wifiSSID != _wifiSsidController.text;
    }

    bool wifiPasswordDif;
    if (widget.central.wifiPassword == null) {
      wifiPasswordDif = false;
    } else {
      wifiPasswordDif =
          widget.central.wifiPassword != _wifiPasswordController.text;
    }

    bool impulsesDif = widget.central.impulsesPerLiter !=
        int.tryParse(_impulsesController.text);

    bool timeZoneDif;
    if (widget.central.timezoneId == null) {
      timeZoneDif = false;
    } else {
      timeZoneDif = widget.central.timezoneId != _selectedTimeZone.timeZoneId;
    }

    bool isValveNoDif = _isValveNO != widget.central.isValveNO;

    return imagePathDif ||
        nameDif ||
        descriptionDif ||
        ipDif ||
        wifiSsidDif ||
        wifiPasswordDif ||
        impulsesDif ||
        timeZoneDif ||
        isValveNoDif;
  }

  Future<void> _checkCentralUnit(String ip) async {
    final macAddress = await _api.getCentralMacAddress(ip);

    if (mounted) {
      if (macAddress != null) {
        _showDialog(
            'Success', 'Connected to central unit with MAC:\n$macAddress');
      } else {
        _showDialog('Error', 'Could not connect to central unit at IP:\n$ip');
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
      return await _saveChanges();
    }

    return true;
  }

  Future<bool> _saveChanges() async {
    bool? isFormValid = _formKey.currentState?.validate();

    await Future.microtask(() => null);

    if (isFormValid != true || !_isValid) {
      return false;
    }

    try {
      widget.central.name = _nameController.text.trim();
      widget.central.description = _descriptionController.text.trim();

      await _db.updateCentralUnit(widget.central);

      if (_isConfigurationChanged) {
        await _sendConfiguration();
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating central unit: $e')),
        );
      }
      return false;
    }
  }

  Widget _buildWifiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WiFi credentials',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'WiFi SSID',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        WifiDropdown(
          controller: _wifiSsidController,
          onNetworkSelected: (network) {
            setState(() {
              _isConfigurationChanged = true;
              _selectedNetwork = network;
            });
          },
          onTextFieldChanged: () {
            setState(() {
              _isConfigurationChanged = true;
              _selectedNetwork = null;
            });
          },
          validator: (value) {
            if (!widget.central.isOnline) {
              return null;
            }
            String? errorMessage;

            if (value == null || value.trim().isEmpty) {
              errorMessage = 'Please enter a WiFi SSID';
            }

            if (errorMessage != null) {
              Future.microtask(() {
                setState(() => _isValid = false);
                _showDialog('Wifi credentials', errorMessage!);
              });
            } else {
              setState(() => _isValid = true);
            }
            return null;
          },
        ),
        if (_selectedNetwork?.isSecure ?? true) _buildPassword(),
      ],
    );
  }

  Widget _buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Password',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        PasswordWidget(
          controller: _wifiPasswordController,
          validator: (value) {
            if (!widget.central.isOnline) {
              return null;
            }
            String? errorMessage;
            if (!(_selectedNetwork?.isSecure ?? true)) {
              return null;
            }

            if (value == null || value.trim().isEmpty) {
              errorMessage = 'Please enter a WiFi password';
            }

            if (errorMessage != null) {
              Future.microtask(() {
                setState(() => _isValid = false);
                _showDialog('Wifi credentials', errorMessage!);
              });
            } else {
              setState(() => _isValid = true);
            }
            return null;
          },
          onTextFieldChanged: () {
            setState(() => _isConfigurationChanged = true);
          },
        )
      ],
    );
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

  Future<bool> _sendConfiguration() async {
    String? macAddress =
        await _api.getCentralMacAddress(widget.central.addressIP);
    if (macAddress == null) {
      CustomToast.toast(
          'Could not connect to central unit\nConfiguration not sent');
      return false;
    }

    if (macAddress != widget.central.addressMAC &&
        widget.central.addressIP != MyStrings.mockIp) {
      CustomToast.toast('MAC address does not match\nConfiguration not sent');
      return false;
    }

    Map<String, dynamic> config = {
      "ssid": _wifiSsidController.text,
      "passphrase": _wifiPasswordController.text,
      "flow_meter_impulses": int.tryParse(_impulsesController.text) ?? 0,
      "valve_type": _isValveNO ? "no" : "nc",
      "timezone_id": _selectedTimeZone.timeZoneId,
    };
    if (await _api.putConfig(_ipController.text, config)) {
      widget.central.wifiSSID = _wifiSsidController.text;
      widget.central.wifiPassword = _wifiPasswordController.text;
      widget.central.impulsesPerLiter =
          int.tryParse(_impulsesController.text) ?? 0;
      widget.central.isValveNO = _isValveNO;
      widget.central.timezoneId = _selectedTimeZone.timeZoneId;
      return true;
    } else {
      CustomToast.toast(
          'Could not connect to central unit\nConfiguration not sent');
      return false;
    }
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
        CustomTextField(
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
        const SizedBox(height: 12),
        Text(
          'Description',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _descriptionController,
          hintText: 'Enter description...',
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Text('Photo', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
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
              child: CustomTextField(
                controller: _ipController,
                hintText: 'IP Address',
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
              onPressed: () => _checkCentralUnit(_ipController.text),
              child: const Icon(
                Icons.search,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Time Zone', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        TimeZoneDropdown(
          onTimeZoneSelected: (timeZone) {
            setState(() {
              _selectedTimeZone = timeZone;
              _isConfigurationChanged = true;
            });
          },
          centralUnit: widget.central,
        ),
        const SizedBox(height: 12),
        Text('Impulses Per Liter',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _impulsesController,
                hintText: 'Impulses per liter',
                keyboardType: TextInputType.number,
                onChanged: (_) =>
                    setState(() => _isConfigurationChanged = true),
                validator: (value) {
                  if (!widget.central.isOnline) {
                    return null;
                  }
                  int? impulses = int.tryParse(value ?? '');
                  String? errorMessage;
                  if (value == null || value.trim().isEmpty) {
                    errorMessage = 'Please enter a impulses per liter';
                  }

                  if (impulses != null && impulses <= 0) {
                    errorMessage =
                        'Impulses per liter must be a positive number';
                  }

                  if (errorMessage != null) {
                    Future.microtask(() {
                      setState(() => _isValid = false);
                      _showDialog('Hardware configuration', errorMessage!);
                    });
                  } else {
                    setState(() => _isValid = true);
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Electrovalve Type',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
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
        const SizedBox(height: 12),
        Text('MAC Address', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(widget.central.addressMAC,
            style: Theme.of(context).textTheme.displaySmall),
      ],
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
        group.updateBlockStatus();
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

  Widget _buildLeakProbes() {
    if (widget.central.leakProbes.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leak Probes',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 16),
        for (LeakProbe leakProbe in widget.central.leakProbes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: ProbeWidget(
              probe: leakProbe,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.detailsLeakProbe,
                  arguments: DetailsLeakProbeScreenArguments(
                    leakProbe,
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
            ),
          ),
      ],
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
              const SizedBox(height: 24),
              _buildWifiSection(),
              const SizedBox(height: 24),
              _buildHardwareConfigSection(),
              const SizedBox(height: 24),
              _buildLeakProbes(),
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
