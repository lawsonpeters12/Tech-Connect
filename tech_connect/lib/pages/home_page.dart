import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
//import 'package:html/dom.dart' as dom;

class HomePage extends StatefulWidget { 
  const HomePage({super.key}); 
  
  @override 
  _HomePageState createState() => _HomePageState(); 
} 
  
class _HomePageState extends State<HomePage> { 
    
  // Strings to store the extracted Article titles 
  String result1 = 'Result 1'; 
  String result2 = 'Result 2'; 
  String result3 = 'Result 3'; 
    
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
      var elements = document.querySelectorAll('title');
     // print('something');
      elements.forEach(print);
      //document.outerHtml;
      //var document = response.body;
      
      var responseString1 = document 
            .getElementsByClassName('lw_cal_upcoming_events'); 
  
        print(responseString1);

      print(response.statusCode);
      //print(response.body);
      try { 
          /*
      // Scraping the first article title 
        var responseString1 = document 
            .getElementsByClassName('lw_cal_upcoming_events')[0] 
            .children[0] 
            .children[0] 
            .children[0]; 
  
        print(responseString1.text.trim()); 
          */
      // Scraping the second article title 
        var responseString2 = document 
            .getElementsByClassName('articles-list')[0] 
            .children[1] 
            .children[0] 
            .children[0]; 
  
        print(responseString2.text.trim()); 
          
      // Scraping the third article title 
        var responseString3 = document 
            .getElementsByClassName('articles-list')[0] 
            .children[2] 
            .children[0] 
            .children[0]; 
  
        print(responseString3.text.trim()); 
          
        // Converting the extracted titles into 
        // string and returning a list of Strings 
        return [ 
          //responseString1.text.trim(), 
          responseString2.text.trim(), 
          responseString3.text.trim() 
        ]; 
      } catch (e) { 
        return ['', '', 'ERROR!']; 
      } 
    } else { 
      return ['', '', 'ERROR: ${response.statusCode}.']; 
    } 
  } 
  
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
                children: [
                  SizedBox(height: 200,),
                  
                ],
              ),
              ),
              Container( color: Color.fromRGBO(198, 218, 231, 100),
                child: Row(children: [
                  SizedBox(height: 30,)
                ]),
              ),
            // if isLoading is true show loader 
            // else show Column of Texts 
            isLoading 
                ? CircularProgressIndicator() 
                : Container( color: Colors.white,
                    child: Row( mainAxisAlignment: MainAxisAlignment.center,
                      children: [ 
                      Column(
                        children: [
                          Text(result1, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                      SizedBox( 
                        
                        height: MediaQuery.of(context).size.height * 0.05, 
                        
                      ),
                      Text(result2, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05, 
                      ), 
                      Text(result3, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
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
                  result1 = response[0]; 
                  result2 = response[1]; 
                  result3 = response[2]; 
                  isLoading = false; 
                }); 
              }, 
              child: Text( 
                'Scrap Data', 
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