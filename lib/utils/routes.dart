import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/screens/create_central_screen.dart';
import 'package:leak_guard/screens/find_central_screen.dart';
import 'package:leak_guard/screens/create_group_screen.dart';
import 'package:leak_guard/screens/manage_centrals_screen.dart';
import 'package:leak_guard/screens/manage_groups_screen.dart';
import 'package:leak_guard/screens/main_screen.dart';
import 'package:nsd/nsd.dart';

class Routes {
  static const String main = '/';
  static const String manageGroups = '/manageGroups';
  static const String manageCentrals = '/manageCentrals';
  static const String createGroup = '/createGroup';
  static const String findCentral = '/findCentral';
  static const String createCentral = '/createCentral';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );

      case manageGroups:
        return MaterialPageRoute(
          builder: (_) => const ManageGroupsScreen(),
        );

      case manageCentrals:
        return MaterialPageRoute(
          builder: (_) => const ManageCentralsScreen(),
        );

      case createGroup:
        return MaterialPageRoute(
          builder: (_) => const CreateGroupScreen(),
        );

      case findCentral:
        return MaterialPageRoute(
          builder: (_) => const FindCentralScreen(),
        );

      case createCentral:
        if (settings.arguments is CreateCentralScreenArguments) {
          final args = settings.arguments as CreateCentralScreenArguments;
          return MaterialPageRoute(
            builder: (_) => CreateCentralScreen(
              chosenCentral: args.chosenCentral,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const CreateCentralScreen(),
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

class CreateCentralScreenArguments {
  final Service? chosenCentral;

  CreateCentralScreenArguments([this.chosenCentral]);
}
