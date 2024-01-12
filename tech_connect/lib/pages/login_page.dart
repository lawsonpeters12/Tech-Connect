import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/components/click_button.dart';
import 'package:tech_connect/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  
  // sign in button
  void logIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword
        (email: emailTextController.text, 
        password: passwordTextController.text);
    } on FirebaseAuthException catch (e) {
      displayMessage(e.code);
    }  
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      body: SafeArea ( 
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Container(
                  width: 100, 
                  child: Image.asset("images/logo.png"),),
                
                // welcome
                const SizedBox(height: 50),
                const Text("Welcome to Tech Connect!",),
                
                // email
                const SizedBox(height: 25),
            
                MyTextField(
                  controller: emailTextController, 
                  hintText: 'example@latech.edu', 
                  obscureText: false
                ),
                // password
                const SizedBox(height: 25),

                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true
                ),
                // sign in button
                const SizedBox(height: 50),

                MyButton(
                  onTap: logIn,
                  text: "Login"
                ),

                // register page
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : [
                    GestureDetector(
                    onTap : widget.onTap,
                    child : const Text(
                      "Create Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}