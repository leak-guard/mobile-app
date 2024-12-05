import 'package:flutter/material.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_widget.dart';
import 'package:leak_guard/widgets/probe_widget.dart';

class GroupLeakProbesScreen extends StatefulWidget {
  const GroupLeakProbesScreen({super.key, required this.group});
  final Group group;

  @override
  State<GroupLeakProbesScreen> createState() => _GroupLeakProbesScreenState();
}

class _GroupLeakProbesScreenState extends State<GroupLeakProbesScreen> {
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
        title: widget.group.name,
      ),
      body: BlurredTopWidget(
        height: 20,
        child: _buildScreen(),
      ),
    );
  }

  Widget _buildScreen() {
    if (widget.group.leakProbes.isEmpty) {
      return Center(
        child: Text(
          'No leak probes found',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.group.leakProbes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 12);
        }

        final probe = widget.group.leakProbes[index - 1];
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
    );
  }
}
