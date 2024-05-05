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
    //unreadStatus = getUnreadStatus(); // might be able to get rid of these
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool isDarkMode = false;

  String event1 = 'Last day to register for Spring graduation';
  String event2 = 'Easter Holiday Begins';
  String event3 = 'Easter Holiday Ends';
  String event4 = 'Deadline for completing “I” grade work from Winter';
  String event5 = 'Deadline for faculty submission of “I” grade work from Winter';
  String event6 = 'Advising begins for currently enrolled students';
  String event7 = 'Last day to drop courses or resign with “W” grades';
  String event8 = 'Early Web Registration for Summer & Fall Quarter 2024';
  String event9 = 'Early Web Registration for Veterans and Degree Candidate Seniors ≥ 110 hours';

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

  Future<List<String>> extractData() async {
    final url = Uri.parse('https://events.latech.edu/academic-calendar/all');

    final response = await http.Client().get(url);

    var document = parser.parse(response.body);
    List<String> data = document.getElementsByClassName("lw_events_title").map((e) => e.innerHtml).toList();

    print(data);

    if (response.statusCode == 200) {
      try {
        var responseEvent1 = document
            .getElementsByClassName('lw_cal_event_list')[1]
            .children[3];
        print(responseEvent1.text.trim());

        var responseInfo1 = document
            .getElementsByClassName('lw_events_time')[0]
            .children[0]
            .children[0]
            .children[0];

        print(responseInfo1.text.trim());

        var responseEvent2 = document
            .getElementsByClassName('lw_events_title')[0]
            .children[1]
            .children[0]
            .children[0];

        print(responseEvent2.text.trim());

        var responseInfo2 = document
            .getElementsByClassName('lw_events_time')[0]
            .children[0]
            .children[0]
            .children[0];

        print(responseInfo2.text.trim());

        var responseEvent3 = document
            .getElementsByClassName('lw_events_title')[0]
            .children[2]
            .children[0]
            .children[0];

        print(responseEvent3.text.trim());

        var responseInfo3 = document
            .getElementsByClassName('lw_events_time')[0]
            .children[0]
            .children[0]
            .children[0];

        print(responseInfo3.text.trim());

        return [
          responseEvent1.text.trim(),
          responseInfo1.text.trim(),
          responseEvent2.text.trim(),
          responseInfo2.text.trim(),
          responseEvent3.text.trim(),
          responseInfo3.text.trim(),
        ];
      } catch (e) {
        return ['', '', 'ERROR!', '', '', ''];
      }
    } else {
      return ['', '', 'ERROR: ${response.statusCode}.', '', '', ''];
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

Future<bool> getUnreadStatus() async {
  bool test = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userEmail = currentUser?.email ?? '';
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userEmail)
    .get();
  Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
  List<dynamic> friendsList = userData?['friend_list_test'] ?? [];
  for (var i = 0; i < friendsList.length; i++){
    if(friendsList[i]['unread'] == true){
      test = true;
    }
  }
  return test;
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
        // stack might not be neededif we want to stick with a chat icon or a "send" icon (the message icon led to the friends page anyway)
        Stack(
        children: [
          FutureBuilder(future: getUnreadStatus(), builder: (context, snapshot) {
            // might get rid of loading circle for this
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  CircularProgressIndicator();
            } 
            else {
              bool unreadStatus = snapshot.data ?? false;
              if(unreadStatus){
                return IconButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendPage()));},
                  icon: Icon(Icons.mark_chat_unread_outlined)
                );
              }
              else {
                return IconButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendPage()));},
                  icon: Icon(Icons.chat_bubble_outline)
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
          stream: FirebaseFirestore.instance.collection('alerts').orderBy('timestamp',descending: true).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
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
                          content: Text(details),
                          actions: [], // Remove the actions property if not needed
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
                    subtitle: Text(DateFormat('EEEE, MMMM d h:mm a')
                        .format(timestamp)), // Format timestamp as desired
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