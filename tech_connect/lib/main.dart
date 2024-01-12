// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tech_connect/pages/first_page.dart';
// for debugging
import 'package:html/parser.dart';

void main() {
  // for debugging until line 12
  var document = parse(
      '<body>Hello world! <a href="www.html5rocks.com">HTML5 rocks!');
  print(document.outerHtml);

   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}