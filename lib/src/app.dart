import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dimsummaster/src/posshop/posshop_view.dart';
import 'package:dimsummaster/src/signin/signin_view.dart';

const defaultButtonTextStyle = TextStyle(fontSize: 12);
var deleteButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.red.shade200,
  foregroundColor: Colors.red.shade800,
);
var successButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.green.shade200,
  foregroundColor: Colors.green.shade800,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFA86424),
          brightness: Brightness.light,
          primary: Color(0xFFA86424),
          secondary: Color(0xFFFFEA00),
          background: Color(0xFFFFFFFF),
          onPrimary: Color(0xFFFFFFFF),
        ),
        fontFamily: GoogleFonts.mali().fontFamily,
        textTheme: GoogleFonts.maliTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            if (routeSettings.name == SignInView.routeName) {
              return const SignInView();
            }
            return const PosShopView();
          },
        );
      },
    );
  }
}
