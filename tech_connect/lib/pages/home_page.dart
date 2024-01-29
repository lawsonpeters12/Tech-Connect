import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tech_connect/pages/id_page.dart';
import 'package:html/dom.dart' as dom;


class HomePage extends StatefulWidget { 
  const HomePage({super.key}); 
  
  @override 
  _HomePageState createState() => _HomePageState(); 
} 
  
class _HomePageState extends State<HomePage> { 
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        bottom: const TabBar(tabs: [
          Tab(icon: Icon(Icons.home)),
          Tab(icon: Icon(Icons.crisis_alert))
        ]),
        title: Row(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Home Page'),
          Spacer(),
          Image.asset('images/icon_image.png',
          fit:BoxFit.contain,
          height:60),
        ],
        
        )
        ),
        body:const TabBarView(
          children: [
            Center( 
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center, 
              
          
          )
          ),
          Center(child: Text('Alert and Crime'))
        ],
        )
        )
        );
  }
  // Strings to store the extracted Article titles 
  String event1 = 'event 1'; 
  String event2 = 'event 2'; 
  String event3 = 'event 3'; 
  
  String eventInfo1 = 'eventInfo1';
  String eventInfo2 = 'eventInfo2';
  String eventInfo3 = 'eventInfo3';
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


      var element = document.getElementById('lw_cal');

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
  /*
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        title: Row(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Home Page'),
          Spacer(),
          Image.asset('images/icon_image.png',
          fit:BoxFit.contain,
          height:60),
          
        ],),
        ),
        
       
      body: Padding( 
        padding: const EdgeInsets.all(16.0), 
        
        child: Center( 
            child: Column( 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [ 
            
              Container(color: Colors.white, child: Row(
              ),
              ),
              
              Container( color: Color.fromRGBO(198, 218, 231, 100),
                child: Row(children: [
                  SizedBox(height: 30),
                  Text('current quarter')
                ]),
              ),

            // if isLoading is true show loader 
            // else show Column of Texts 
            isLoading 
                ? CircularProgressIndicator() 
                : Container( color: Colors.white,
                    child: Row( mainAxisAlignment: MainAxisAlignment.start,
                      children: [ 
                      Column(
                        children: [
                          Text(event1, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                          Text(eventInfo1, style: TextStyle(fontSize:12, fontWeight: FontWeight.normal)),
                      SizedBox( 
                        height: MediaQuery.of(context).size.height * 0.15, 
                      ),
                      Text(event2, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                              Text(eventInfo2, style: TextStyle(fontSize:12,
                               fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15, 
                      ), 
                      Text(event3, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                              Text(eventInfo3, style: TextStyle(fontSize:12,
                               fontWeight: FontWeight.normal)),
                        ],
                      ),
                       
                    ], 
                  ),
                ), 
            SizedBox(height: MediaQuery.of(context).size.height * 0.08), 
            MaterialButton( 
             onPressed: () async { 
                 
              // Setting isLoading true to show the loader 
                setState(() { 
                  isLoading = true; 
                }); 
                  
                // Awaiting for web scraping function 
                // to return list of strings 
                final response = await extractData(); 
                  
                // Setting the received strings to be 
                // displayed and making isLoading false 
                // to hide the loader 
                setState(() { 
                  event1 = response[0]; 
                  eventInfo1 = response[1];

                  event2 = response[2];
                  eventInfo2 = response[3];

                  event3 = response[4];
                  eventInfo3 = response[5]; 
                  isLoading = false; 
                }); 
              }, 
              child: Text( 
                'Get Events', 
                style: TextStyle(color: Colors.white), 
              ), 
              color: Colors.blue, 
            ) 
          ], 
        )), 
      ),*/ 
    //); 
  } 
