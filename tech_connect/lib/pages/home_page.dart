import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tech_connect/pages/DM_page.dart';
import 'package:tech_connect/pages/id_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String event1 = 'Last Day of Classes';
  String event2 = 'Early Web Registration Ends for Spring Quarter 2024';
  String event3 = '1st Scheduled Purge';
  String event4 = 'WINTER 2023-2024 QUARTER ENDS';
  String event5 = 'Winter Commencement Exercises';
  String event6 = 'All Other Grades Due';
  String event7 = 'Grades “live” on Student BOSS';
  String event8 = 'SPRING QUARTER 2024 BEGINS';
  String event9 = 'Placement Exams';

  String eventInfo1 = 'Tuesday, February 27';
  String eventInfo2 = 'Wednesday, February 28';
  String eventInfo3 = 'Wednesday, February 28';
  String eventInfo4 = 'Saturday, March 2';
  String eventInfo5 = 'Saturday, March 2';
  String eventInfo6 = 'Monday, March 4';
  String eventInfo7 = 'Tuesday, March 5';
  String eventInfo8 = 'Tuesday, March 12';
  String eventInfo9 = 'Tuesday, March 12';

  bool isLoading = false;

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
      backgroundColor: Color.fromRGBO(77, 95, 128, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        title: Text('Home Page'),
        leading: Container(),
        actions: [
          Image.asset("images/logo.png", fit: BoxFit.contain, height: 60),
          Spacer(),
          IconButton(
              icon: Icon(Icons.send_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) => DMPage())));
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