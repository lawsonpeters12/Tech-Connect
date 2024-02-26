// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrgsPage extends StatefulWidget {
  const OrgsPage({super.key});

  @override
  State<OrgsPage> createState() => _OrgsPageState();  
}

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Organizations')),
      );
  }

class _OrgsPageState extends State<OrgsPage>{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: organizationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class organizationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        title: Text('Organizations'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(77, 95, 128, 100),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16),
          OrganizationButton(
            label: 'All Organizations',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => allOrgs()),
              );
            },
          ),
          SizedBox(height: 16),
          OrganizationButton(
            label: 'My Organizations',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrgs()),
              );
            },
          ),
          SizedBox(height: 16),
          const Divider(
            height: 20.0,
            thickness: 5.0,
            indent: 0,
            endIndent: 0,
            color: Colors.black,
          ),
        ],
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

//Designer code for All Organizations Page
class allOrgs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(203, 51, 59, 100),
        title: Text("All Organizations"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: OrganizationButton(
              label: "ACM",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ACM()),
                );
              },
            ),
          ),
          Expanded(
            child: OrganizationButton(
              label: "WoSTEM",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrgsPage()),
                );
              },
            ),
          ),
          Expanded(
            child: OrganizationButton(
              label: "Math Club",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrgsPage()),
                );
              },
            ),
          ),
          Expanded(
            child: OrganizationButton(
              label: "LTSEC",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrgsPage()),
                );
              },
            ),
          ),
          Expanded(
            child: OrganizationButton(
              label: ". . .",
              onPressed: () {
                // Add logic for the last button
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyOrgs extends StatefulWidget {
  @override
  _MyOrgsState createState() => _MyOrgsState();
}

class _MyOrgsState extends State<MyOrgs> {
  bool isACMMember = false;

  @override
  void initState() {
    super.initState();
    _checkACMMembership();
  }

  Future<void> _checkACMMembership() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';

    CollectionReference organizations =
        FirebaseFirestore.instance.collection('Organizations');

    try {
      QuerySnapshot membershipSnapshot = await organizations
          .doc('ACM')
          .collection('members')
          .where('user', isEqualTo: userEmail)
          .get();

      setState(() {
        isACMMember = membershipSnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking ACM membership: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(203, 51, 59, 100),
        title: Text("My Organizations"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            padding: EdgeInsets.all(25.0),
            child: isACMMember
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ACM()),
                        );
                      },
                      child: Text('ACM'),
                    ),
                  )
                : Center(
                    child: Text(
                      "You have not joined any organizations",
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ACM extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(203, 51, 59, 100),
        title: Text("Association for Computing Machinery - ACM"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              _requestJoin();
            },
            child: Text(
              "Request Join",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            padding: EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Club Members",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Organizations')
                      .doc('ACM')
                      .collection('members')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final members = snapshot.data!.docs;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: members.map((member) {
                          final memberData =
                              member.data() as Map<String, dynamic>;
                          final memberName = memberData['user'] ??
                              'Unknown'; // Assuming 'name' is a field for each member
                          return Text(memberName);
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            padding: EdgeInsets.all(25.0),
            child: Column(
              children: [
                Text(
                  "ACM Connect",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "You must be a member of this organization to view and send messages.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _requestJoin() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? 'anonymous';

      CollectionReference orgMembersRef = FirebaseFirestore.instance
          .collection('Organizations')
          .doc('ACM')
          .collection('members');

      await orgMembersRef.add({
        'user': userEmail,
        // Add additional user info if needed
      });

      // Show a snackbar or a message to indicate successful join
    } catch (e) {
      print('Error requesting join: $e');
      // Handle error appropriately
    }
  }
}
