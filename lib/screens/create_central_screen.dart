import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/wifi_network.dart';
import 'package:leak_guard/services/api_service.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/widgets/photo_widget.dart';
import 'package:leak_guard/widgets/wifi_dropdown_widget.dart';
import 'package:nsd/nsd.dart';

class CreateCentralScreen extends StatefulWidget {
  final Service? chosenCentral;

  const CreateCentralScreen({
    super.key,
    this.chosenCentral,
  });

  @override
  State<CreateCentralScreen> createState() => _CreateCentralScreenState();
}

class _CreateCentralScreenState extends State<CreateCentralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appData = AppData();
  final _api = CustomApi();
  final _networkService = NetworkService();
  final _db = DatabaseService.instance;

  WifiNetwork? _selectedNetwork;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ipController = TextEditingController();
  final _wifiSsidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  final _impulsesController = TextEditingController();

  bool _isCentralFound = false;
  bool _isValveNO = true;
  bool _isValid = true;

  final _central = CentralUnit(
    name: '',
    description: '',
    addressIP: '',
    impulsesPerLiter: 0,
    isValveNO: true,
    password: "admin1",
    addressMAC: '',
  );

  @override
  void initState() {
    super.initState();
    if (widget.chosenCentral != null) {
      if (widget.chosenCentral!.addresses != null) {
        _ipController.text = widget.chosenCentral!.addresses!.first.address;
        _isCentralFound = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ipController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _impulsesController.dispose();
    super.dispose();
  }

  Future<void> _checkCentralUnit(String ip) async {
    setState(() {
      _isCentralFound = true;
    });
    final macAddress = await _api.getCentralMacAddress(ip);

    if (mounted) {
      if (macAddress != null) {
        _showDialog('Success', 'Found central unit with MAC:\n$macAddress');
      } else {
        _showDialog('Error', 'Could not find central unit at IP:\n$ip');
        setState(() {
          _isCentralFound = false;
        });
      }
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
        const SizedBox(height: 12),
        WifiDropdown(
          controller: _wifiSsidController,
          onNetworkSelected: (network) {
            setState(() {
              _selectedNetwork = network;
            });
          },
          onTextFieldChanged: () {
            setState(() {
              _selectedNetwork = null;
            });
          },
          validator: (value) {
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
        const SizedBox(height: 12),
        CustomTextField(
          hintText: 'Enter password...',
          validator: (value) {
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
          controller: _wifiPasswordController,
        ),
      ],
    );
  }

  Widget _buildIpSection() {
    if ((_networkService?.currentWifiName ?? "") == "LeakGuardConfig") {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IP Address',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _ipController,
                hintText: 'Enter IP address...',
                readOnly: _isCentralFound,
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
              onPressed: !_isCentralFound
                  ? () => _checkCentralUnit(_ipController.text)
                  : null,
              child: const Icon(Icons.search),
            ),
          ],
        ),
        const SizedBox(height: 24),
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

  Widget _buildHardwareConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hardware Configuration',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 16),
        _buildIpSection(),
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
                validator: (value) {
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
                });
              },
            ),
            Text("Normally Open",
                style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildCentralUnitInformation() {
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
        const SizedBox(height: 12),
        CustomTextField(
          controller: _nameController,
          hintText: 'Enter name...',
          validator: (value) {
            String? errorMessage;
            if (value == null || value.trim().isEmpty) {
              errorMessage = 'Please enter a name';
            } else if (_appData.centralUnits.any(
                (c) => c.name.toLowerCase() == value.trim().toLowerCase())) {
              errorMessage = 'Central unit name already exists';
            }

            if (errorMessage != null) {
              Future.microtask(() {
                setState(() => _isValid = false);
                _showDialog('Wrong name', errorMessage!);
              });
            } else {
              setState(() => _isValid = true);
            }
            return null;
          },
        ),
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
          item: _central,
          size: MediaQuery.of(context).size.width - 32,
          onPhotoChanged: () {
            setState(() {});
          },
        ),
      ],
    );
  }

  Future<bool> _sendConfiguration(CentralUnit centralUnit) async {
    Map<String, dynamic> config = {
      "ssid": _wifiSsidController.text,
      "passphrase": _wifiPasswordController.text,
      "flow_meter_impulses": centralUnit.impulsesPerLiter,
      "valve_type": centralUnit.isValveNO ? "no" : "nc",
      // TODO: Add timezone to configuration
      "timezone_id": 37,
    };

    if (!(await _api.putConfig(centralUnit.addressIP, config))) return false;

    return true;
  }

  Future<bool> _createCentralUnit() async {
    bool? isFormValid = _formKey.currentState?.validate();

    await Future.microtask(() => null);

    if (isFormValid != true || !_isValid) {
      return false;
    }

    _central.name = _nameController.text;
    _central.description = _descriptionController.text;
    _central.addressIP = _ipController.text;
    _central.isValveNO = _isValveNO;
    _central.impulsesPerLiter = int.tryParse(_impulsesController.text) ?? 0;
    String? adresMac = await _api.getCentralMacAddress(_central.addressIP);
    _central.addressMAC = adresMac ?? '';

    if (await _sendConfiguration(_central)) {
      int centralID = await _db.addCentralUnit(_central);
      _central.centralUnitID = centralID;
      _central.isOnline = true;
      _appData.centralUnits.add(_central);
      return true;
    } else {
      _showDialog('Error', 'Errors occurred while using API');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () => Navigator.pop(context),
        title: 'Create Central Unit',
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: () {
          _createCentralUnit().then((success) {
            if (success) {
              Navigator.pop(context);
            }
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
              _buildCentralUnitInformation(),
              const SizedBox(height: 24),
              _buildWifiSection(),
              const SizedBox(height: 24),
              _buildHardwareConfigSection(),
            ],
          ),
        ),
      ),
    );
  }
}
