import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/services/api_service.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:nsd/nsd.dart';
import 'package:leak_guard/services/network_service.dart';

// TODO: Check if Central is already in database

class FindCentralScreen extends StatefulWidget {
  const FindCentralScreen({super.key});

  @override
  State<FindCentralScreen> createState() => _FindCentralScreenState();
}

class _FindCentralScreenState extends State<FindCentralScreen> {
  final _networkService = NetworkService();
  final _api = CustomApi();

  @override
  void initState() {
    super.initState();
    _networkService.startServiceDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () => Navigator.pop(context),
        title: 'Find Central Unit',
      ),
      body: BlurredTopWidget(
        height: 20,
        child: StreamBuilder<List<Service>>(
          stream: _networkService.servicesStream,
          builder: (context, snapshot) {
            final services = snapshot.data ?? [];

            return ListView.builder(
                itemCount: services.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: NeumorphicButton(
                        style: NeumorphicStyle(
                          depth: 5,
                          intensity: 0.8,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.createCentralUnit,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Find central unit manually",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    );
                  }

                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeumorphicButton(
                            style: NeumorphicStyle(
                              depth: 5,
                              intensity: 0.8,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _networkService.startServiceDiscovery,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_networkService.isSearchingServices)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  if (!_networkService.isSearchingServices)
                                    const Icon(Icons.refresh),
                                  const SizedBox(width: 8),
                                  Text(
                                    _networkService.isSearchingServices
                                        ? 'Searching...'
                                        : 'Refresh',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final service = services[index - 2];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: NeumorphicButton(
                      onPressed: () async {
                        Map<String, dynamic>? config = await _api
                            .getConfig(service.addresses!.first.address);
                        String? macAddress = await _api.getCentralMacAddress(
                            service.addresses!.first.address);
                        print(config);

                        CentralUnit mdnsCentral = CentralUnit(
                          name: "",
                          addressIP: service.addresses!.first.address,
                          addressMAC: macAddress ?? '',
                          password: 'admin1',
                          isValveNO: (config!['valve_type'] as String) == "no",
                          impulsesPerLiter:
                              config['flow_meter_impulses'] as int,
                          timezoneId: config['timezone_id'] as int,
                          wifiSSID: config['ssid'] as String,
                          wifiPassword: config['passphrase'] as String,
                        );

                        Navigator.pushNamed(
                          context,
                          Routes.createCentralUnit,
                          arguments: CreateCentralScreenArguments(mdnsCentral),
                        );
                      },
                      style: NeumorphicStyle(
                        depth: 5,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${service.name}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hostname: ${service.host}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'IPv4: ${service.addresses!.first.address}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
