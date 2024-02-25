import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

class DirectMessagePage extends StatefulWidget {
  final String otherUserEmail;

  DirectMessagePage({required this.otherUserEmail});

  @override
  _DirectMessagePageState createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  TextEditingController _messageController = TextEditingController();
  late Future<void> _initializeControllerFuture;
  late StreamController<QuerySnapshot> _messageStreamController;
  String otherUserName = '';

  File? imageFile;
  String? fileName;

  @override
  void initState() {
    super.initState();
    _messageStreamController = StreamController<QuerySnapshot>();
    _updateMessageStream();
    _getOtherUserName();
  }

  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }

  void _sendMessage() async {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? 'anonymous';
      List<String> users = [userEmail, widget.otherUserEmail];
      users.sort();

      CollectionReference directMessages =
          FirebaseFirestore.instance.collection('directmessages');

      // Get server timestamp before adding the message
      Timestamp serverTimestamp = Timestamp.now();

      try {
        await directMessages.add({
          'users': '${users[0]}_${users[1]}', // Store the users in a DM conversation as a concatenated string with an underscore to separate them.
          'message': message,
          'sender': userEmail, // Store sender's email
          'timestamp': serverTimestamp,
          'type': "text",
        });

        // Clear the input field
        _messageController.clear();

        _updateMessageStream();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

void _getOtherUserName() async {
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserEmail)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        otherUserName = userData['name'] ?? '';
      });
    }
  } catch (e) {
    print('Error fetching other user name: $e');
  }
}

  void _showCameraOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text('Take picture'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        Navigator.pop(context);
                        _openGallery(); 
                      },
                    ),
                    Text('Choose from gallery'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateMessageStream() {
    FirebaseFirestore.instance
      .collection('directmessages')
      .where('users', isEqualTo: _generateUsersString())
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((data) {
        _messageStreamController.add(data);
      });
  }


// The users in a DM conversation are stored as a concatenated string in alphabetical order. 
// This is the unique identifer for a particular conversation.
  String _generateUsersString() {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';
    List<String> users = [userEmail, widget.otherUserEmail];
    users.sort(); 
    return '${users[0]}_${users[1]}';
  }

  Future<void> _openGallery() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
      }
      _uploadImageToFirebase();
    });
  }

  Future<void> _uploadImageToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';

    String timestamp = DateTime.now().toUtc().toIso8601String();
    fileName = '$userEmail-$timestamp.jpg';

    var ref = FirebaseStorage.instance.ref().child('images').child(fileName!);

    var uploadTask = await ref.putFile(imageFile!);

    String imageUrl = await uploadTask.ref.getDownloadURL();

    print(imageUrl);

    uploadImageToFirestore(imageUrl);
  }

  void uploadImageToFirestore(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';

    CollectionReference directMessages =
        FirebaseFirestore.instance.collection('directmessages');
    directMessages.add({
      'users': _generateUsersString(),
      'message': imageUrl,
      'sender': userEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'type': "image",
    }).then((_) {
      // After the message is added to Firestore, update the stream
      _updateMessageStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName), // Display the name of the user you're messaging
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messageStreamController.stream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  var messages = snapshot.data?.docs ?? [];
                  List<Widget> messageWidgets = [];

                  for (var message in messages) {
                    var messageData = message.data() as Map<String, dynamic>;
                    var timestamp = messageData['timestamp'] as Timestamp?;

                    var formattedTime = timestamp != null
                        ? TimeOfDay.fromDateTime(timestamp.toDate())
                            .format(context)
                        : "00:00";

                    var userDisplayName = messageData['sender'] == FirebaseAuth.instance.currentUser?.email
                        ? 'You'
                        : otherUserName;

                    if (messageData['type'] == 'text') {
                      messageWidgets.add(
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              '$userDisplayName: ${messageData['message']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              formattedTime, // Display sender's email
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (messageData['type'] == 'image') {
                      messageWidgets.add(
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,  // Align to the left
                            children: [
                              // Display the sender's name above the image
                              Text(
                                '$userDisplayName:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListTile(
                                title: Image.network(
                                  messageData['message'], 
                                  height: 150, // Adjust the height as needed
                                ),
                                subtitle: Text(
                                  formattedTime, 
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: messageWidgets.length,
                    itemBuilder: (context, index) => messageWidgets[index],
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _showCameraOptions,
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
