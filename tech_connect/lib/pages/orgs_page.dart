import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/pages/org_chat.dart';
import 'package:tech_connect/pages/org_profile.dart';

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
              onPressed: _routeToAllOrgsPage,
              child: Text('All Organizations'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _routeToMyOrgsPage,
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


class AllOrgsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('All Organizations')),
      body: Center(
        child: _buildOrgsList(context),
      ),
    );
  }

  Widget _buildOrgsList(BuildContext context) {
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
                        builder: (context) => OrganizationPage(orgName: orgName)),
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
