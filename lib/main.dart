import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/routes.dart';

// TODO: Baza danych - kolumna pozycji grupy. Kolumna pozycji powinna być o jeden większa od poprzedniej. To wystarczy.
// TODO: Trzeba ogarnąć powrót do manage groups po dodaniu grupy.
void main() {
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
                fontWeight: FontWeight.w600)),
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      initialRoute: Routes.main,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
