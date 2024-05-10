import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tech_connect/pages/DM_page.dart';
import 'package:tech_connect/pages/calendar_page.dart';
import 'package:tech_connect/pages/friend_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool isAdmin = false;
  //late Future<bool> unreadStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getDarkModeValue();
    createGoogleUser();
    checkAdminStatus();
    eventGrabber();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool isDarkMode = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextStyle headerStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle bodyStyle = const TextStyle(fontSize: 20.0);

  List events = [];

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void createGoogleUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'anonymous';
    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userEmail);
    var doc = await userDocRef.get();
    if (!doc.exists){
      await FirebaseFirestore.instance.collection('users').doc(userEmail).set({
        'email': userEmail,
        'about': "Nothing is known about this user yet",
        'major': "Undeclared",
        'profile_picture': "https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Fdefault_user.PNG?alt=media&token=c592af94-a160-43c1-8f2b-29a7123756dd",
        'name': userEmail
      });
    }
  }

    Future<void> checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? '';
    var adminDoc = await FirebaseFirestore.instance.collection('admins').doc(userEmail).get();
    setState(() {
      isAdmin = adminDoc.exists;
    });
  }

  
  void showMessageOptionsPopup(
      String messageId, String currentMessage, isImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Alert?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('alerts')
                      .doc(messageId)
                      .delete();
                  Navigator.pop(context);
                },
                child: Text("Delete Alert"),
              ),
            ],
          ),
        );
      },
    );
  }

Future<void> addAlert() async {
  String? message = await showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController controller = TextEditingController();
      return AlertDialog(
        title: Text('Add Alert'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter alert message'),
          onChanged: (value) => setState(() {}),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );

  if (message != null && message.isNotEmpty) {
    CollectionReference alerts = FirebaseFirestore.instance.collection('alerts');
    Timestamp serverTimestamp = Timestamp.now();

    try {
      await alerts.add({ 
        'message': message,
        'timestamp': serverTimestamp,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

  Future<List> queryValues() async {
  final snapshot = await firestore.collection('academic_calendar_events2').orderBy('date', descending: false).get();
  late List eventsQuery;
  if(snapshot.docs.isNotEmpty){
    eventsQuery = snapshot.docs.map((doc) => doc.data()).toList();
  }
  return eventsQuery;
}

  void eventGrabber() async {
    List eventsQ = await queryValues();
    setState(() {
      events = eventsQ;
    });
  }

// get friend requests
Future<bool> getFriendRequestStatus() async {
  User? currentUser = FirebaseAuth.instance.currentUser; 
  String userEmail = currentUser?.email ?? '';
  DocumentSnapshot friendRequests = await FirebaseFirestore.instance
    .collection('friend_requests')
    .doc(userEmail)
    .get();
  Map<String, dynamic>? requestData = friendRequests.data() as Map<String, dynamic>?;
  List<dynamic> requestList = requestData?['incoming_friend_requests'] ?? [];
  if (requestList.length <= 0){
    return false;
  }
  else {
    return true;
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: isDarkMode
          ? const Color.fromRGBO(167, 43, 42, 1)
          : const Color.fromRGBO(77, 95, 128, 100),
      title: const Text('Home Page'),
      leading: Container(),
      actions: [
        Image.asset("images/logo.png", fit: BoxFit.contain, height: 60),
        IconButton(
          icon: Icon(Icons.calendar_today_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
            );
          },
        ),
        Spacer(),
        Stack(
        children: [
          FutureBuilder(future: getFriendRequestStatus(), builder: (context, snapshot) {
            // might get rid of loading circle for this
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  CircularProgressIndicator();
            } 
            else {
              bool friendRequestStatus = snapshot.data ?? false;
              if(friendRequestStatus){
                return IconButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendPage()));},
                  icon: Icon(Icons.person_add_outlined)
                );
              }
              else {
                return IconButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendPage()));},
                  icon: Icon(Icons.person_outlined)
                );
              }
            }  
          }),
          // IconButton(
          //   icon: const Icon(Icons.send_outlined),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const FriendPage()),
          //     );
          //   },
          // ),
      ]),
        const SizedBox(width: 20),
      ],
      bottom: TabBar(
        tabs: [
          Tab(text: 'Academic Calendar'),
          Tab(text: 'Alerts'),
        ],
        controller: _tabController,
      ),
    ),
    backgroundColor: isDarkMode
        ? Color.fromRGBO(203, 102, 102, 1)
        : Color.fromRGBO(198, 218, 231, 1),
    body: TabBarView(
      controller: _tabController,
      children: [
        Center(
          child: Scaffold(
            appBar: AppBar(
            title: const Text('Academic Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: isDarkMode
                  ? Color.fromRGBO(203, 102, 102, 1)
                  : Color.fromRGBO(198, 218, 231, 1),
            ),
            backgroundColor: isDarkMode
                ? Color.fromRGBO(203, 102, 102, 1)
                : Color.fromRGBO(198, 218, 231, 1),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (events.isEmpty)
                        ? const CircularProgressIndicator()
                        : Expanded(
                            child: SizedBox(
                              height: 200.0,
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                children: [
                                  for (var i = 0; i < 11; i++)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Divider(),
                                        Text(
                                          events[i]['formatted_date'],
                                          style: headerStyle,
                                        ),
                                        Text(
                                          events[i]['event'],
                                          style: bodyStyle,
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text('Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: isDarkMode
                ? Color.fromRGBO(203, 102, 102, 1)
                : Color.fromRGBO(198, 218, 231, 1),
            ),
              backgroundColor: isDarkMode
                ? Color.fromRGBO(203, 102, 102, 1)
                : Color.fromRGBO(198, 218, 231, 1),
          body:StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('alerts2').orderBy('timestamp',descending: true).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (context, index) {
              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              DateTime timestamp = data['timestamp'].toDate();
              String message = data['message'];
              String details = data['details'] ?? message;

                return GestureDetector(
                  onLongPress: () {
                    if (isAdmin) {
                      showMessageOptionsPopup(
                          snapshot.data!.docs[index].id, message, false);
                    }
                  },
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Alert Details'),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                          content: Container(
                            height: 250,
                              child: SingleChildScrollView(
                                child: Text(details),
                          ),
                        ),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    title: Text(
                      message,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(DateFormat('EEEE, MMMM d h:mm a').format(timestamp)),
                ),
              );
            },
          );
        },
      ),
    ),
  ],
),
  );
}
}