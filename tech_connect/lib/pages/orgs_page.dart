import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_connect/pages/org_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrgsPage extends StatefulWidget {
  @override
  _OrgsPageState createState() => _OrgsPageState();
}

class _OrgsPageState extends State<OrgsPage> {
  bool isDarkMode = false;

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
  }

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
      appBar: AppBar(
        centerTitle: true,
        title: Text('Organizations'),
        backgroundColor: isDarkMode
            ? Color.fromRGBO(167, 43, 42, 1)
            : Color.fromRGBO(77, 95, 128, 100),
      ),
      backgroundColor: isDarkMode
          ? Color.fromRGBO(203, 102, 102, 40)
          : Color.fromRGBO(198, 218, 231, 1),
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
            SizedBox(
              height: 50,
              child: Text("here"),
            ),
            Container(
                child: Column(
              children: [],
            ))
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

class AllOrgsPage extends StatefulWidget {
  @override
  _AllOrgsPageState createState() => _AllOrgsPageState();
}

class _AllOrgsPageState extends State<AllOrgsPage> {
  bool isDarkMode = false;

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('All Organizations'),
        backgroundColor: isDarkMode
            ? Color.fromRGBO(167, 43, 42, 1)
            : Color.fromRGBO(77, 95, 128, 100),
      ),
      backgroundColor: isDarkMode
          ? Color.fromRGBO(203, 102, 102, 40)
          : Color.fromRGBO(198, 218, 231, 1),
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
                      builder: (context) => OrganizationPage(orgName: orgName),
                    ),
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

class MyOrgsPage extends StatefulWidget {
  @override
  _MyOrgsPageState createState() => _MyOrgsPageState();
}

class _MyOrgsPageState extends State<MyOrgsPage> {
  List<String> userOrgs = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _getUserOrgs();
    getDarkModeValue();
  }

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _getUserOrgs() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Return if user is not logged in

    String userEmail = user.email ?? 'anonymous';

    QuerySnapshot orgsSnapshot =
        await FirebaseFirestore.instance.collection('Organizations').get();

    List<String> userOrgIds = [];

    for (QueryDocumentSnapshot orgSnapshot in orgsSnapshot.docs) {
      QuerySnapshot membershipSnapshot = await orgSnapshot.reference
          .collection('members')
          .where('email', isEqualTo: userEmail)
          .get();

      if (membershipSnapshot.docs.isNotEmpty) {
        userOrgIds.add(orgSnapshot.id);
      }
    }

    setState(() {
      userOrgs = userOrgIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Organizations'),
        backgroundColor: isDarkMode
            ? Color.fromRGBO(167, 43, 42, 1)
            : Color.fromRGBO(77, 95, 128, 100),
      ),
      backgroundColor: isDarkMode
          ? Color.fromRGBO(203, 102, 102, 40)
          : Color.fromRGBO(198, 218, 231, 1),
      body: ListView.builder(
        itemCount: userOrgs.length,
        itemBuilder: (context, index) {
          String orgName = userOrgs[index];

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
      ),
    );
  }
}
