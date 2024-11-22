import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import '../utils/colors.dart';
import '../utils/routes.dart';
import '../utils/strings.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key, required this.groups});
  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: MyColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          NeumorphicDrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/icons/logo.png', width: 80),
                const SizedBox(height: 16),
                Text(
                  MyStrings.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          NeumorphicListTile(
            leading: Icon(Icons.room_preferences_rounded,
                color: MyColors.lightThemeFont),
            title: Text('Manage groups',
                style: Theme.of(context).textTheme.displaySmall),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.manageGroups,
              );
            },
          ),
        ],
      ),
    );
  }
}

class NeumorphicListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;

  const NeumorphicListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: NeumorphicButton(
        style: NeumorphicStyle(
          depth: 2,
          intensity: 0.8,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: onTap,
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            title,
          ],
        ),
      ),
    );
  }
}

class NeumorphicDrawerHeader extends StatelessWidget {
  final Widget child;

  const NeumorphicDrawerHeader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 16, 16, 16),
      child: child,
    );
  }
}
