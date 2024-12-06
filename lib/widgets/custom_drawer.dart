import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/custom_icons.dart';
import '../utils/colors.dart';
import '../utils/routes.dart';
import '../utils/strings.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required this.onBack});
  final VoidCallback onBack;

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
            leading: Icon(CustomIcons.group, color: MyColors.lightThemeFont),
            title: Text('Manage groups',
                style: Theme.of(context).textTheme.displaySmall),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.manageGroups,
              ).then((_) => onBack());
            },
          ),
          NeumorphicListTile(
            leading:
                Icon(CustomIcons.centralUnit, color: MyColors.lightThemeFont),
            title: Text('Manage central units',
                style: Theme.of(context).textTheme.displaySmall),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.manageCentralUnits,
              ).then((_) => onBack());
            },
          ),
          NeumorphicListTile(
            leading: Icon(CustomIcons.probe, color: MyColors.lightThemeFont),
            title: Text('Manage leak probes',
                style: Theme.of(context).textTheme.displaySmall),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.manageLeakProbes,
              ).then((_) => onBack());
            },
          ),
          NeumorphicListTile(
            leading: Icon(Icons.adb, color: MyColors.lightThemeFont),
            title:
                Text('Tests', style: Theme.of(context).textTheme.displaySmall),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.tests,
              ).then((_) => onBack());
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
