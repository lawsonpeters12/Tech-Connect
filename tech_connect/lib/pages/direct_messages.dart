import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  String searchString = '';
  List<String> conversationID = [];
  final ProfanityFilter profanityFilter = ProfanityFilter();
  bool isDarkMode = false;


  File? imageFile;
  String? fileName;

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

  @override
  void initState() {
    super.initState();
    _messageStreamController = StreamController<QuerySnapshot>();
    _getOtherUserDisplayName();
    _getConversationID();
    _updateMessageStream();
    getDarkModeValue();

  }

  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }

  void _sendMessage() async {
    // update unread message status for the user theyre sending the message to
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
    }
    if (message.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? 'anonymous';
      String displayName = await _getUserDisplayName(userEmail);

      CollectionReference directMessages =
          FirebaseFirestore.instance.collection('directmessages');

      Timestamp serverTimestamp = Timestamp.now();

      try {
        await directMessages.add({
          'users': conversationID, 
          'message': message,
          'sender': userEmail,
          'sender_display_name': displayName,
          'timestamp': serverTimestamp,
          'type': "text",
        });

        _messageController.clear();
        _updateMessageStream();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
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
      print('Error fetching user display name: $e');
    }
    return 'anonymous';
  }

  void _getOtherUserDisplayName() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserEmail)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
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

  // Function creates a dialog with a textbox containing the message the user wants to edit. If the message is saved, the change is saved to the Firestore using the message's id from Firestore.
void showEditMessagePopup(String messageId, String currentMessage) {
 TextEditingController editMessageController = TextEditingController(text: currentMessage);
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
                await FirebaseFirestore.instance.collection('directmessages').doc(messageId).update(
                 {
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

void showMessageOptionsPopup(String messageId, String currentMessage, isImage) {
 showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Message Options"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(!isImage) // Can't edit image messages, only text messages
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showEditMessagePopup(messageId, currentMessage);
              },
              child: Text("Edit Message"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('directmessages').doc(messageId).delete();
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

void _updateMessageStream() {
  FirebaseFirestore.instance
      .collection('directmessages')
      .where('users', isEqualTo: conversationID) // 'users' field is the sorted array between the 2 unique emails
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((data) {
    _messageStreamController.add(data);
  });
}


void _getConversationID() {
  User? user = FirebaseAuth.instance.currentUser;
  String userEmail = user?.email ?? 'anonymous';
  conversationID = [userEmail, widget.otherUserEmail]..sort();
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

    CollectionReference directMessages =
        FirebaseFirestore.instance.collection('directmessages');
    directMessages.add({
      'users': conversationID,
      'message': imageUrl,
      'sender': userEmail,
      'sender_display_name': displayName,
      'timestamp': FieldValue.serverTimestamp(),
      'type': "image",
    }).then((_) {
      _updateMessageStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
        backgroundColor: appBarBackgroundColor,
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
                          searchString = "";
                          Navigator.pop(context);
                          _updateMessageStream();
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
      backgroundColor: pageBackgroundColor,
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

                  var messages = snapshot.data!.docs.where((message) {
                    var messageData = message.data() as Map<String, dynamic>;
                    return messageData['message'].contains(searchString);
                  }).toList();

                  List<Widget> messageWidgets = [];

                  User? user = FirebaseAuth.instance.currentUser;
                  String userEmail = user?.email ?? 'anonymous';

                  for (var message in messages) {
                    var messageData = message.data() as Map<String, dynamic>;
                    var timestamp = messageData['timestamp'] as Timestamp?;

                    String senderName = messageData['sender_display_name'] ?? 'unknown';

                    var formattedTime = timestamp != null
                        ? TimeOfDay.fromDateTime(timestamp.toDate())
                            .format(context)
                        : "00:00";
                    
                    var formattedDate = timestamp != null
                        ? "${timestamp.toDate().month}/${timestamp.toDate().day}"
                        : "";

                    bool isCurrentUser = messageData['sender'] == userEmail;
                    Color color = isCurrentUser ? Color.fromRGBO(145, 174, 241, 1) : Color.fromRGBO(184, 178, 178, 1);

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
                        
                        if (isCurrentUser) {
                          messageWidget = GestureDetector(
                            onLongPress: () {
                              showMessageOptionsPopup(message.id, messageData['message'], false);
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
                                senderName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListTile(
                                title: Image.network(
                                  messageData['message'],
                                  height: 150,
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
                            showMessageOptionsPopup(message.id, messageData['message'], true);
                          },
                          child: messageWidget,
                          );
                        }

                        messageWidgets.add(messageWidget);
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
