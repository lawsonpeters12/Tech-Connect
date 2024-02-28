 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_connect/main.dart';
import 'package:tech_connect/pages/student_id.dart';
import 'package:tech_connect/main.dart';

void logOut() async {
  await FirebaseAuth.instance.signOut();
}

AppBar buildAppBar(BuildContext context){
  return AppBar(
    backgroundColor: Color.fromRGBO(75, 97, 126, 1),
    elevation: 0,
    leading:
      IconButton(
        onPressed:() => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => StudentID())),
        icon: Icon(Icons.credit_card),
      ),
    actions: [    
      IconButton(
        onPressed: logOut,
        icon: Icon(Icons.logout),
      ),
    ]
  );
}