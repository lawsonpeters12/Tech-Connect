import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tech_connect/pages/DM_page.dart';
import 'package:tech_connect/pages/friend_page.dart';
import 'package:tech_connect/pages/id_page.dart';
//import 'package:';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // might need to be Future<List<String>>
  Future<void> extractData() async {
    String url = 'https://events.latech.edu';
    
    final response = await http.Client().get(Uri.parse(url));
    //print(response);
    //print('-----------------------------');
    print(response.body);
    //print(http.Request(response.body, Uri.parse(url)));
    
    //var responseData = json.decode(response.body);

    //print(responseData);
  }
/*
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
*/
  @override
  void initState() {
    super.initState();
    extractData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(77, 95, 128, 100),
      appBar: AppBar(
        backgroundColor:  Color.fromRGBO(77, 95, 128, 100),
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
      ),
      body: DefaultTabController(
        length: 2,
        child: TabBarView(
          children: [
            Center(
              child: Scaffold(
                appBar: AppBar(title: Text('Academic Calendar')),
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
        ),
      ),
    );
  }
}