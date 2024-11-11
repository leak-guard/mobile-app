import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../utils/colors.dart';
import '../utils/routes.dart';
import '../utils/strings.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: MyColors.lightThemeFont,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          NeumorphicListTile(
            leading: Icon(Icons.home, color: MyColors.lightThemeFont),
            title:
                Text('Home', style: Theme.of(context).textTheme.displaySmall),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.main));
            },
          ),
          NeumorphicListTile(
            leading: Icon(Icons.home, color: MyColors.lightThemeFont),
            title: Text('Manage gorups',
                style: Theme.of(context).textTheme.displaySmall),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(Routes.main));
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
