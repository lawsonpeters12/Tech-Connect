import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

class IDPage extends StatefulWidget {
  const IDPage({Key? key}) : super(key: key);

  @override
  _IDPageState createState() => _IDPageState();
}

class _IDPageState extends State<IDPage> {
  TextEditingController _messageController = TextEditingController();
  late Future<void> _initializeControllerFuture;
  String currentChatTopic = "main_chat";
  late StreamController<QuerySnapshot> _messageStreamController;

  File? imageFile;
  String? fileName;

  @override
  void initState() {
    super.initState();
    _messageStreamController = StreamController<QuerySnapshot>();
    _updateMessageStream(currentChatTopic);
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

    CollectionReference messages =
        FirebaseFirestore.instance.collection('messages');

    // Get server timestamp before adding the message
    Timestamp serverTimestamp = Timestamp.now();

    try {
      await messages.add({
        'user': userEmail,
        'message': message,
        'timestamp': serverTimestamp,
        'chat_topic': currentChatTopic,
        'type': "text",
      });

      // Clear the input field
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

void _showChatTopicsPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Chat Topic'),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              ElevatedButton(
                onPressed: () {
                  _updateChatTopic("main_chat");
                  Navigator.pop(context);
                },
                child: Text('Main Chat'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateChatTopic("lost_item_chat");
                  Navigator.pop(context);
                },
                child: Text('Lost Item Chat'),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void _updateChatTopic(String newChatTopic) {
    setState(() {
      currentChatTopic = newChatTopic;
    });
    _updateMessageStream(newChatTopic);
  }

void _updateMessageStream(String chatTopic) {
  FirebaseFirestore.instance
      .collection('messages')
      .where('chat_topic', isEqualTo: chatTopic)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((data) {
    _messageStreamController.add(data);
  });
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

    CollectionReference messages =
        FirebaseFirestore.instance.collection('messages');
    messages.add({
      'user': userEmail,
      'message': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'chat_topic': currentChatTopic, // Add chat topic field
      'type': "image",
    }).then((_) {
      // After the message is added to Firestore, update the stream
      _updateMessageStream(currentChatTopic);
    });
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
                        _openGallery(); // Call your existing method for opening gallery
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _showChatTopicsPopup();
              },
            ),
            SizedBox(width: 16),
            Center(
              child: Text(
                currentChatTopic == "main_chat"
                    ? 'Main Chat'
                    : 'Lost and Found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromRGBO(75, 97, 126, 1),
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

                    var userDisplayName = messageData['user'];

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
                              formattedTime,
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
                                  messageData['message'], // Assuming 'message' contains the image URL
                                  height: 100, // Adjust the height as needed
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
