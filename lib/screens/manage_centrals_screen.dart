import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/add_new_unit_button.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';
import 'package:leak_guard/widgets/central_unit_button.dart';

class ManageCentralsScreen extends StatefulWidget {
  const ManageCentralsScreen({super.key});

  @override
  State<ManageCentralsScreen> createState() => _ManageCentralsScreenState();
}

class _ManageCentralsScreenState extends State<ManageCentralsScreen> {
  final _appData = AppData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: MyStrings.manageUnits,
      ),
      body: BlurredTopEdge(
        height: 20,
        child: ListView.builder(
          itemCount: _appData.centralUnits.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: AddNewUnitButton(
                  onBack: () => setState(() {}),
                ),
              );
            }

            final central = _appData.centralUnits[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: CentralUnitButton(
                central: central,
                onPressed: () {
                  print(central);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
