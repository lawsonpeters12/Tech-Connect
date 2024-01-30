// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tech_connect/pages/friend_page.dart';

class DMPage extends StatelessWidget{
  const DMPage({super.key});

  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        title: Text('DM Page'),
        leading: Container(),

        actions: [
          Image.asset(
            "images/logo.png",
            fit:BoxFit.contain,
            height:60
          ),
          SizedBox(width: 550),
          IconButton(
            icon: Icon(Icons.group_add_rounded),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: ((context) => FriendPage())));
            }
          ),
        SizedBox(width: 20),
        ]
        )
        );
  }
}