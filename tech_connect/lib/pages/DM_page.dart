import 'package:flutter/material.dart';
import 'package:tech_connect/pages/friend_page.dart';

class DMPage extends StatelessWidget {
  const DMPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('DM Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.group_add_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: ((context) => FriendPage())),
              );
            },
          ),
          SizedBox(width: 20),
        ],
        flexibleSpace: Container(
          alignment: Alignment.center,
          child: Image.asset(
            "images/logo.png",
            fit: BoxFit.contain,
            height: 60,
          ),
        ),
      ),
    );
  }
}
