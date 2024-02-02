
import 'package:flutter/material.dart';
import 'package:tech_connect/user/appbar_widget.dart';
import 'package:tech_connect/user/profile_widget.dart';
import 'package:tech_connect/user/user.dart';
import 'package:tech_connect/user/textfield_widget.dart';
import 'package:tech_connect/user/user_preferences.dart';

class EditUserPage extends StatefulWidget{
  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  UserInf user = UserPreferences.myUser;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: buildAppBar(context),
    body: ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        ProfileWidget(imagePath: user.imagePath,
          isEdit: true,
          onClicked: () async {},
         ),
         const SizedBox(height: 24,),
         TextFieldWidget(
          label: 'Full Name',
          text: user.name,
          onChanged:(name) => user = user.copy(name:name),
         ),
         const SizedBox(height: 24,),
         TextFieldWidget(
          label: 'email',
          text: user.email,
          onChanged:(email) => user = user.copy(email:email),
         ),
         const SizedBox(height: 24,),
         TextFieldWidget(
          label: 'Bio',
          text: user.about,
          maxLines:5,
          onChanged:(about) => user = user.copy(about:about),
         ),
         const SizedBox(height: 24,),
         MaterialButton(onPressed: () {
          UserPreferences.setUser(user);
          Navigator.of(context).pop();
         },
         color: Colors.blue,
         shape: const BeveledRectangleBorder(),
         child: const Text('Save'),
         
         )
      ],
    )
  );
}