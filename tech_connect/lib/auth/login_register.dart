import 'package:flutter/material.dart';
import 'package:tech_connect/pages/login_page.dart';
import 'package:tech_connect/pages/register_page.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  // show login page first
  bool showLoginPage = true;

  // toggle login and register
  void togglePages() {
    setState((){
      showLoginPage = !showLoginPage;
    });
  }
  
  @override
  Widget build(BuildContext context){
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    }
    else {
      return RegisterPage(onTap: togglePages);
    }
  }
}