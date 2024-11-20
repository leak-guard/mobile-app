import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/screens/create_central_screen.dart';
import 'package:leak_guard/screens/find_central_screen.dart';
import 'package:leak_guard/screens/create_group_screen.dart';
import 'package:leak_guard/screens/group_screen.dart';
import 'package:leak_guard/screens/main_screen.dart';
import 'package:nsd/nsd.dart';

class Routes {
  static const String main = '/';
  static const String groups = '/groups';
  static const String createGroup = '/createGroup';
  static const String findCentral = '/findCentral';
  static const String createCentral = '/createCentral';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        if (settings.arguments is MainScreenArguments) {
          final args = settings.arguments as MainScreenArguments;
          return MaterialPageRoute(
            builder: (_) => MainScreen(groups: args.groups),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const MainScreen(groups: []),
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

      case findCentral:
        if (settings.arguments is FindCentralScreenArguments) {
          final args = settings.arguments as FindCentralScreenArguments;
          return MaterialPageRoute(
            builder: (_) => FindCentralScreen(centralUnits: args.centralUnits),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid arguments')),
          ),
        );

      case createCentral:
        if (settings.arguments is CreateCentralScreenArguments) {
          final args = settings.arguments as CreateCentralScreenArguments;
          return MaterialPageRoute(
            builder: (_) => CreateCentralScreen(
              centralUnits: args.centralUnits,
              chosenCentral: args.chosenCentral,
            ),
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

class MainScreenArguments {
  final List<Group> groups;

  MainScreenArguments(this.groups);
}

class GroupScreenArguments {
  final List<Group> groups;

  GroupScreenArguments(this.groups);
}

class CreateGroupScreenArguments {
  final List<Group> groups;

  CreateGroupScreenArguments(this.groups);
}

class FindCentralScreenArguments {
  final List<CentralUnit> centralUnits;

  FindCentralScreenArguments(this.centralUnits);
}

class CreateCentralScreenArguments {
  final List<CentralUnit> centralUnits;
  final Service? chosenCentral;

  CreateCentralScreenArguments(this.centralUnits, [this.chosenCentral]);
}
