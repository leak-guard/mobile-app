import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/services/permissions_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:network_tools/network_tools.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDirectory = await getApplicationDocumentsDirectory();
  await configureNetworkTools(appDocDirectory.path, enableDebugging: true);

  PermissionsService();
  NetworkService();

  await Firebase.initializeApp();
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);
  final fncToken = await FirebaseMessaging.instance.getToken();
  if (fncToken != null) {
    print("FNC token: ${fncToken}");
  } else {
    print('There is no FNC token');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'LeakGuard',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        baseColor: MyColors.background,
        lightSource: LightSource.topLeft,
        shadowDarkColorEmboss: MyColors.darkShadow,
        shadowDarkColor: MyColors.darkShadow,
        shadowLightColorEmboss: Colors.white,
        shadowLightColor: Colors.white,
        iconTheme: IconThemeData(color: MyColors.lightThemeFont, size: 30),
        textTheme: GoogleFonts.latoTextTheme().copyWith(
            titleLarge: TextStyle(
                color: MyColors.lightThemeFont,
                fontSize: 25,
                fontWeight: FontWeight.w600),
            displaySmall: TextStyle(
                color: MyColors.lightThemeFont,
                fontSize: 17,
                fontWeight: FontWeight.w600),
            displayMedium: TextStyle(
                color: MyColors.lightThemeFont,
                fontSize: 20,
                fontWeight: FontWeight.w600),
            displayLarge: TextStyle(
                color: MyColors.lightThemeFont,
                fontSize: 30,
                fontWeight: FontWeight.w600)),
        depth: 10,
      ),
      darkTheme: const NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      home: FutureBuilder(
        future: AppData().loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: MyColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/logo.png', width: 150),
                    const SizedBox(height: 20),
                    Text(MyStrings.appName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 50)),
                    const SizedBox(height: 50),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          }

          return const Navigator(
            initialRoute: Routes.main,
            onGenerateRoute: Routes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
