import 'package:flutter/material.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/widgets/central_unit_widget.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';

class GroupCentralUnitsScreen extends StatefulWidget {
  const GroupCentralUnitsScreen({super.key, required this.group});
  final Group group;

  @override
  State<GroupCentralUnitsScreen> createState() =>
      _GroupCentralUnitsScreenState();
}

class _GroupCentralUnitsScreenState extends State<GroupCentralUnitsScreen> {
  bool _centralChoosen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: widget.group.name,
      ),
      body: BlurredTopWidget(
        height: 20,
        child: ListView.builder(
          itemCount: widget.group.centralUnits.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SizedBox(height: 12);
            }

            final central = widget.group.centralUnits[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: CentralUnitWidget(
                central: central,
                onPressed: () async {
                  if (_centralChoosen) return;
                  _centralChoosen = true;
                  await central.refreshConfig();

                  Navigator.pushNamed(
                    context,
                    Routes.detailsCentralUnit,
                    arguments: DetailsCentralUnitScreenArguments(
                      central,
                    ),
                  ).then((_) {
                    setState(() {
                      _centralChoosen = false;
                    });
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
