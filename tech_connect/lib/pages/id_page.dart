import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as Path;

class IDPage extends StatefulWidget {
  const IDPage({Key? key}) : super(key: key);

  @override
  _IDPageState createState() => _IDPageState();
}

class _IDPageState extends State<IDPage> {
  TextEditingController _messageController = TextEditingController();
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  String currentChatTopic = "main_chat"; // Initial chat topic
  StreamController<QuerySnapshot> _messageStreamController =
      StreamController<QuerySnapshot>();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _updateMessageStream(currentChatTopic);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _cameraController.initialize();
  }

  void dispose() {
    _cameraController.dispose();
    _messageStreamController.close();
    super.dispose();
  }

void _sendMessage() {
  String message = _messageController.text;
  if (message.isNotEmpty) {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';

    CollectionReference messages =
        FirebaseFirestore.instance.collection('messages');
    messages.add({
      'user': userEmail,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'chat_topic': currentChatTopic, // Add chat topic field
    }).then((_) {
      // After the message is added to Firestore, update the stream
      _updateMessageStream(currentChatTopic);
      _messageController.clear();
    });
  }
}

 void _showChatTopicsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Chat Topic'),
          content: Column(
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
              // Add more buttons for other chat topics as needed
            ],
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
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';

    Reference storageReference = FirebaseStorage.instance.ref().child('images/${DateTime.now().toUtc().toIso8601String()}');
    
    // Check if the file path is not null
    String filePath = file.path ?? '';

    UploadTask uploadTask = storageReference.putFile(File(filePath));

    await uploadTask.whenComplete(() async {
      String downloadUrl = await storageReference.getDownloadURL();

      CollectionReference messages =
          FirebaseFirestore.instance.collection('messages');
      messages.add({
        'user': userEmail,
        'image_url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile picture = await _cameraController.takePicture();

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Get the user's email
      String userEmail = user?.email ?? 'anonymous';

      // Upload the image to Firestore
      CollectionReference messages =
          FirebaseFirestore.instance.collection('messages');
      messages.add({
        'user': userEmail,
        'image_url': picture.path, // Assuming you want to store the image URL
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<String> uploadImageToFirebase(File file)async{
    String fileUrl = '';
    String fileName = Path.basename(file.path);
    var reference = FirebaseStorage.instance.ref().child('myfiles/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      fileUrl = value;
    });
    print("Url $fileUrl");
    return fileUrl;
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
                    : 'Lost Item Chat', // Update title based on current chat topic
                style: TextStyle(color: Colors.black),
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
                            '${messageData['user']}: ${messageData['message']}',
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