import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/components/click_button.dart';
import 'package:tech_connect/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // sign up button
  void signUp() async {
    if (passwordTextController.text != confirmPasswordTextController.text){
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
    }
    
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text, 
        password: passwordTextController.text
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }


  @override
  Widget build(BuildContext context){
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
                const Icon(
                  Icons.lock,
                  size: 100, 
                ),
                
                // create account
                const SizedBox(height: 50),
                const Text("Create an Account",),
                
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

                // confirm password
                const SizedBox(height: 25),

                MyTextField(
                  controller: confirmPasswordTextController, 
                  hintText: "Confirm Password", 
                  obscureText: true
                ),

                // sign in button
                const SizedBox(height: 50),

                MyButton(
                  onTap: signUp,
                  text: "Sign Up"
                ),
                
                // login if have account
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : [
                    Text("Already have an Account? ",
                    style: TextStyle(color: Colors.grey[700],),),
                    GestureDetector(
                    onTap : widget.onTap,
                    child : const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    )
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
