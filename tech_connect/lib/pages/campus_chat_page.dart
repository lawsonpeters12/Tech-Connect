import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:tech_connect/pages/org_profile.dart';

class CampusChatPage extends StatefulWidget {
  const CampusChatPage({Key? key}) : super(key: key);

  @override
  _CampusChatPageState createState() => _CampusChatPageState();
}

class _CampusChatPageState extends State<CampusChatPage> {
  final ProfanityFilter profanityFilter = ProfanityFilter();

  TextEditingController _messageController = TextEditingController();
  late Future<void> _initializeControllerFuture;
  String currentChatTopic = "Main Chat";
  late StreamController<QuerySnapshot> _messageStreamController;
  String searchString = '';
  late bool isAdmin = false;

  
  File? imageFile;
  String? fileName;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _messageStreamController = StreamController<QuerySnapshot>();
    _updateMessageStream(currentChatTopic);
    getDarkModeValue();
    checkAdminStatus();
  }

  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _sendMessage() async {
    String message = _messageController.text;
    String censoredMessage = profanityFilter.censorString(message);
    
    if (censoredMessage.isNotEmpty) {
      if(censoredMessage != message){
        showDialog(
          context: context, 
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Profanity Detected"),
              content: Text("The following words have been removed. Please try again."),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                    child: Text('OK'),
                  ),
                ],
              );         
            }
          );
          return;
      }
      
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? 'anonymous';
      String displayName = await _getUserDisplayName(userEmail);

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
          'sender_display_name': displayName
        });

        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? '';
    var adminDoc = await FirebaseFirestore.instance.collection('admins').doc(userEmail).get();
    setState(() {
      isAdmin = adminDoc.exists;
    });
  }

  Future<String> _getUserDisplayName(String userEmail) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
        return userData['name'] ?? '';
      }
    } catch (e) {
      print('Could not find user : $e');
    }
    return 'anonymous';
  }


// Function creates a dialog with a textbox containing the message the user wants to edit. If the message is saved, the change is saved to the Firestore using the message's id from Firestore.
  void showEditMessagePopup(String messageId, String currentMessage) {
    TextEditingController editMessageController =
        TextEditingController(text: currentMessage);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Message"),
          content: TextField(
            controller: editMessageController,
            decoration: InputDecoration(hintText: "Edit message"),
          ),
          actions: [
            ElevatedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                String editedMessage = editMessageController.text;
                if (editedMessage != "") {
                  await FirebaseFirestore.instance
                      .collection('messages')
                      .doc(messageId)
                      .update({
                    'message': editedMessage,
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showMessageOptionsPopup(
      String messageId, String currentMessage, isImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Message Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isImage) // Can't edit image messages, only text messages
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showEditMessagePopup(messageId, currentMessage);
                  },
                  child: Text("Edit Message"),
                ),
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('messages')
                      .doc(messageId)
                      .delete();
                  Navigator.pop(context);
                },
                child: Text("Delete Message"),
              ),
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

    uploadImageToFirestore(imageUrl);
  }

  void uploadImageToFirestore(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';
    String displayName = await _getUserDisplayName(userEmail);

    CollectionReference messages =
        FirebaseFirestore.instance.collection('messages');
    messages.add({
      'user': userEmail,
      'message': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'chat_topic': currentChatTopic,
      'type': "image",
      'sender_display_name': displayName
    }).then((_) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 16),
            Center(
              child: Text(
                currentChatTopic,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode
            ? Color.fromRGBO(167, 43, 42, 1)
            : Color.fromRGBO(77, 95, 128, 100),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Search Messages'),
                    content: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchString = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            searchString = '';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Clear Search'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Search'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: isDarkMode
          ? Color.fromRGBO(203, 102, 102, 40)
          : Color.fromRGBO(198, 218, 231, 1),
          drawer: Drawer(
  child: ListView(
    children: [
      Container(
        height: 100,
        color: Colors.grey,
        child: Center(
          child: Text(
            'Select Chat Topic',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      ListTile(
        title: Text('Main Chat'),
        onTap: () {
          _updateChatTopic("Main Chat");
          Navigator.pop(context);
        },
      ),
      ListTile(
        title: Text('Lost Item Chat'),
        onTap: () {
          _updateChatTopic("Lost Item Chat");
          Navigator.pop(context);
        },
      ),
      ListTile(
        title: Text('Campus Events'),
        onTap: () {
          _updateChatTopic("Campus Events");
          Navigator.pop(context);
        },
      ),
    ],
  ),
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

                  User? user = FirebaseAuth.instance.currentUser;
                  String userEmail = user?.email ?? 'anonymous';

                  for (var message in messages) {
                    var messageData = message.data() as Map<String, dynamic>;
                    var timestamp = messageData['timestamp'] as Timestamp?;

                    var formattedTime = timestamp != null
                        ? TimeOfDay.fromDateTime(timestamp.toDate())
                            .format(context)
                        : "00:00";

                    var formattedDate = timestamp != null
                        ? "${timestamp.toDate().month}/${timestamp.toDate().day}"
                        : "";

                    String senderName = messageData['sender_display_name'] ??
                        messageData['user'];

                    bool isCurrentUser = messageData['user'] == userEmail;
                    Color color = isCurrentUser
                        ? Color.fromRGBO(145, 174, 241, 1)
                        : Color.fromRGBO(184, 178, 178, 1);

                    if (messageData['message'].contains(searchString)) {
                      if (messageData['type'] == 'text') {
                        Widget messageWidget = Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$senderName: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${messageData['message']}',
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Text(
                              '$formattedDate\t\t\t$formattedTime',
                              style: TextStyle(
                                color: Color.fromARGB(255, 101, 101, 101),
                              ),
                            ),
                          ),
                        );

                        if(messageData['chat_topic'] == "Campus Events") {
                          messageWidget = GestureDetector(
                            onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrganizationPage(orgName: messageData['user'])
                                  ),
                                );
                            },
                            child: messageWidget,
                          );
                        }

                        else if (isCurrentUser) {
                          messageWidget = GestureDetector(
                            onLongPress: () {
                              showMessageOptionsPopup(
                                  message.id, messageData['message'], false);
                            },
                            child: messageWidget,
                          );
                        }
                        else if(isAdmin) {
                          messageWidget = GestureDetector(
                            onLongPress: () {
                              showMessageOptionsPopup(
                                  message.id, messageData['message'], true);
                            },
                            child: messageWidget,
                          );
                        }

                        messageWidgets.add(messageWidget);
                      } else if (messageData['type'] == 'image' && searchString == '') {
                        Widget messageWidget = Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$senderName:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListTile(
                                title: Image.network(
                                  messageData['message'],
                                  height: 100,
                                ),
                                subtitle: Text(
                                  '$formattedDate\t\t\t$formattedTime',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 101, 101, 101),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (isCurrentUser) {
                          messageWidget = GestureDetector(
                            onLongPress: () {
                              showMessageOptionsPopup(
                                  message.id, messageData['message'], true);
                            },
                            child: messageWidget,
                          );
                        }
                        else if(isAdmin) {
                          messageWidget = GestureDetector(
                            onLongPress: () {
                              showMessageOptionsPopup(
                                  message.id, messageData['message'], true);
                            },
                            child: messageWidget,
                          );
                        }

                        messageWidgets.add(messageWidget);
                      }
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
                    onPressed: _openGallery,
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