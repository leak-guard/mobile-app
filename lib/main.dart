import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/services/permissions_service.dart';
import 'package:leak_guard/services/shared_preferences.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:network_tools/network_tools.dart';
import 'package:path_provider/path_provider.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  showFlutterNotification(message);
}

Future<void> setupFlutterNotifications() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/leak');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void showFlutterNotification(RemoteMessage message) {
  if (message.data.containsKey('device_id')) {
    String notificationMessage = "We have detected a leak in your system!";
    final data = message.data;
    final deviceID = data['device_id'];
    for (var cu in AppData().centralUnits) {
      if (cu.hardwareID == deviceID) {
        notificationMessage = "Leak detected in ${cu.name}";
        break;
      }
    }
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      "Leak detected",
      notificationMessage,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: '@mipmap/leak',
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDirectory = await getApplicationDocumentsDirectory();
  await configureNetworkTools(appDocDirectory.path, enableDebugging: true);

  await Firebase.initializeApp();
  await FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true);

  PermissionsService();
  final networkService = NetworkService();
  networkService.fcmToken = await FirebaseMessaging.instance.getToken();
  if (networkService.fcmToken != null) {
    print("FNC token: ${networkService.fcmToken}");
  } else {
    print('There is no FNC token');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await setupFlutterNotifications();
  FirebaseMessaging.onMessage.listen(showFlutterNotification);
  await PreferencesService.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
                    CircularProgressIndicator(
                      color: MyColors.lightThemeFont,
                    ),
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
