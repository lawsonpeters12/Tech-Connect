import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/user/appbar_widget.dart';
import 'package:tech_connect/user/profile_widget.dart';
import 'package:tech_connect/user/user.dart';
import 'package:tech_connect/pages/direct_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';


class OtherUserPage extends StatefulWidget {
  final String otherUserEmail;
  final bool darkMode;

  OtherUserPage({required this.otherUserEmail, this.darkMode = false});

  @override
  _OtherUserPageState createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  late Future<UserInf> otherUserFuture;

  @override
  void initState() {
    super.initState();
    otherUserFuture = fetchOtherUserData();
  }

  Future<UserInf> fetchOtherUserData() async {
    // Retrieve the other user document from Firestore based on the email
    DocumentSnapshot otherUserSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserEmail)
        .get();

    // Extract other user information from the document
    Map<String, dynamic> otherUserData =
        otherUserSnapshot.data() as Map<String, dynamic>;
    return UserInf(
      imagePath: otherUserData['profile_picture'] ?? 'https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Fdefault_user.PNG?alt=media&token=c592af94-a160-43c1-8f2b-29a7123756dd',
      name: otherUserData['name'] ?? '',
      major: otherUserData['major'] ?? '',
      email: otherUserData['email'] ?? '',
      about: otherUserData['about'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: widget.darkMode ? Color.fromRGBO(203, 51, 59, 100) : Color.fromRGBO(198, 218, 231, 100),
      body: FutureBuilder<UserInf>(
        future: otherUserFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display loading indicator while fetching other user data
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching other user data'),
            );
          } else {
            final otherUser = snapshot.data!;
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  imagePath: otherUser.imagePath,
                  onClicked: () {},
                ),
                const SizedBox(height: 24),
                buildName(otherUser),
                const SizedBox(height: 24),
                buildAbout(otherUser),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DirectMessagePage(otherUserEmail: otherUser.email)));
                      },
                      child: Text('Message'),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      // Update the current user's document in Firestore
                      User? currentUser = FirebaseAuth.instance.currentUser;
                      String userEmail = currentUser?.email ?? '';
                      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance.collection('friend_requests')
                          .doc(userEmail)
                          .get();

                      Map<String, dynamic>? currentUserData = currentUserDoc.data() as Map<String, dynamic>?;

                      List<dynamic> currentUserOutgoingRequests = currentUserData?['outgoing_friend_requests'] ?? [];
                      if (!currentUserOutgoingRequests.contains(otherUser.email)) {
                        currentUserOutgoingRequests.add(otherUser.email);
                        await FirebaseFirestore.instance.collection('friend_requests')
                            .doc(userEmail)
                            .set({'outgoing_friend_requests': currentUserOutgoingRequests}, SetOptions(merge: true)); // SetOptions(merge: true) will only edit 1 field of the document. Without it, the other fields get erased.
                      }

                      // Update the other user's document in Firestore
                      DocumentSnapshot otherUserDoc = await FirebaseFirestore.instance.collection('friend_requests')
                          .doc(otherUser.email)
                          .get();

                      Map<String, dynamic>? otherUserData = otherUserDoc.data() as Map<String, dynamic>?;

                      List<dynamic> otherUserIncomingRequests = otherUserData?['incoming_friend_requests'] ?? [];
                      if (!otherUserIncomingRequests.contains(userEmail)) {
                        otherUserIncomingRequests.add(userEmail);
                        await FirebaseFirestore.instance.collection('friend_requests')
                            .doc(otherUser.email)
                            .set({'incoming_friend_requests': otherUserIncomingRequests}, SetOptions(merge: true)); // SetOptions(merge: true) will only edit 1 field of the document. Without it, the other fields get erased.
                      }
                    },
                    child: Text('Add Friend'),
                  ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildName(UserInf otherUser) => Column(
    children: [
      Text(
        otherUser.name,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black),
      ),
      const SizedBox(height: 4),
      Text(
        otherUser.major,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.grey),
      ),
      const SizedBox(height: 4),
      Text(
        otherUser.email,
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );

  Widget buildAbout(UserInf otherUser) => Container(
    padding: EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        const SizedBox(height: 16),
        Text(
          otherUser.about,
          style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.grey),
        )
      ],
    ),
  );
}
