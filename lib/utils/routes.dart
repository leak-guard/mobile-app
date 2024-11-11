import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/screens/create_group_screen.dart';
import 'package:leak_guard/screens/group_screen.dart';
import 'package:leak_guard/screens/main_screen.dart';

class Routes {
  static const String main = '/';
  static const String groups = '/groups';
  static const String createGroup = '/createGroup';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );

      case groups:
        if (settings.arguments is GroupScreenArguments) {
          final args = settings.arguments as GroupScreenArguments;
          return MaterialPageRoute(
            builder: (_) => GroupScreen(groups: args.groups),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid arguments')),
          ),
        );

      case createGroup:
        if (settings.arguments is CreateGroupScreenArguments) {
          final args = settings.arguments as CreateGroupScreenArguments;
          return MaterialPageRoute(
            builder: (_) => CreateGroupScreen(groups: args.groups),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid arguments')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

class GroupScreenArguments {
  final List<Group> groups;

  GroupScreenArguments(this.groups);
}

class CreateGroupScreenArguments {
  final List<Group> groups;

  CreateGroupScreenArguments(this.groups);
}
