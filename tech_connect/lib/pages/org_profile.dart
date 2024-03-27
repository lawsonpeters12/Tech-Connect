import 'package:flutter/material.dart';
import 'package:tech_connect/pages/org_chat.dart';
import 'package:tech_connect/pages/other_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_connect/pages/add_event_page.dart';

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
    DocumentSnapshot<Map<String, dynamic>> members = await FirebaseFirestore.instance
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
    
    DocumentSnapshot<Map<String, dynamic>> orgDoc = await FirebaseFirestore.instance
        .collection('Organizations')
        .doc(widget.orgName)
        .get();
    
    List<dynamic>? admins = orgDoc.data()?['admins'];
    return (admins != null && admins.contains(userEmail));
  }

  Future<void> acceptJoinRequest(String userEmail) async {
    DocumentReference orgDocRef = FirebaseFirestore.instance.collection('Organizations').doc(widget.orgName);
    await orgDocRef.update({
      'join_requests': FieldValue.arrayRemove([userEmail]),
    });
    await orgDocRef.collection('members').doc(userEmail).set({
      'email': userEmail
    });
  }

  Future<void> declineJoinRequest(String userEmail) async {
    DocumentReference orgDocRef = FirebaseFirestore.instance.collection('Organizations').doc(widget.orgName);
    await orgDocRef.update({
      'join_requests': FieldValue.arrayRemove([userEmail]),
    });
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
                            child: Text(
                              email,
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
              var profilePictureUrl =
                  data['profile_picture'] ??
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
                  builder: (context) => OrganizationMembersPage(orgName: widget.orgName),
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
                  var description = data['description'] ?? 'Organization at Louisiana Tech University';
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'About:',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          bool isMember = snapshot.data ?? false;
                          if (!isMember) {
                            return ElevatedButton(
                              onPressed: () async {
                                User? user = FirebaseAuth.instance.currentUser;
                                String userEmail = user?.email ?? 'anonymous';
                                DocumentReference orgDocRef = FirebaseFirestore.instance.collection('Organizations').doc(widget.orgName);
                                await orgDocRef.update({
                                  'join_requests': FieldValue.arrayUnion([userEmail]),
                                });
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
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          bool isMember = snapshot.data ?? false;
                          if (isMember) {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrganizationChatPage(orgName: widget.orgName),
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                            builder: (context) => AddEventPage(orgName: widget.orgName))
                        );
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
            var members = snapshot.data!.docs.map((doc) => doc.id).toList();
            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserPage(otherUserEmail: members[index]),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(members[index]),
                  ),
                );
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

        final List<Widget> eventTiles =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          final Map<String, dynamic>? data =
              document.data() as Map<String, dynamic>?;

          if (data == null || data['eventName'] == null) {
            return SizedBox(); 
          }

          final String eventName = data['eventName'];

          return ListTile(
            title: Text(eventName),
          );
        }).toList();

        return ListView(
          children: eventTiles,
        );
      },
    );
  }
}