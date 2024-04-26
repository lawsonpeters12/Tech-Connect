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
  List<String> userEvents = [];

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

  Future<void> _getUserEvents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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
    for (String orgId in userOrgIds) {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('Organizations')
          .doc(orgId)
          .collection('Events')
          .get();
      List<String> orgEvents = eventSnapshot.docs
          .map((eventDoc) => eventDoc['eventName'].toString())
          .toList();

      setState(() {
        userEvents.addAll(orgEvents);
      });
    }
  }

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
                              eventName: userEvents[index],
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrganizationPage(
                                          orgName: userOrgs[index])),
                                );
                              },
                            ),
                        childCount: userEvents.length)),
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
    return Container(
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
    );
  }
}

class EventButton extends StatelessWidget {
  final String eventName;
  final VoidCallback onPressed;

  const EventButton({required this.eventName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: TextButton(
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tap to view event details',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
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

        final List<Widget> eventButtons =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          final Map<String, dynamic>? data =
              document.data() as Map<String, dynamic>?;

          if (data == null || data['eventName'] == null) {
            return SizedBox();
          }

          final String eventName = data['eventName'];

          return EventButton(
            eventName: eventName,
            onPressed: () {
              _showEventDetails(context, data);
            },
          );
        }).toList();

        return ListView(
          children: eventButtons,
        );
      },
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> eventData) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          eventData['eventName'] ?? 'name',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          eventData['location'] ?? 'location',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                      ])));
        });
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
