import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:nfc_manager/nfc_manager.dart';
import 'package:tech_connect/components/ID_button.dart';
import 'package:tech_connect/user/user.dart';

class StudentID extends StatefulWidget {
  StudentID({super.key});

  @override
  State<StudentID> createState() => _StudentIDState();
}

class _StudentIDState extends State<StudentID> {
  bool isDarkMode = false;
  late  Future<bool> hasNFCData;
  late Future<String> userPFP;
  late Future<dynamic> userName;
  late UserInf user;
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
  //pop-up dialog test
  //showDialog(context: context, builder: (context) => AlertDialog(title: Text(message)));
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
    
    nfcFeedback("ID scanned! Please Refresh the Page...");
    NfcManager.instance.stopSession();
  });
}

void _deleteTag() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userEmailNFC = currentUser?.email ?? '';
  await FirebaseFirestore.instance.collection('users').doc(userEmailNFC).update({
    'nfc_data': FieldValue.delete(),
  });
  nfcFeedback("ID Deleted, Please Refresh Page...");
}

void _tagWriteNFCA() {
  // check if it is already writing, stop it if it is
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
  nfcFeedback("Tap ID Button to Scan.");
  return true;
}


// do this later, i dont feel like finishing this now
Future<void> getPFP() async {
 User? currentUser = FirebaseAuth.instance.currentUser;
 String userEmail = currentUser?.email ?? '';
 DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
 .collection('users')
 .doc(userEmail)
 .get();

 Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
 user = UserInf(
  imagePath: userData['profile_picture'],
  name: userData['name'] ?? '',
  email: '',
  about: '',
 );
 var userPFP = userData['profile_picture'] ?? 'https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Fdefault_user.PNG?alt=media&token=c592af94-a160-43c1-8f2b-29a7123756dd';
}

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
    hasNFCData = nfcDataExists();
    getPFP();
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
                        return Container (
                          width: 400,
                          height: 200,
                          child:
                          ElevatedButton(
                            child: Text("No ID on File.\n\nScan Student ID?", textAlign: TextAlign.center,),
                              onPressed: _tagRead,
                              style: ElevatedButton.styleFrom(
                              backgroundColor: appBarBackgroundColor,
                              textStyle: TextStyle(fontSize: 20),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                            ),
                          )
                        );
                      }
                      else {
                        return Column(
                          children: [
                            // ID
                            FutureBuilder(future: getPFP(), 
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting){
                                return CircularProgressIndicator();
                              }
                              else {
                                String nameText = "Louisiana Tech University ID\n\n\n\n${user.name}";
                                  return IDButton(
                                    onTap: _tagWriteNFCA,
                                    text: nameText,
                                    backgroundColor: pageBackgroundColor, 
                                    edgeColor: appBarBackgroundColor,
                                    userImage: user.imagePath,
                                  );
                              }
                            }
                            ),
                            // wireless transmit image
                            const SizedBox(height: 20,),
                            Container (
                              width: 50,
                              child: Image.asset("images/wireless.png"),
                            ),
                            // delete user NFC data
                            const SizedBox(
                              height: 200
                            ),
                            ElevatedButton(
                              onPressed: _deleteTag,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pageBackgroundColor,
                                textStyle: TextStyle(fontSize: 20),
                                foregroundColor: Colors.black,
                              ),
                              child: Text("Delete NFC Data")
                            )
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