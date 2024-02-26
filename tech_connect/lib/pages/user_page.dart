import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/user/appbar_widget.dart';
import 'package:tech_connect/user/profile_widget.dart';
import 'package:tech_connect/user/user.dart';
import 'package:tech_connect/user/numbers_widget.dart';
import 'package:tech_connect/pages/edit_user_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<UserInf> userFuture;
  bool isDarkMode = false;
  Color backgroundColor = Color.fromRGBO(198, 218, 231, 1);

  @override
  void initState() {
    super.initState();
    userFuture = fetchUserData();
  }

  Future<UserInf> fetchUserData() async {
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
      imagePath: userData['profile_picture'] ?? 'https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Fdefault_user.PNG?alt=media&token=c592af94-a160-43c1-8f2b-29a7123756dd',
      name: userData['name'] ?? '',
      major: userData['major'] ?? '',
      email: userEmail,
      about: userData['about'] ?? '',
    );
  }

  void editUserPage() {
    // Navigate to the EditUserPage and pass a function to update user data
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditUserPage(updateUserData: updateUser)));
  }

  void updateUser(UserInf newUser) {
    // Update user data and trigger a rebuild
    setState(() {
      userFuture = Future.value(newUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: backgroundColor, // Use dynamic background color
      body: FutureBuilder<UserInf>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display loading indicator while fetching user data
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Handle error state
            return Center(
              child: Text('Error fetching user data'),
            );
          } else {
            // User data loaded successfully, display user information
            final user = snapshot.data!;
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  imagePath: user.imagePath,
                  onClicked: () async {
                    editUserPage();
                  },
                ),
                const SizedBox(height: 24),
                buildName(user),
                NumbersWidget(),
                const SizedBox(height: 48),
                buildAbout(user),
              ],
            );
          }
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('User Profile'),
      actions: [
        IconButton(
          icon: isDarkMode ? Icon(Icons.toggle_on) : Icon(Icons.toggle_off),
          onPressed: () {
            // Toggle dark mode
            setState(() {
              isDarkMode = !isDarkMode;
              // Change background color
              backgroundColor = isDarkMode ? Colors.red : Color.fromRGBO(198, 218, 231, 1);
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            FirebaseAuth.instance.signOut();
            // Navigate to sign-in page or any other page after sign-out
          },
        ),
      ],
    );
  }

  Widget buildName(UserInf user) => Column(
        children: [
          Text(
            user.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.major,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );

  Widget buildAbout(UserInf user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.about,
              style: TextStyle(fontSize: 16, height: 1.4),
            )
          ],
        ),
      );
}
