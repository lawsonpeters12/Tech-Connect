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

  void _sendMessage() {
  String message = _messageController.text;
  if (message.isNotEmpty) {
    CollectionReference messages = FirebaseFirestore.instance.collection('messages');
    messages.add({
      'user': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _messageController.clear();
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromRGBO(198, 218, 231, 100),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                var messages = snapshot.data?.docs ?? [];
                List<Widget> messageWidgets = [];

                for (var message in messages.reversed) {
                  var messageData = message.data() as Map<String, dynamic>;
                  var timestamp = FieldValue.serverTimestamp();

                  messageWidgets.add(
                    ListTile(
                      title: Text('${messageData['user']}: ${messageData['message']}'),
                      subtitle: Text(
                        timestamp.toString()
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Enter your message...',
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
        ],
      ),
    ),
  );
}

}
