import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/components/click_button.dart';
import 'package:tech_connect/components/text_field.dart';

class PasswordReset extends StatefulWidget {
  PasswordReset({super.key});

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  // text editing controllers
  final emailTextController = TextEditingController();

  // password reset via Firebase
  void resetPass() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailTextController.text);
    } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  child: Image.asset("images/logo.png"),),
                
                // Reset Password Text
                const SizedBox(height: 50),
                const Text(
                  "Please input your email to\nreset password", 
                  textAlign: TextAlign.center,
                ),

                // email box
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailTextController,
                  hintText: "example@latech.edu", 
                  obscureText: false),

                // Submit button
                const SizedBox(height: 25),
                MyButton(
                  onTap: resetPass,
                  text: "Send Email")
                ],
            )
          ),
        ) 
      ),
    );
  }
}