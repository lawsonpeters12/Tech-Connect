import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
//import 'package:tech_connect/pages/id_page.dart';
//import 'package:html/dom.dart' as dom;


class HomePage extends StatefulWidget { 
  const HomePage({super.key}); 
  
  @override 
  _HomePageState createState() => _HomePageState(); 
} 
  
class _HomePageState extends State<HomePage> { 
  // Strings to store the extracted Article titles 
  String event1 = 'Last day to drop courses or resign with “W” grades'; 
  String event2 = 'Early Web Registration Begins for Spring and Summer Quarter 2024'; 
  String event3 = 'Early Registration for Veterans and Degree Candidate Seniors ≥ 110 hours'; 
  String event4 = 'Early Registration for Honors Students, Grad Students, & Eligible Athletes'; 
  String event5 = 'Early Registration for Seniors ≥ 100 hours'; 
  String event6 = 'Early Registration for Seniors ≥ 90 hours';
  String event7 = 'Early Registration for Juniors ≥ 80 hours'; 
  String event8 = 'Early Registration for Juniors ≥ 71 hours'; 
  String event9 = 'Early Registration for Juniors ≥ 60 hours';
  
  String eventInfo1 = 'Friday, February 2';
  String eventInfo2 = 'Monday, February 5';
  String eventInfo3 = 'Monday, February 5';
  String eventInfo4 = 'Monday, February 5';
  String eventInfo5 = 'Tuesday, February 6';
  String eventInfo6 = 'Tuesday, February 6';
  String eventInfo7 = 'Wednesday, February 7';
  String eventInfo8 = 'Wednesday, February 7';
  String eventInfo9 = 'Thursday, February 8';
  // boolean to show CircularProgressIndication 
  // while Web Scraping awaits 
  bool isLoading = false; 
  
  Future<List<String>> extractData() async { 

    // Getting the response from the targeted url 
      final url = Uri.parse('https://events.latech.edu/academic-calendar/all');
      
      final response = await http.Client().get(url);
      // TODO learn ajax command to get these scrapers working right
      var document = parser.parse(response.body);
      List<String> data = document.getElementsByClassName("lw_events_title").map((e) => e.innerHtml).toList();

      print(data);


     // var element = document.getElementById('lw_cal');

    if (response.statusCode == 200) { 
        

      try { 
      // Scraping the first event
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
          
      // Scraping the second event
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
          
      // Scraping the third event
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
        // Converting the extracted titles into 
        // string and returning a list of Strings 
        return [ 
          responseEvent1.text.trim(), 
          responseInfo1.text.trim(),
          responseEvent2.text.trim(), 
          responseInfo2.text.trim(),
          responseEvent3.text.trim(),
          responseInfo3.text.trim()
        ]; 
      } catch (e) { 
        return ['', '','ERROR!','', '','']; 
      } 
    } else { 
      return ['', '', 'ERROR: ${response.statusCode}.','','','']; 
    } 
  } 
    Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(backgroundColor: const Color.fromRGBO(198, 218, 231, 100),
        bottom: const TabBar(tabs: [
          Tab(icon: Icon(Icons.home)),
          Tab(icon: Icon(Icons.crisis_alert))
        ]),
        title:  Row(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Info Page'),
          Spacer(),
          Image.asset('images/icon_image.png',
          fit:BoxFit.contain,
          height:60),
        ],
        
        )
        ),
        body: TabBarView(
          children: [
            Center( 
            child: Scaffold(appBar: AppBar(title: Text('Academic Calendar')),
            body: Padding(padding: const EdgeInsets.all(16.0),
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                  ? CircularProgressIndicator()
                  : Expanded(child: SizedBox(height: 200.0, child:
                  ListView(
                    scrollDirection: Axis.vertical,
                    children: [
                      Text(event1,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo1),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event2,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo2),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event3,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo3),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event4,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo4),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event5,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo5),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event6,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo6),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event7,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo7),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event8,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo8),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(event9,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text(eventInfo9),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                    ],
                  )
                  )
                  )
              ],
            )),
            ),
            )
                ),
              const Center(child: Text('Alert and Crime'))
              ],
          )
          ),
    
        );
  }
  } 

