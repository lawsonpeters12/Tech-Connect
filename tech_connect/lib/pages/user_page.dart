// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:tech_connect/components/click_button.dart';
import 'package:tech_connect/pages/edit_user_page.dart';
//import 'package:tech_connect/pages/register_page.dart';
import 'package:tech_connect/user/appbar_widget.dart';
import 'package:tech_connect/user/user_preferences.dart';
import 'package:tech_connect/user/profile_widget.dart';
import 'package:tech_connect/user/user.dart';
import 'package:tech_connect/user/numbers_widget.dart';
//import 'package:tech_connect/main.dart';

/*
FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
*/

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
// checks if the user doc exists
/*
// TODO: get access to fire store and work on this
  Future checkUserInFirestore(User user, String username) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

    if(!doc.exists){
      print('User Does Not Exist');
    }
  }
  */
// add logout button
  @override
  Widget build(BuildContext context){
    final user = UserPreferences.getUser();
    
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: user.imagePath,
            onClicked: () async {
                await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditUserPage(),)
              );
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          buildName(user),
          NumbersWidget(),
          const SizedBox(height: 48),
          buildAbout(user),
        ],
      )
      
    );
  }

  Widget buildName(UserInf user) => Column(
    children: [
      Text(
        user.name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        user.major,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      const SizedBox(height: 4),
      Text( 
        user.email,
        style:TextStyle(color: Colors.grey)
      ),
    ],
  );

  Widget buildAbout(UserInf user) => Container(
    padding: EdgeInsets.symmetric(horizontal: 48),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Bio',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16,),
      Text(user.about,
      style: TextStyle(fontSize:16, height: 1.4),
      )
    ],
  )
  );
}