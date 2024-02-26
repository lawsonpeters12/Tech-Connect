// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_connect/auth/auth.dart';
import 'package:tech_connect/firebase_options.dart';
import 'package:tech_connect/pages/first_page.dart';
import 'package:tech_connect/pages/login_page.dart';
import 'package:tech_connect/user/user_preferences.dart';
// for coding and debugging
//import 'pages/home_page.dart';
//import 'pages/user_page.dart';
//import 'pages/edit_user_page.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_connect/pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/*
class ThemeProvider extends ChangeNotifier{
  ThemeMode themeMode = ThemeMode.dark;

  bool get DarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;  
    notifyListeners();
  }
}

class myThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Color.fromRGBO(203, 51, 59, 100),
    colorScheme: ColorScheme.dark(),
  );

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: Color.fromRGBO(198, 218, 231, 100),
      colorScheme: ColorScheme.light(),
  );
}
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(dividerColor: Colors.black),
      home: FirstPage(),
    );
  }
}