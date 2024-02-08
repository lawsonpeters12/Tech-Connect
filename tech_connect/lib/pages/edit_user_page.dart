import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/user/appbar_widget.dart';
import 'package:tech_connect/user/profile_widget.dart';
import 'package:tech_connect/user/user.dart';
import 'package:tech_connect/user/textfield_widget.dart';
import 'package:tech_connect/user/user_preferences.dart';

class EditUserPage extends StatefulWidget {
  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late UserInf user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Load user data from UserPreferences
    user = await UserPreferences.getUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(context),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: user.imagePath,
              isEdit: true,
              onClicked: () async {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Full Name',
              text: user.name,
              onChanged: (name) => user = user.copy(name: name),
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Major',
              text: user.major,
              onChanged: (major) => user = user.copy(major: major),
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Email',
              text: user.email, // Display email, not editable
              onChanged: (email) => user = user.copy(email: email),// Disable editing
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Bio',
              text: user.about,
              maxLines: 5,
              onChanged: (about) => user = user.copy(about: about),
            ),
            const SizedBox(height: 24),
            MaterialButton(
              onPressed: () async {
                await _updateUserData();
                Navigator.of(context).pop();
              },
              color: Colors.blue,
              shape: const BeveledRectangleBorder(),
              child: const Text('Save'),
            ),
          ],
        ),
      );

  Future<void> _updateUserData() async {
    // Get the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmail = currentUser?.email ?? 'anonymous';

    // Update the user document in Firestore
    await FirebaseFirestore.instance.collection('users').doc(userEmail).update({
      'name': user.name,
      'major': user.major,
      'about': user.about,
    });
  }
}
