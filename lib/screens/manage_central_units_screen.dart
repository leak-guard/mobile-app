import 'package:flutter/material.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/add_unit_button.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/central_unit_widget.dart';
import 'package:leak_guard/widgets/loading_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class ManageCentralUnitsScreen extends StatefulWidget {
  const ManageCentralUnitsScreen({super.key});

  @override
  State<ManageCentralUnitsScreen> createState() =>
      _ManageCentralUnitsScreenState();
}

class _ManageCentralUnitsScreenState extends State<ManageCentralUnitsScreen> {
  final _appData = AppData();
  bool _centralChosen = false;
  bool _isLoading = false;
  final _db = DatabaseService.instance;

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    List<Future<bool>> futures = [];
    for (var central in _appData.centralUnits) {
      futures.add(central.refreshForWidget());
    }
    await Future.wait(futures);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshIndicator() async {
    await Future.delayed(const Duration(seconds: 2));
    List<Future<bool>> futures = [];
    for (var central in _appData.centralUnits) {
      futures.add(central.refreshForWidget());
    }
    await Future.wait(futures);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      isLoading: _isLoading,
      child: Scaffold(
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
          onRefresh: _refreshIndicator,
          child: BlurredTopWidget(
            height: 20,
            child: ListView.builder(
              itemCount: _appData.centralUnits.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: AddUnitButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });

                        Permission.locationWhenInUse.serviceStatus.isEnabled
                            .then((isEnable) {
                          if (!isEnable) {
                            CustomToast.toast(
                                'Please turn on location on your phone');
                          }
                        });
                        Navigator.pushNamed(
                          // ignore: use_build_context_synchronously
                          context,
                          Routes.findCentralUnit,
                        ).then((_) {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      },
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
                      if (_isLoading) return;
                      if (_centralChosen) return;
                      setState(() {
                        _centralChosen = true;
                        _isLoading = true;
                      });
                      await central.refreshStatus();
                      await _db.updateCentralUnit(central);

                      if (!mounted) return;
                      Navigator.pushNamed(
                        // ignore: use_build_context_synchronously
                        context,
                        Routes.detailsCentralUnit,
                        arguments: DetailsCentralUnitScreenArguments(
                          central,
                        ),
                      ).then((_) {
                        if (_appData.centralUnits.isEmpty) {
                          // ignore: use_build_context_synchronously
                          if (mounted) Navigator.pop(context);
                        }
                        setState(() {
                          _isLoading = false;
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
      ),
    );
  }
}
