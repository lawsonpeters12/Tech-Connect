import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/user/appbar_widget.dart';
import 'package:tech_connect/user/profile_widget.dart';
import 'package:tech_connect/user/user.dart';

class OtherUserPage extends StatefulWidget {
  final String otherUserEmail;

  OtherUserPage({required this.otherUserEmail});

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
      imagePath: otherUserData['profile_picture'] ?? '',
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
      backgroundColor: Colors.white, 
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
                      },
                      child: Text('Add Friend'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                      },
                      child: Text('Message'),
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
