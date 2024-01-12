// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  void _sendMessage() async {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Get the user's email
      String userEmail = user?.email ?? 'anonymous';

      CollectionReference messages = FirebaseFirestore.instance.collection('messages');
      messages.add({
        'user': userEmail,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Campus Chat',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Color.fromRGBO(75, 97, 126, 1), // Light blue color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('messages').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  var messages = snapshot.data?.docs ?? [];
                  List<Widget> messageWidgets = [];

                  for (var message in messages) {
                    var messageData = message.data() as Map<String, dynamic>;
                    var timestamp = messageData['timestamp'] as Timestamp?;

                    // Format the timestamp to display in HH:MM format
                    var formattedTime = timestamp != null
                        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
                        : '00:00';

                    // Create a white box for each message
                    messageWidgets.add(
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white, // Set the color of the message box
                          borderRadius: BorderRadius.circular(12), // Set the border radius for rounded corners
                        ),
                        child: ListTile(
                          title: Text(
                            '${messageData['user']}: ${messageData['message']}',
                            style: TextStyle(
                              color: Colors.black, // Set the text color for the message
                              fontWeight: FontWeight.bold, // Set the font weight if needed
                            ),
                          ),
                          subtitle: Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.grey, // Set the text color for the timestamp
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
                color: Colors.white, // Set the color of the text input box
                borderRadius: BorderRadius.circular(20), // Set the border radius for rounded corners
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message...',
                        border: InputBorder.none, // Remove the default border
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
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
