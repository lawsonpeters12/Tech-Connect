import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_connect/pages/friend_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isDarkMode = false;

  TextStyle headerStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0);
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

  @override
  void initState() {
    eventGrabber();
    getDarkModeValue();
    createGoogleUser();
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
      backgroundColor: isDarkMode ? const Color.fromRGBO(167, 43, 42, 1) : const Color.fromRGBO(77, 95, 128, 100),
        title: const Text('Home Page'),
        leading: Container(),
        actions: [
          Image.asset("images/logo.png", fit: BoxFit.contain, height: 60),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) => const FriendPage())));
              }),
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor: isDarkMode ? const Color.fromRGBO(203, 102, 102, 40) : const Color.fromRGBO(198, 218, 231, 1),
      body: DefaultTabController(
        length: 2,
        child: TabBarView(
          children: [
            Center(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Academic Calendar'),
                  backgroundColor: isDarkMode ? const Color.fromRGBO(203, 102, 102, 40) : const Color.fromRGBO(198, 218, 231, 1),
                ),
                backgroundColor: isDarkMode ? const Color.fromRGBO(203, 102, 102, 40) : const Color.fromRGBO(198, 218, 231, 1),
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
                                    children:
                                    [
                                    Text(events[0]['formatted_date'], style: headerStyle,),
                                    Text(events[0]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[1]['formatted_date'], style: headerStyle,),
                                    Text(events[1]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[2]['formatted_date'], style: headerStyle,),
                                    Text(events[2]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[3]['formatted_date'], style: headerStyle,),
                                    Text(events[3]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[4]['formatted_date'], style: headerStyle,),
                                    Text(events[4]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[5]['formatted_date'], style: headerStyle,),
                                    Text(events[5]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[6]['formatted_date'], style: headerStyle,),
                                    Text(events[6]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[7]['formatted_date'], style: headerStyle,),
                                    Text(events[7]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[8]['formatted_date'], style: headerStyle,),
                                    Text(events[8]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[9]['formatted_date'],style: headerStyle,),
                                    Text(events[9]['event'], style: bodyStyle,),
                                    const SizedBox(height: 20),
                                    Text(events[10]['formatted_date'], style: headerStyle,),
                                    Text(events[10]['event'], style: bodyStyle,),

                                    ]
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
        ),
      ),
    );
  }
}