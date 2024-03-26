import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/pages/org_chat.dart';

class OrgsPage extends StatefulWidget {
  @override
  _OrgsPageState createState() => _OrgsPageState();
}

class _OrgsPageState extends State<OrgsPage> {
  void _routeToAllOrgsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllOrgsPage()),
    );
  }

  void _routeToMyOrgsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyOrgsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Organizations')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Action for the first button
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllOrgsPage()),
                );
              },
              child: Text('All Organizations'),
            ),
            SizedBox(height: 16), // Adjust spacing between buttons if needed
            TextButton(
              onPressed: () {
                // Action for the second button
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyOrgsPage()),
                );
              },
              child: Text('My Organizations'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrganizationButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OrganizationButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: TextButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class OrgDetails extends StatelessWidget {
 final String orgName;

 const OrgDetails({required this.orgName});

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(orgName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Details for $orgName'),
            SizedBox(height: 16), // Adjust spacing between elements if needed
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                 context,
                 MaterialPageRoute(
                    builder: (context) => OrganizationChatPage(orgName: orgName),
                 ),
                );
              },
              child: Text('Org Chat'),
            ),
          ],
        ),
      ),
    );
 }
}

class AllOrgsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('All Organizations')),
      body: Center(
        child: _buildOrgsList(),
      ),
    );
  }

  Widget _buildOrgsList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('Organizations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final organizations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: organizations.length,
            itemBuilder: (context, index) {
              final orgName = organizations[index].id;
              return OrganizationButton(
                label: orgName,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrgDetails(orgName: orgName)),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

class MyOrgsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Organizations')),
      body: Center(
        child: Text('This page will display organizations user is a member of'),
      ),
    );
  }
}
