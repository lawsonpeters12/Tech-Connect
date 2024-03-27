import 'package:flutter/material.dart';
import 'package:tech_connect/pages/org_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/pages/add_event_page.dart';

class OrganizationPage extends StatelessWidget {
  final String orgName;

  OrganizationPage({required this.orgName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(orgName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _requestJoin();
                  },
                  child: Text('Request to Join'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrganizationChatPage(orgName: orgName),
                  ),
                );
              },
              child: Text('View Organization Chat'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to AddEventPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(orgName: orgName),
                  ),
                );
              },
              child: Text('Add Event'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('View Requests'),
            ),
            SizedBox(height: 20),
            Text(
              'Upcoming Events:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: EventList(orgName: orgName),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addMember(String orgName, User currentUser) async {
    try {
      // Get the current user's email
      String? userEmail = currentUser.email;

      // Add the user to the organization's member collection
      await FirebaseFirestore.instance
          .collection('Organizations')
          .doc(orgName)
          .collection('members')
          .doc(currentUser.uid)
          .set({
        'user': userEmail,
        'role': 'member',
      });

      print('User added to organization successfully');
    } catch (error) {
      print('Failed to add user to organization: $error');
    }
  }

  void _requestJoin() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      addMember(orgName, currentUser);
    }
  }
}

class EventList extends StatelessWidget {
  final String orgName;

  EventList({required this.orgName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Organizations')
          .doc(orgName)
          .collection('Events')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final List<Widget> eventTiles =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          final Map<String, dynamic>? data =
              document.data() as Map<String, dynamic>?;

          if (data == null || data['eventName'] == null) {
            return SizedBox(); // Skip rendering if data is null
          }

          final String eventName = data['eventName'];

          return ListTile(
            title: Text(eventName),
            // You can add more details here if needed
          );
        }).toList();

        return ListView(
          children: eventTiles,
        );
      },
    );
  }
}
