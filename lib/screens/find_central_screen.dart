import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:nsd/nsd.dart';

//TODO:  Check if founded centrals are already in the list by MAC address

class FindCentralScreen extends StatefulWidget {
  const FindCentralScreen({super.key});

  @override
  State<FindCentralScreen> createState() => _FindCentralScreenState();
}

class _FindCentralScreenState extends State<FindCentralScreen> {
  Discovery? _discovery;
  final List<Service> _services = [];
  bool _isSearching = false;

  bool isSame(Service a, Service b) => a.name == b.name && a.type == b.type;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  @override
  void dispose() {
    _stopDiscovery();
    super.dispose();
  }

  Future<void> _stopDiscovery() async {
    if (_discovery != null) {
      await stopDiscovery(_discovery!);
      _discovery = null;
    }
  }

  Future<void> _startDiscovery() async {
    setState(() {
      _isSearching = true;
      print("Searching...");
      _services.clear();
    });

    try {
      await _stopDiscovery();
      _discovery = await startDiscovery(
        '_leakguard._tcp',
        autoResolve: true,
        ipLookupType: IpLookupType.v4,
      );

      _discovery?.addServiceListener((service, status) {
        setState(() {
          if (status == ServiceStatus.found) {
            _services.add(service);
            print("found new service!");

            print(service.toString());
          } else {
            _services.removeWhere((s) => isSame(s, service));
          }
          _isSearching = false;
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting discovery: $e')),
        );
      }
      setState(() {
        _isSearching = false;
        print("searching stoped");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () => Navigator.pop(context),
        title: 'Find Central Unit',
      ),
      body: BlurredTopEdge(
        height: 20,
        child: ListView.builder(
          itemCount: _services.length + 2,
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
                      Routes.createCentral,
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
                      onPressed: _startDiscovery,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSearching)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            if (!_isSearching) const Icon(Icons.refresh),
                            const SizedBox(width: 8),
                            Text(
                              _isSearching ? 'Searching...' : 'Refresh',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final service = _services[index - 2];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: NeumorphicButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.createCentral,
                    arguments: CreateCentralScreenArguments(
                      service,
                    ),
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
          },
        ),
      ),
    );
  }
}
