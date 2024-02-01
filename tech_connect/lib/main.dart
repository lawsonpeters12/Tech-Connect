// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/auth/auth.dart';
import 'package:tech_connect/firebase_options.dart';
import 'package:tech_connect/pages/first_page.dart';
// for coding and debugging
import 'pages/home_page.dart';
import 'pages/user_page.dart';
import 'pages/edit_user_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(dividerColor: Colors.black),
      // home: AuthPage(),
       home: UserPage(),
       //home: EditUserPage(),
      //home: FirstPage(),
    );
  }
}