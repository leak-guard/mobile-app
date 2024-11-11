import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.groups});
  final List<Group> groups;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () => Navigator.pop(context),
        title: MyStrings.manageGroups,
        trailingIcon: const Icon(Icons.refresh),
        onTrailingTap: () {},
      ),
      body: BlurredTopEdge(
        height: 20,
        child: ListView.builder(
          itemCount: widget.groups.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                child: Neumorphic(
                  padding: const EdgeInsets.all(15),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    depth: -10,
                    intensity: 0.8,
                    lightSource: LightSource.topLeft,
                    color: MyColors.background,
                  ),
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
                        Routes.createGroup,
                        arguments: CreateGroupScreenArguments(widget.groups),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    child: Center(
                      child: Text(
                        'Add new group',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: MyColors.lightThemeFont.withOpacity(0.4),
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }
            final group = widget.groups[index - 1];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 5,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        group.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
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
