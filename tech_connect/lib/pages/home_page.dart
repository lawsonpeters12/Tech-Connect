import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tech_connect/pages/DM_page.dart';
import 'package:tech_connect/pages/friend_page.dart';
import 'package:tech_connect/pages/campus_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getDarkModeValue();
    createGoogleUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String event1 = 'Last day to register for Spring graduation';
  String event2 = 'Easter Holiday Begins';
  String event3 = 'Easter Holiday Ends';
  String event4 = 'Deadline for completing “I” grade work from Winter';
  String event5 = 'Deadline for faculty submission of “I” grade work from Winter';
  String event6 = 'Advising begins for currently enrolled students';
  String event7 = 'Last day to drop courses or resign with “W” grades';
  String event8 = 'Early Web Registration for Summer & Fall Quarter 2024';
  String event9 = 'Early Web Registration for Veterans and Degree Candidate Seniors ≥ 110 hours';

  String eventInfo1 = 'Friday, March 29';
  String eventInfo2 = 'Friday, March 29';
  String eventInfo3 =  'Monday, April 1';
  String eventInfo4 = 'Friday, April 5';
  String eventInfo5 = 'Friday, April 12';
  String eventInfo6 = 'Monday, April 29';
  String eventInfo7 = 'Friday, May 3';
  String eventInfo8 = 'Monday, May 6';
  String eventInfo9 = 'Monday, May 6';

  bool isLoading = false;
  bool isDarkMode = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
        title: Text('Home Page'),
        leading: Container(),
        actions: [
          Image.asset("images/logo.png", fit: BoxFit.contain, height: 60),
          Spacer(),
          IconButton(
              icon: Icon(Icons.send_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) => FriendPage())));
              }),
          SizedBox(width: 20),
        ],
        bottom: TabBar(
          tabs: [
            Tab(text: 'Academic Calendar'),
            Tab(text: 'Crime and Alerts'),
          ],
          controller: _tabController,
        ),
      ),
      backgroundColor: isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1),
      body: TabBarView(
          children: [
            Center(
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Academic Calendar'),
                backgroundColor: isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1),
              ),
                  backgroundColor: isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isLoading
                            ? CircularProgressIndicator()
                            : Expanded(
                                child: SizedBox(
                                  height: 200.0,
                                  child: ListView(
                                    scrollDirection: Axis.vertical,
                                    children: [
                                      Text(
                                        event1,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo1),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event2,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo2),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event3,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo3),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event4,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo4),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event5,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo5),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event6,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo6),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event7,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo7),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event8,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo8),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Text(
                                        event9,
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(eventInfo9),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                    ],
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Center(child: Text('Alert and Crime')),
        ],
        controller: _tabController,
      ),
    );
  }
}