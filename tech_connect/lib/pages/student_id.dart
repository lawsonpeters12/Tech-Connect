import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class StudentID extends StatefulWidget {
  StudentID({super.key});

  @override
  State<StudentID> createState() => _StudentIDState();
}

class _StudentIDState extends State<StudentID> {
  bool isDarkMode = false;
  Color pageBackgroundColor = Color.fromRGBO(198, 218, 231, 1);
  Color appBarBackgroundColor = Color.fromRGBO(77, 95, 128, 100);

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      pageBackgroundColor = isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1);
      appBarBackgroundColor = isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100);
    });
  }

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {Navigator.pop(context);
              },
            ),
        title:
          Text('Student ID'),
        backgroundColor: appBarBackgroundColor,
      ),
      backgroundColor: pageBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container (
                  width: 300,
                  child: Image.asset("images/card.png"),),
                Container (
                  width: 50,
                  child: Image.asset("images/wireless.png"),
                )
              ],
              ),
            ),
        ),
      ),
    );
  }
}