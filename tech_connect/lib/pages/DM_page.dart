// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class DMPage extends StatelessWidget{
  const DMPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      body: Center(child: Text("DM Page")),
    );
  }
}