// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class OrgsPage extends StatefulWidget {
  const OrgsPage({super.key});

  @override
  State<OrgsPage> createState() => _OrgsPageState();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Organizations')),
    );
  }
}

class _OrgsPageState extends State<OrgsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: organizationPage());
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
        backgroundColor: Color.fromRGBO(203, 51, 59, 100),
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
                MaterialPageRoute(builder: (context) => myOrgs()),
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
                  MaterialPageRoute(builder: (context) => acm()),
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

class myOrgs extends StatelessWidget {
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
            child: Center(
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

class acm extends StatelessWidget {
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
            onPressed: () {},
            child: Text("Request Join", selectionColor: Color.fromARGB(1, 1, 1, 1)),
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
              children: [
                Text("Club Members", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("There are no members in this organization yet"),
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
                Text("ACM Connect", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("You must be a member of this organization to view and send messages."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
