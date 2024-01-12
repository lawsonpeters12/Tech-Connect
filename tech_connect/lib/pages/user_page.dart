// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/components/click_button.dart';
import 'package:tech_connect/main.dart';

class UserPage extends StatefulWidget{
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // log user out
  void logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      body: SafeArea (
        child: Center(
          child: Padding (
            padding: const EdgeInsets.symmetric(horizontal: 25,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text("User Page"),
                const SizedBox(height: 50),
                MyButton(onTap: logOut, text: "Log Out."),
              ]
            ),
          )
        
        ),
      ),
      
    );
  }
}