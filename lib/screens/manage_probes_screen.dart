import 'package:flutter/material.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/probe_widget.dart';

class ManageLeakProbesScreen extends StatefulWidget {
  const ManageLeakProbesScreen({super.key});

  @override
  State<ManageLeakProbesScreen> createState() => _ManageLeakProbesScreenState();
}

class _ManageLeakProbesScreenState extends State<ManageLeakProbesScreen> {
  final _appData = AppData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 80,
        onLeadingTap: () {
          Navigator.pop(context);
        },
        title: MyStrings.manageProbes,
      ),
      body: BlurredTopWidget(
        height: 20,
        child: ListView.builder(
          itemCount: _appData.leakProbes.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SizedBox(height: 12);
            }

            final probe = _appData.leakProbes[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ProbeWidget(
                probe: probe,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.detailsLeakProbe,
                    arguments: DetailsLeakProbeScreenArguments(
                      probe,
                    ),
                  ).then((_) {
                    setState(() {});
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
