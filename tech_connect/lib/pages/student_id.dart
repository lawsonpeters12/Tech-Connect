import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:nfc_manager/nfc_manager.dart';
import 'package:tech_connect/pages/test_id.dart';

class StudentID extends StatefulWidget {
  StudentID({super.key});

  @override
  State<StudentID> createState() => _StudentIDState();
}

class _StudentIDState extends State<StudentID> {
  bool isDarkMode = false;
  late  Future<bool> hasNFCData;
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
ValueNotifier<dynamic> result = ValueNotifier(null);

void _tagRead() {
  /// make a popup that will tell the user to scan their card
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    result.value = tag.data;
    // store data in user's firebase table
    NfcManager.instance.stopSession();
  });
}

Future<bool> nfcDataExists() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userEmail = currentUser?.email ?? '';
  
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
  .collection('users')
  .doc(userEmail)
  .get();
  
  Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
  var nfcData = userData['nfc_data'] ?? '';
  if (nfcData == '') {
    return false;
  }
  return true;
}

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
    hasNFCData = nfcDataExists();
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
        actions: [
          // TESTING PAGE
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TestID())),
            ),
          ],
        backgroundColor: appBarBackgroundColor,
      ),
      // Conditionally set this page based on whether or not NFC data is stored
      backgroundColor: pageBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: hasNFCData, 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return  CircularProgressIndicator();
                    } 
                    else {
                      bool hasNFCData = snapshot.data ?? false; // change this to grab from the function up top
                      if (!hasNFCData) {
                        return ElevatedButton(
                          child: Text("Scan Student ID?"),
                          onPressed: _tagRead,);
                      }
                      else {
                        Container (
                          width: 300,
                          child: Image.asset("images/card.png"),
                          );
                        // i dont know if I should return here, i might try to do return children: [] with these two containers in it
                        return Container (
                          width: 50,
                          child: Image.asset("images/wireless.png"),
                          // output NFC data here
                        );
                      }
                    }
                  })
              ],
              ),
            ),
        ),
      ),
    );
  }
}