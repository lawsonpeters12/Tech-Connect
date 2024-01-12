import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/auth/login_register.dart';
import 'package:tech_connect/pages/first_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          // user is logged in
          if (snapshot.hasData){
            return FirstPage();
          }

          // user not logged in
          else {
            return const LoginRegister();
          }
        }
        ),
    );
  }
}