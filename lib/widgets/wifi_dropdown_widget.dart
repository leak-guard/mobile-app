import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/services/permissions_service.dart';
import 'package:leak_guard/models/wifi_network.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiDropdown extends StatefulWidget {
  final TextEditingController controller;
  final Function(WifiNetwork) onNetworkSelected;
  final VoidCallback? onTextFieldChanged;
  final String? Function(String?)? validator;

  const WifiDropdown({
    super.key,
    required this.controller,
    required this.onNetworkSelected,
    this.onTextFieldChanged,
    this.validator,
  });

  @override
  State<WifiDropdown> createState() => _WifiDropdownState();
}

class _WifiDropdownState extends State<WifiDropdown> {
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final _networkService = NetworkService();
  final _permissionsService = PermissionsService();

  double _getListHeight(List<WifiNetwork> networks) {
    return networks.length >= 3 ? 150.0 : networks.length * 55.0;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget _buildPermissionMessage() {
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_disabled,
                size: 32,
                color: MyColors.lightThemeFont.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Location permission required',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: MyColors.lightThemeFont.withOpacity(0.5),
                    ),
              ),
              const SizedBox(height: 16),
              NeumorphicButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                  });
                  _permissionsService.requestPermission(Permission.location);
                },
                child: Text(
                  'Grant Permission',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(List<WifiNetwork> networks) {
    return SizedBox(
      height: _getListHeight(networks),
      child: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        padding: const EdgeInsets.all(8),
        thickness: 4,
        radius: const Radius.circular(2),
        thumbColor: MyColors.lightThemeFont.withOpacity(0.3),
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: networks.length,
          itemBuilder: (context, index) {
            final network = networks[index];
            return NeumorphicButton(
              style: NeumorphicStyle(
                depth: 0,
                intensity: 0,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(0),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              onPressed: () {
                _isExpanded = false;
                widget.controller.text = network.ssid;
                widget.onNetworkSelected(network);
              },
              child: Row(
                children: [
                  Icon(_getSignalIcon(network.signalQuality)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          network.ssid,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Text(
                          '${network.signalStrength} dBm',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: MyColors.lightThemeFont.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (network.isSecure) const Icon(Icons.lock, size: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getSignalIcon(SignalStrength strength) {
    switch (strength) {
      case SignalStrength.excellent:
        return Icons.wifi;
      case SignalStrength.good:
        return Icons.wifi_2_bar;
      case SignalStrength.poor:
        return Icons.wifi_1_bar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              controller: widget.controller,
              onChanged: (_) {
                widget.onTextFieldChanged?.call();
              },
              hintText: 'Select WiFi network...',
              validator: widget.validator,
            )),
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
              onPressed: () {
                if (_isExpanded) {
                  setState(() => _isExpanded = false);
                } else {
                  _networkService.scanWifiNetworks();
                  setState(() => _isExpanded = true);
                }
              },
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isExpanded ? 0.5 : 0.0,
                child: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isExpanded ? 158 : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: -5,
                intensity: 0.8,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              child: StreamBuilder<List<WifiNetwork>>(
                stream: _networkService.wifiStream,
                builder: (context, snapshot) {
                  if (_networkService.isSearchingWifi) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 150,
                            child: Center(
                                child: CircularProgressIndicator(
                              color: MyColors.lightThemeFont,
                            ))),
                      ],
                    );
                  }

                  if (_networkService.permissionGranted == false) {
                    return _buildPermissionMessage();
                  }

                  final networks = snapshot.data ?? [];
                  if (networks.isEmpty) {
                    return SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 32,
                                color: MyColors.lightThemeFont.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No WiFi networks found',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: MyColors.lightThemeFont
                                          .withOpacity(0.5),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildListContent(networks);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
