import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
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

void nfcFeedback(String message) async {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  await SystemChannels.platform.invokeMethod<void>(
    'HapticFeedback.vibrate',
    'HapticFeedback.lightImpact',
  );
}

void _tagRead() {
  nfcFeedback("Please tap Student ID to the back of your phone.");
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmailNFC = currentUser?.email ?? '';
    
    result.value = tag.data;
    // store data in user's firebase table
    await FirebaseFirestore.instance.collection('users').doc(userEmailNFC).update({
    'nfc_data': result.value,
    });
    
    nfcFeedback("ID scanned! Refreshing page...");
    NfcManager.instance.stopSession();
  });
}

void _tagWriteNFCA() {
  nfcFeedback("Ready to scan...");
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
  _tagWriteNFCA();
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
            onPressed: () {
              Navigator.pop(context);
              NfcManager.instance.stopSession();
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
                      bool hasNFCData = snapshot.data ?? false;
                      if (!hasNFCData) {
                        return ElevatedButton(
                          child: Text("Scan Student ID?"),
                          onPressed: _tagRead,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appBarBackgroundColor,
                            textStyle: TextStyle(fontSize: 20),
                            foregroundColor: Colors.black,
                          ),
                          );
                      }
                      else {
                        return Column(
                          children: [Container (
                          width: 300,
                          child: Image.asset("images/card.png"),
                          ),
                        Container (
                          width: 50,
                          child: Image.asset("images/wireless.png"),
                          // output NFC data here
                        ),
                        ],
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