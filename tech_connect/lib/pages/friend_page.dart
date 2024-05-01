import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:tech_connect/pages/other_user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  late Future<List<String>> friendsList;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    friendsList = fetchFriendsList();
    getDarkModeValue();
  }

  Future<List<String>> fetchFriendsList() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmail = currentUser?.email ?? '';
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .get();

    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    List<dynamic> friendsList = userData?['friends_list'] ?? [];
    return friendsList.cast<String>();
  }

    Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<List<String>> getIncomingFriendRequests() async {
    // Fetch incoming friend requests from Firestore
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userEmail = currentUser?.email ?? '';
    DocumentSnapshot requestDoc = await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(userEmail)
        .get();

    Map<String, dynamic>? requestData = requestDoc.data() as Map<String, dynamic>?;

    List<dynamic> incomingRequests = requestData?['incoming_friend_requests'] ?? [];
    return incomingRequests.cast<String>();
  }

  Future<void> refreshRequests() async {
    setState(() {}); // Refresh the UI
    friendsList = fetchFriendsList();
  }

  // gives user feedback when they accept a friend request
  Future<void> requestAcceptedFeedback() async {
    // SnackBar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Friend request accepted!")));
    // Light haptic feedback
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.lightImpact',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1),
        appBar: AppBar(
          backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              Text('Friends'),
              Spacer(),
              Image.asset(
                "images/logo.png",
                fit: BoxFit.contain,
                height: 60,
              ),
              SizedBox(width: 8),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(),
                );
              },
            ),
            SizedBox(width: 20),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1),
                title: TabBar(
                  tabs: [
                    Tab(text: 'Friends'),
                    Tab(text: 'Requests'),
                  ],
                ),
                floating: true,
                pinned: true,
                snap: false,
              ),
            ];
          },
          body: TabBarView(
            children: [
              FutureBuilder<List<String>>(
                future: friendsList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } 
                  else {
                    List<String> friendsList = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: friendsList.length,
                      itemBuilder: (context, index) {
                        String friendEmail = friendsList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherUserPage(otherUserEmail: friendEmail),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              friendEmail,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              FutureBuilder<List<String>>(
                future: getIncomingFriendRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  else {
                    List<String> incomingRequests = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: incomingRequests.length,
                      itemBuilder: (context, index) {
                        String requestEmail = incomingRequests[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherUserPage(otherUserEmail: requestEmail),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(requestEmail),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check),
                                onPressed: () async {
                                  User? currentUser = FirebaseAuth.instance.currentUser;
                                  String userEmail = currentUser?.email ?? '';
                                  await FirebaseFirestore.instance
                                      .collection('friend_requests')
                                      .doc(userEmail)
                                      .update({
                                      'incoming_friend_requests': FieldValue.arrayRemove([requestEmail])
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('friend_requests')
                                      .doc(requestEmail)
                                      .update({
                                      'outgoing_friend_requests': FieldValue.arrayRemove([userEmail])
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(requestEmail)
                                      .set({
                                      'friends_list': FieldValue.arrayUnion([userEmail])
                                  }, SetOptions(merge: true));
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userEmail)
                                      .set({
                                      'friends_list': FieldValue.arrayUnion([requestEmail])
                                  }, SetOptions(merge: true));
                                  refreshRequests(); 
                                  // TEST THIS
                                  requestAcceptedFeedback();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () async {
                                  User? currentUser = FirebaseAuth.instance.currentUser;
                                  String userEmail = currentUser?.email ?? '';
                                  await FirebaseFirestore.instance
                                      .collection('friend_requests')
                                      .doc(userEmail)
                                      .update({
                                      'incoming_friend_requests': FieldValue.arrayRemove([requestEmail])
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('friend_requests')
                                      .doc(requestEmail)
                                      .update({
                                      'outgoing_friend_requests': FieldValue.arrayRemove([userEmail])
                                  });
                                  refreshRequests();
                                  // TEST THIS 
                                  requestAcceptedFeedback();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),  
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Color.fromRGBO(198, 218, 231, 100),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
        }
      },
    )
  ];

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        query,
        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.normal),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getUserEmails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          List<String> searchResults = snapshot.data!;
          List<String> suggestions = searchResults.where((searchResult) {
            final result = searchResult.toLowerCase();
            final input = query.toLowerCase();
            return result.contains(input);
          }).toList();

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                title: Text(suggestion),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherUserPage(
                        otherUserEmail: suggestion,
                      ),
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

  Future<List<String>> getUserEmails() async {
    List<String> userEmails = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
      Map<String, dynamic> userData = doc.data();
      userEmails.add(userData['email']);
    }
    return userEmails;
  }
}