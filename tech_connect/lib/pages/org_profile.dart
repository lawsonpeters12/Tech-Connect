import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tech_connect/pages/org_chat.dart';
import 'package:tech_connect/pages/other_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_connect/pages/add_event_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//class to store and display member info
class Member {
  final String email;
  final String name;
  final String major;
  final String role;

  Member(
      {required this.email,
      required this.name,
      required this.major,
      required this.role});
}

class OrganizationPage extends StatefulWidget {
  final String orgName;

  OrganizationPage({required this.orgName});

  @override
  _OrganizationPageState createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  late Future<DocumentSnapshot> orgSnapshot;
  late Future<bool> isMember;
  late Future<bool> isAdmin;

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    orgSnapshot = FirebaseFirestore.instance
        .collection('Organizations')
        .doc(widget.orgName)
        .get();
    isMember = checkIfMember();
    isAdmin = checkIfAdmin();
  }

  // Checks if user is a member of the organization, chat is only viewable to user if they're an org member.
  Future<bool> checkIfMember() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmail = currentUser?.email ?? '';
    DocumentSnapshot<Map<String, dynamic>> members = await FirebaseFirestore
        .instance
        .collection('Organizations')
        .doc(widget.orgName)
        .collection('members')
        .doc(userEmail)
        .get();

    return members.exists;
  }

  // Checks if the user is an admin for the organization. Only admins can accept/decline requests to join the org.
  Future<bool> checkIfAdmin() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmail = currentUser?.email ?? '';

    DocumentSnapshot<Map<String, dynamic>> orgDoc = await FirebaseFirestore
        .instance
        .collection('Organizations')
        .doc(widget.orgName)
        .get();

    List<dynamic>? admins = orgDoc.data()?['admins'];
    return (admins != null && admins.contains(userEmail));
  }

  Future<void> acceptJoinRequest(String userEmail) async {
    DocumentReference orgDocRef = FirebaseFirestore.instance
        .collection('Organizations')
        .doc(widget.orgName);
    await orgDocRef.update({
      'join_requests': FieldValue.arrayRemove([userEmail]),
    });

    //Get user document from users collectino for user's displayed information
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .get();

    if (userSnapshot.exists) {
      String userName = userSnapshot.get('name');
      String userMajor = userSnapshot.get('major');
      String userRole = userSnapshot.get('role');
      String userEmail = userSnapshot.get('email');

      await orgDocRef.collection('members').doc(userEmail).set({
        'email': userEmail,
        'name': userName,
        'major': userMajor,
        'role': userRole
      });
    }
  }

  Future<void> declineJoinRequest(String userEmail) async {
    DocumentReference orgDocRef = FirebaseFirestore.instance
        .collection('Organizations')
        .doc(widget.orgName);
    await orgDocRef.update({
      'join_requests': FieldValue.arrayRemove([userEmail]),
    });
  }

  // gives user feedback when they request to join
  Future<void> requestSentFeedback() async {
    // SnackBar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request sent!")));
    // Light haptic feedback
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.lightImpact',
    );
  }

  // Lists all the users in the 'join_requests' field for an organization. An admin can choose to let them join or decline the request.
  Future<void> showJoinRequestsPopup(BuildContext context) async {
    DocumentSnapshot orgDoc = await FirebaseFirestore.instance
        .collection('Organizations')
        .doc(widget.orgName)
        .get();
    Map<String, dynamic> orgData = orgDoc.data() as Map<String, dynamic>;
    List<dynamic> joinRequests = orgData['join_requests'] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Join Requests'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: joinRequests.length,
                  itemBuilder: (context, index) {
                    String email = joinRequests[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OtherUserPage(otherUserEmail: email),
                                  ),
                                );
                              },
                              child: Text(
                                email,
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  acceptJoinRequest(email);
                                  setState(() {
                                    joinRequests.removeAt(index);
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  declineJoinRequest(email);
                                  setState(() {
                                    joinRequests.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // App bar displays org name, org profile picture, and an icon to view the members of the org
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: orgSnapshot,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              var profilePictureUrl = data['profile_picture'] ??
                  'https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Ftechconnect.PNG?alt=media&token=ad8c3eff-3c7b-4a60-8939-693de6fd9558';
              return Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      profilePictureUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(widget.orgName),
                ],
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrganizationMembersPage(orgName: widget.orgName),
                ),
              );
            },
          ),
        ],
      ),
      // Org description is stored and retrieved from the Firestore.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: orgSnapshot,
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  var description = data['description'] ??
                      'Organization at Louisiana Tech University';
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'About:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        description,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    // The button to join the organization is only visible if the user is NOT in the organization.
                    FutureBuilder<bool>(
                      future: isMember,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          bool isMember = snapshot.data ?? false;
                          if (!isMember) {
                            return ElevatedButton(
                              onPressed: () async {
                                User? user = FirebaseAuth.instance.currentUser;
                                String userEmail = user?.email ?? 'anonymous';
                                DocumentReference orgDocRef = FirebaseFirestore
                                    .instance
                                    .collection('Organizations')
                                    .doc(widget.orgName);
                                await orgDocRef.update({
                                  'join_requests':
                                      FieldValue.arrayUnion([userEmail]),
                                });
                                // Request sent
                                requestSentFeedback();
                              },
                              child: Text('Request to Join'),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    // Button for organization chat, retrieves from Firestore if the user is in the organization. The button is only visible if the user is a member of the org.
                    FutureBuilder<bool>(
                      future: isMember,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          bool isMember = snapshot.data ?? false;
                          if (isMember) {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrganizationChatPage(
                                        orgName: widget.orgName),
                                  ),
                                );
                              },
                              child: Text('View Organization Chat'),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    // Only show "View Join Requests" button if user is admin
                    FutureBuilder<bool>(
                      future: isAdmin,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          bool isAdmin = snapshot.data ?? false;
                          if (isAdmin) {
                            return ElevatedButton(
                              onPressed: () => showJoinRequestsPopup(context),
                              child: Text('View Join Requests'),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddEventPage(orgName: widget.orgName)));
                      },
                      child: Text('Add Event'),
                    ),
                  ],
                ),
              ],
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
}

// Lists all the members of the org and directs to their profiles if you click on their email
class OrganizationMembersPage extends StatelessWidget {
  final String orgName;

  OrganizationMembersPage({required this.orgName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$orgName Members'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Organizations')
            .doc(orgName)
            .collection('members')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            var members = snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return Member(
                  email: data['email'] ?? 'email',
                  name: data['name'] ?? 'name',
                  major: data['major'] ?? 'major',
                  role: data['role'] ?? 'role');
            }).toList();

            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserPage(
                              otherUserEmail: members[index].email),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(members[index].name),
                          subtitle: Text(members[index].email),
                          isThreeLine: true,
                          trailing: Text(members[index].role),
                        ),
                      ],
                    ));
              },
            );
          } else {
            return Center(
              child: Text('No members found.'),
            );
          }
        },
      ),
    );
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

// Lists the upcoming events for an organization
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
