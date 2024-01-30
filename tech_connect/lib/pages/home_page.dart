import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tech_connect/pages/DM_page.dart';
import 'package:tech_connect/pages/id_page.dart';
//import 'package:html/dom.dart' as dom;

class HomePage extends StatefulWidget { 
  const HomePage({super.key}); 
  
  @override 
  _HomePageState createState() => _HomePageState(); 
} 
  
class _HomePageState extends State<HomePage> { 
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
    final response = 
        await http.Client().get(Uri.parse('https://events.latech.edu/day/categories/Academic%20Calendar')); 
      
        // Status Code 200 means response has been received successfully 
    if (response.statusCode == 200) { 
        
    // Getting the html document from the response 
      var document = parser.parse(response.body);
      //var elements = document.querySelectorAll('title');
     // print('something');
      //elements.forEach(print);
      //document.outerHtml;
      //var document = response.body;
      /*
      var responseEvent1 = document 
            .getElementsByClassName('lw_cal_upcoming_events'); 
  
        print(responseEvent1);

      print(response.statusCode);
      */
      //print(response.body);
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
  
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        title: Text('Home Page'),
        leading: Container(),

        actions: [
          Image.asset(
            'images/icon_image.png',
            fit:BoxFit.contain,
            height:60
          ),
          SizedBox(width: 550),
          IconButton(
            icon: Icon(Icons.send_outlined),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: ((context) => DMPage())));
            }
          ),
        SizedBox(width: 20),
        ]
        ),
        
       
      body: Padding( 
        padding: const EdgeInsets.all(16.0), 
        
        child: Center( 
            child: Column( 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [ 
            
              Container(color: Colors.white, child: Row(
                children: [
                  SizedBox(height: 200), IconButton( icon: Icon(Icons.chat_bubble),
             onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: ((context) => IDPage())));
             },
              color: Colors.blue,
            ) 
                  
                ],
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
                        
                        height: MediaQuery.of(context).size.height * 0.05, 
                        
                      ),
                      Text(event2, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                              Text(eventInfo2, style: TextStyle(fontSize:12, fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05, 
                      ), 
                      Text(event3, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                              Text(eventInfo3, style: TextStyle(fontSize:12, fontWeight: FontWeight.normal)),
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
      ), 
    ); 
  } 
} 
