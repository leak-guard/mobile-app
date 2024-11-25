import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/services/api_service.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:leak_guard/utils/colors.dart';
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
  bool _isValid = true;
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  bool _isCentralFound = false;
  final api = CustomApi();

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
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _checkCentralUnit(String ip) async {
    setState(() {
      _isCentralFound = true;
    });
    final (macAddress, success) = await api.getCentralMacAddress(ip);

    if (mounted) {
      if (success) {
        _showDialog(
            context, 'Success', 'Found central unit with MAC:\n$macAddress');
      } else {
        _showDialog(
            context, 'Error', 'Could not find central unit at IP:\n$ip');
        setState(() {
          _isCentralFound = false;
        });
      }
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
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
        title: 'Create Central Unit',
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: () {
          if (_formKey.currentState?.validate() ?? false) {
            // TODO: Create central unit
          }
        },
      ),
      body: BlurredTopEdge(
        height: 20,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'IP Address',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
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
                        controller: _ipController,
                        readOnly: _isCentralFound,
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontWeight: FontWeight.normal,
                                ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter IP address...',
                          hintStyle: TextStyle(
                              color: MyColors.lightThemeFont.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeumorphicButton(
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
              Text(
                'Name',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Neumorphic(
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
                    hintText: 'Enter name...',
                    hintStyle: TextStyle(
                        color: MyColors.lightThemeFont.withOpacity(0.5)),
                  ),
                  validator: (value) {
                    String? errorMessage;
                    if (value == null || value.trim().isEmpty) {
                      errorMessage = 'Please enter a name';
                    } else if (_appData.centralUnits.any((c) =>
                        c.name.toLowerCase() == value.trim().toLowerCase())) {
                      errorMessage = 'Central unit name already exists';
                    }

                    if (errorMessage != null) {
                      Future.microtask(() {
                        setState(() => _isValid = false);
                        _showDialog(context, 'Wrong name', errorMessage!);
                      });
                    } else {
                      setState(() => _isValid = true);
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              NeumorphicButton(
                onPressed: () => _checkCentralUnit(_ipController.text),
                child: const Text("Central Unit info"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
