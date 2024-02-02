import 'dart:convert';
import 'package:tech_connect/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyUser = 'user';

  static const myUser = UserInf(
    imagePath: 'images/icon_image.png',
    name: 'Name Lastname',
    email: 'emaill@email.com',
    major: 'Undeclared',
    about: 'BIO--------------------------------------------------------------------------------BIO'

    // isDarkMode: false
  );

  static Future init() async =>
    _preferences = await SharedPreferences.getInstance();

    static Future setUser(UserInf user) async {
      final json = jsonEncode(user.toJson());

      await _preferences.setString(_keyUser, json);
    }

  static UserInf getUser(){
    final json = _preferences.getString(_keyUser);
    return json == null ? myUser : UserInf.fromJson(jsonDecode(json));
  }
}