import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NumbersWidget extends StatefulWidget {
  final String userEmail;
  const NumbersWidget({super.key, required this.userEmail});
  
  @override
  _NumbersWidgetState createState() => _NumbersWidgetState();
}

class _NumbersWidgetState extends State<NumbersWidget> {
  late Future<int> friendsCountFuture;

  @override
  void initState() {
    super.initState();
    friendsCountFuture = getNumFriends();
  }

  Future<int> getNumFriends() async {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> friendsList = userData['friends_list'] ?? [];
        return friendsList.length;
      }
      return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: friendsCountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return buildButton(context, '${snapshot.data}', 'Friends');
        }
      },
    );
  }

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 2),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
