import 'package:flutter/material.dart';
import 'package:tech_connect/pages/org_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/pages/add_event_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizationPage extends StatefulWidget {
  final String orgName;

  OrganizationPage({required this.orgName});

  @override
  _OrganizationPageState createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orgName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              _showMembers(context, widget.orgName);
            },
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
                        OrganizationChatPage(orgName: widget.orgName),
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
                    builder: (context) => AddEventPage(orgName: widget.orgName),
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
              child: EventList(orgName: widget.orgName),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
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
      addMember(widget.orgName, currentUser);
    }
  }

  void _showMembers(BuildContext context, String orgName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Organization Members'),
          content: Container(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Organizations')
                  .doc(orgName)
                  .collection('members')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final List<String> members =
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                  final dynamic data = document.data();

                  // Check if data is null or not a map
                  if (data == null || data is! Map<String, dynamic>) {
                    return '';
                  }

                  // Access the 'user' field and convert it to a string
                  final dynamic userData = data['user'];
                  return userData?.toString() ?? '';
                }).toList();

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(members[index]),
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
