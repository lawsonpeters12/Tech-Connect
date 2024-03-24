import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/components/click_button.dart';
import 'package:tech_connect/components/text_field.dart';
import 'package:tech_connect/pages/password_reset_page.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(198, 218, 231, 1),
      body: 
      SingleChildScrollView( 
      physics: const NeverScrollableScrollPhysics(),
      child: 
      SafeArea ( 
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
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

                // goto register page
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
              // goto forgot password page
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PasswordReset())),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10,),
              Container(
                width:300,
                height:80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // decoration: BoxDecoration(color: Colors.blue),
                    Image.asset(
                      "images/google_icon.png",
                      width: 45, height: 45,
                      fit:BoxFit.cover,
                    ),     
                    const SizedBox(width: 5.0,),
                    const Text('Sign-in with Google') // add gesture detector
                  ],
                ),
            ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}