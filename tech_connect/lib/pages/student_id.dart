import "package:flutter/material.dart";

class StudentID extends StatefulWidget {
  StudentID({super.key});

  @override
  State<StudentID> createState() => _StudentIDState();
}

class _StudentIDState extends State<StudentID> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Container (
                  width: 100,
                  child: Image.asset("images/logo.png"),),
              ],
              ),
            ),
        ),
      ),
    );
  }
}