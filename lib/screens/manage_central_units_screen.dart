import 'package:flutter/material.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/add_unit_button.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/central_unit_widget.dart';

class ManageCentralUnitsScreen extends StatefulWidget {
  const ManageCentralUnitsScreen({super.key});

  @override
  State<ManageCentralUnitsScreen> createState() =>
      _ManageCentralUnitsScreenState();
}

class _ManageCentralUnitsScreenState extends State<ManageCentralUnitsScreen> {
  final _appData = AppData();
  bool _centralChosen = false;
  final _networkService = NetworkService();
  final _db = DatabaseService.instance;

  Future<void> _refresh() async {
    _networkService.startServiceDiscovery();
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          height: 80,
          onLeadingTap: () {
            Navigator.pop(context);
          },
          title: MyStrings.manageUnits,
          trailingIcon: const Icon(Icons.refresh),
          onTrailingTap: _refresh),
      body: RefreshIndicator(
        color: MyColors.lightThemeFont,
        backgroundColor: MyColors.background,
        onRefresh: _refresh,
        child: BlurredTopWidget(
          height: 20,
          child: ListView.builder(
            itemCount: _appData.centralUnits.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: AddUnitButton(
                    onBack: () => setState(() {}),
                  ),
                );
              }

              final central = _appData.centralUnits[index - 1];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: CentralUnitWidget(
                  central: central,
                  onPressed: () async {
                    if (_centralChosen) return;
                    _centralChosen = true;
                    await central.refreshConfig();

                    await _db.updateCentralUnit(central);

                    Navigator.pushNamed(
                      context,
                      Routes.detailsCentralUnit,
                      arguments: DetailsCentralUnitScreenArguments(
                        central,
                      ),
                    ).then((_) {
                      setState(() {
                        _centralChosen = false;
                      });
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
