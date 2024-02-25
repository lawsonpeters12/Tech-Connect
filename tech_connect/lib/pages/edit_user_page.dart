import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/user/appbar_widget.dart';
import 'package:tech_connect/user/profile_widget.dart';
import 'package:tech_connect/user/user.dart';
import 'package:tech_connect/user/textfield_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

class EditUserPage extends StatefulWidget {
  final Function(UserInf) updateUserData;

  EditUserPage({required this.updateUserData});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late UserInf user;
  bool _isLoading = true;
  File? imageFile;
  String? fileName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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
    setState(() {
      user = UserInf(
        imagePath: userData['profile_picture'] ?? '',
        name: userData['name'] ?? '',
        major: userData['major'] ?? '',
        email: userData['email'] ?? '',
        about: userData['about'] ?? '',
      );
      _isLoading = false;
    });
  }

    Future<void> _openGallery() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
      }
      _uploadProfilePictureToFirebase();
    });
  }

  Future<void> _uploadProfilePictureToFirebase() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userEmail = currentUser?.email ?? 'anonymous';

  String timestamp = DateTime.now().toUtc().toIso8601String();
  fileName = '$userEmail-$timestamp.jpg';

  var ref = FirebaseStorage.instance.ref().child('images').child(fileName!);

  var uploadTask = await ref.putFile(imageFile!);

  String imageUrl = await uploadTask.ref.getDownloadURL();

  uploadProfilePictureToFirestore(imageUrl, currentUser!);
}

void uploadProfilePictureToFirestore(String imageUrl, User currentUser) async {
  String userEmail = currentUser.email ?? 'anonymous';

  await FirebaseFirestore.instance.collection('users').doc(userEmail).update({
    'profile_picture': imageUrl,
  });

  // Create a new UserInf instance with the new profile picture so the picture is immediately shown on user_page when this page is popped
  UserInf updatedUser = UserInf(
    imagePath: imageUrl,
    name: user.name,
    major: user.major,
    email: user.email,
    about: user.about,
  );

  widget.updateUserData(updatedUser);
}

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(context),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: 32),
                physics: BouncingScrollPhysics(),
                children: [
                  ProfileWidget(
                    imagePath: user.imagePath,
                    isEdit: true,
                    onClicked: () async {
                      await _openGallery();
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFieldWidget(
                    label: 'Full Name',
                    text: user.name,
                    onChanged: (name) => user = user.copy(name: name),
                  ),
                  const SizedBox(height: 24),
                  TextFieldWidget(
                    label: 'Major',
                    text: user.major,
                    onChanged: (major) => user = user.copy(major: major),
                  ),
                  const SizedBox(height: 24),
                  TextFieldWidget(
                    label: 'Bio',
                    text: user.about,
                    maxLines: 5,
                    onChanged: (about) => user = user.copy(about: about),
                  ),
                  const SizedBox(height: 24),
                  MaterialButton(
                    onPressed: () async {
                      await _updateUserData();
                      // Close the EditUserPage
                      Navigator.of(context).pop();
                    },
                    color: Colors.blue,
                    shape: const BeveledRectangleBorder(),
                    child: const Text('Save'),
                  ),
                ],
              ),
      );

  Future<void> _updateUserData() async {
    // Get the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmail = currentUser?.email ?? 'anonymous';

    // Update the user document in Firestore
    await FirebaseFirestore.instance.collection('users').doc(userEmail).update({
      'name': user.name,
      'major': user.major,
      'about': user.about,
    });

    // Call the update function passed from UserPage to update the user data
    widget.updateUserData(user);
  }
}
