import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_connect/user/user.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyUser = 'user';

  static const myUser = UserInf(
    imagePath: 'images/icon_image.png',
    name: 'Name Lastname',
    email: 'email@email.com',
    major: 'Undeclared',
    about: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris pidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

    // isDarkMode: false
  );

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future<UserInf> getDefaultUser() async {
    // Get the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmail = currentUser?.email ?? '';

    // Retrieve the user document from Firestore based on the email
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .get();

    // Extract user information from the document
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    return UserInf(
      imagePath: userData['imagePath'] ?? 'images/icon_image.png',
      name: userData['name'] ?? 'Name Lastname',
      email: userData['email'] ?? 'emaill@email.com',
      major: userData['major'] ?? 'Undeclared',
      about:
          userData['about'] ??
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris pidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    );
  }

  static Future setUser(UserInf user) async {
    final json = jsonEncode(user.toJson());
    await _preferences.setString(_keyUser, json);
  }

  static UserInf getUser() {
    final json = _preferences.getString(_keyUser);
    final defaultUser = UserInf(
      imagePath: 'images/icon_image.png',
      name: 'Name Lastname',
      email: 'emaill@email.com',
      major: 'Undeclared',
      about:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris pidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    );
    return json == null ? defaultUser : UserInf.fromJson(jsonDecode(json));
  }
}
