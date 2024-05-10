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
  List<String> userOrgs = [];
  List<Map<String, String>> userEvents = [];

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
    _getUserOrgs();
    _getUserEvents();
    _mounted = true;
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

Future<void> _getUserOrgs() async {
  User? user = FirebaseAuth.instance.currentUser;
  String userEmail = user?.email ?? 'anonymous';

  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userEmail)
      .get();

  List<dynamic> userOrgsData = userDoc.get('organizations') ?? [];
  List<String> userOrgList = userOrgsData.cast<String>(); 
  print(userOrgsData);

  setState(() {
    userOrgs = userOrgList;
  });
}

Future<void> _getUserEvents() async {
  User? user = FirebaseAuth.instance.currentUser;
  String userEmail = user?.email ?? 'anonymous';

  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userEmail)
      .get();

  List<dynamic> userOrgsData = userDoc.get('organizations') ?? [];
  List<String> userOrgList = userOrgsData.cast<String>();

  QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
      .collection('eventsGlobal')
      .where('orgName', whereIn: userOrgList)
      .get();

  List<Map<String, String>> orgEvents = eventsSnapshot.docs
      .map((eventDoc) => {
            'eventName': eventDoc['eventName'].toString(),
            'orgName': eventDoc['orgName'].toString(),
          })
      .toList();

  setState(() {
    userEvents = orgEvents;
  });
}


  bool _mounted = false;

  void _routeToAllOrgsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllOrgsPage()),
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
        body: Padding(
            padding: EdgeInsets.all(8),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color.fromRGBO(77, 95, 128, 100),
                    ),
                    margin:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    child: TextButton(
                      onPressed: _routeToAllOrgsPage,
                      child: Text(
                        'View All Orgs',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    child: Text(
                      'Your Organizations',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (context, index) => OrganizationButton(
                              label: userOrgs[index],
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrganizationPage(
                                          orgName: userOrgs[index])),
                                );
                              },
                            ),
                        childCount: userOrgs.length)),
                SliverToBoxAdapter(
                  child: Container(
                    child: Text(
                      'Your Events',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => EventButton(
                      eventName: userEvents[index]['eventName'] ??
                          '', // Access eventName from the map
                      orgName: userEvents[index]['orgName'] ??
                          '', // Access orgName from the map
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrganizationPage(
                                orgName: userEvents[index]['orgName'] ?? ''),
                          ),
                        );
                      },
                    ),
                    childCount: userEvents.length,
                  ),
                ),
              ],
            )));
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
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Color.fromRGBO(77, 95, 128, 100),
        ),
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class EventButton extends StatelessWidget {
  final String eventName;
  final String orgName;
  final VoidCallback onPressed;

  const EventButton(
      {required this.eventName,
      required this.orgName,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Color.fromRGBO(77, 95, 128, 100),
        ),
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: TextButton(
          onPressed: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                'View Org Page',
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
            ],
          ),
        ),
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
  String searchString = '';

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
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Search Organizations'),
                      content: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchString = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            setState(() {
                              searchString = '';
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Clear Search'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Search'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        backgroundColor: isDarkMode
            ? Color.fromRGBO(203, 102, 102, 40)
            : Color.fromRGBO(198, 218, 231, 1),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: _buildOrgsList(context))));
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

          final filteredOrgs = organizations.where((org) {
            final orgName = org.id.toLowerCase();
            final searchLowerCase = searchString.toLowerCase();
            return orgName.contains(searchLowerCase);
          }).toList();

          return ListView.builder(
            itemCount: filteredOrgs.length,
            itemBuilder: (context, index) {
              final orgName = filteredOrgs[index].id;
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