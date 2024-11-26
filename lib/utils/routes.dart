import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/screens/arc_test_screen.dart';
import 'package:leak_guard/screens/create_central_screen.dart';
import 'package:leak_guard/screens/details_central_screen.dart';
import 'package:leak_guard/screens/details_group_screen.dart';
import 'package:leak_guard/screens/error_screen.dart';
import 'package:leak_guard/screens/find_central_screen.dart';
import 'package:leak_guard/screens/create_group_screen.dart';
import 'package:leak_guard/screens/manage_centrals_screen.dart';
import 'package:leak_guard/screens/manage_groups_screen.dart';
import 'package:leak_guard/screens/main_screen.dart';
import 'package:nsd/nsd.dart';

class Routes {
  static const String main = '/';
  static const String manageGroups = '/manageGroups';
  static const String createGroup = '/createGroup';
  static const String detailsGroup = '/detailsGroup';
  static const String manageCentrals = '/manageCentrals';
  static const String createCentral = '/createCentral';
  static const String detailsCentral = '/detailsCentral';
  static const String findCentral = '/findCentral';

  //TODO: to delete
  static const String arcTest = '/arcTest';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      //TODO: to delete
      case arcTest:
        return MaterialPageRoute(
          builder: (_) => const ArcTestScreen(),
        );

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

      case detailsGroup:
        if (settings.arguments is DetailsGroupScreenArguments) {
          final args = settings.arguments as DetailsGroupScreenArguments;
          return MaterialPageRoute(
            builder: (_) => DetailsGroupScreen(
              group: args.chosenGroup,
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );

      case detailsCentral:
        if (settings.arguments is DetailsCentralcreenArguments) {
          final args = settings.arguments as DetailsCentralcreenArguments;
          return MaterialPageRoute(
            builder: (_) => DetailsCentralScreen(
              central: args.central,
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );
    }
  }
}

class CreateCentralScreenArguments {
  final Service? chosenCentral;

  CreateCentralScreenArguments([this.chosenCentral]);
}

class DetailsGroupScreenArguments {
  final Group chosenGroup;

  DetailsGroupScreenArguments(this.chosenGroup);
}

class DetailsCentralcreenArguments {
  final CentralUnit central;

  DetailsCentralcreenArguments(this.central);
}
