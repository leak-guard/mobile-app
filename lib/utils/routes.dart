import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/screens/block_schedule_screen.dart';
import 'package:leak_guard/screens/create_central_screen.dart';
import 'package:leak_guard/screens/details_central_unit_screen.dart';
import 'package:leak_guard/screens/details_group_screen.dart';
import 'package:leak_guard/screens/details_leak_probe_screen.dart';
import 'package:leak_guard/screens/error_screen.dart';
import 'package:leak_guard/screens/find_central_screen.dart';
import 'package:leak_guard/screens/create_group_screen.dart';
import 'package:leak_guard/screens/group_central_units_screen.dart';
import 'package:leak_guard/screens/group_leak_probes_screen.dart';
import 'package:leak_guard/screens/manage_central_units_screen.dart';
import 'package:leak_guard/screens/manage_groups_screen.dart';
import 'package:leak_guard/screens/main_screen.dart';
import 'package:leak_guard/screens/manage_probes_screen.dart';
import 'package:leak_guard/screens/water_usage_screen.dart';

class Routes {
  static const String main = '/';

  static const String groupLeakProbes = '/groupLeakProbes';
  static const String groupCentralUnits = '/groupCentralUnits';
  static const String blockSchedule = '/blockSchedule';
  static const String waterUsage = '/waterUsage';

  static const String manageGroups = '/manageGroups';
  static const String createGroup = '/createGroup';
  static const String detailsGroup = '/detailsGroup';

  static const String manageCentralUnits = '/manageCentralUnits';
  static const String createCentralUnit = '/createCentralUnit';
  static const String detailsCentralUnit = '/detailsCentralUnit';
  static const String findCentralUnit = '/findCentralUnit';

  static const String manageLeakProbes = '/manageLeakProbes';
  static const String detailsLeakProbe = '/detailsLeakProbe';

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

      case manageCentralUnits:
        return MaterialPageRoute(
          builder: (_) => const ManageCentralUnitsScreen(),
        );

      case manageLeakProbes:
        return MaterialPageRoute(
          builder: (_) => const ManageLeakProbesScreen(),
        );

      case createGroup:
        return MaterialPageRoute(
          builder: (_) => const CreateGroupScreen(),
        );

      case findCentralUnit:
        return MaterialPageRoute(
          builder: (_) => const FindCentralScreen(),
        );

      case createCentralUnit:
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

      case detailsCentralUnit:
        if (settings.arguments is DetailsCentralUnitScreenArguments) {
          final args = settings.arguments as DetailsCentralUnitScreenArguments;
          return MaterialPageRoute(
            builder: (_) => DetailsCentralUnitScreen(
              central: args.central,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );

      case detailsLeakProbe:
        if (settings.arguments is DetailsLeakProbeScreenArguments) {
          final args = settings.arguments as DetailsLeakProbeScreenArguments;
          return MaterialPageRoute(
            builder: (_) => DetailsLeakProbeScreen(
              leakProbe: args.leakProbe,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );

      case groupLeakProbes:
        if (settings.arguments is GroupLeakProbesScreenArguments) {
          final args = settings.arguments as GroupLeakProbesScreenArguments;
          return MaterialPageRoute(
            builder: (_) => GroupLeakProbesScreen(
              group: args.group,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );

      case groupCentralUnits:
        if (settings.arguments is GroupCentralUnitsScreenArguments) {
          final args = settings.arguments as GroupCentralUnitsScreenArguments;
          return MaterialPageRoute(
            builder: (_) => GroupCentralUnitsScreen(
              group: args.group,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );

      case blockSchedule:
        if (settings.arguments is BlockScheduleScreenArguments) {
          final args = settings.arguments as BlockScheduleScreenArguments;
          return MaterialPageRoute(
            builder: (_) => BlockScheduleScreen(
              group: args.group,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(),
        );

      case waterUsage:
        if (settings.arguments is WaterUsageScreenArguments) {
          final args = settings.arguments as WaterUsageScreenArguments;
          return MaterialPageRoute(
            builder: (_) => WaterUsageScreen(
              group: args.group,
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

class WaterUsageScreenArguments {
  final Group group;

  WaterUsageScreenArguments(this.group);
}

class GroupCentralUnitsScreenArguments {
  final Group group;

  GroupCentralUnitsScreenArguments(this.group);
}

class GroupLeakProbesScreenArguments {
  final Group group;

  GroupLeakProbesScreenArguments(this.group);
}

class DetailsLeakProbeScreenArguments {
  final LeakProbe leakProbe;

  DetailsLeakProbeScreenArguments(this.leakProbe);
}

class CreateCentralScreenArguments {
  final CentralUnit? chosenCentral;

  CreateCentralScreenArguments([this.chosenCentral]);
}

class DetailsGroupScreenArguments {
  final Group chosenGroup;

  DetailsGroupScreenArguments(this.chosenGroup);
}

class DetailsCentralUnitScreenArguments {
  final CentralUnit central;

  DetailsCentralUnitScreenArguments(this.central);
}

class BlockScheduleScreenArguments {
  final Group group;

  BlockScheduleScreenArguments(this.group);
}
