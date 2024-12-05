import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/widgets/central_unit_widget.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/services/network_service.dart';

// TODO: Check if Central is already in database

class FindCentralScreen extends StatefulWidget {
  const FindCentralScreen({super.key});

  @override
  State<FindCentralScreen> createState() => _FindCentralScreenState();
}

class _FindCentralScreenState extends State<FindCentralScreen> {
  final _networkService = NetworkService();
  bool _centralChosen = false;

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
        child: StreamBuilder<List<CentralUnit>>(
          stream: _networkService.centralUnitsStream,
          builder: (context, snapshot) {
            final centralUnits = snapshot.data ?? [];

            return ListView.builder(
                itemCount: centralUnits.length + 2,
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
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: MyColors.lightThemeFont,
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

                  final centralUnit = centralUnits[index - 2];
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: CentralUnitWidget(
                        central: centralUnit,
                        onPressed: () async {
                          if (_centralChosen) return;
                          _centralChosen = true;

                          centralUnit.name = "";

                          Navigator.pushNamed(
                            context,
                            Routes.createCentralUnit,
                            arguments: CreateCentralScreenArguments(
                              centralUnit,
                            ),
                          ).then((success) {
                            setState(() {
                              print("Success: $success");
                              _centralChosen = false;
                              if (success == true) {
                                Navigator.pop(context);
                              }
                            });
                          });
                        },
                      ));
                });
          },
        ),
      ),
    );
  }
}
