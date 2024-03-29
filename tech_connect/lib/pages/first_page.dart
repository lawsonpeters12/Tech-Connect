// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:tech_connect/pages/home_page.dart';
import 'package:tech_connect/pages/campus_chat_page.dart';
import 'package:tech_connect/pages/map_page.dart';
import 'package:tech_connect/pages/orgs_page.dart';
import 'package:tech_connect/pages/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FirstPage extends StatefulWidget{
  FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  // this will keep track of the current page to display
  int _selectedIndex = 2;
  bool isDarkMode = false;

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
  }

  // this method updates the new selected index 
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = [
    //Orgs
    OrgsPage(),

    //ID
    CampusChatPage(),

    //Home
    HomePage(),

    //Map
    MapPage(),

    //User
    UserPage(),
  ];
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: [
          // Orgs icon
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Orgs', 
            backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
            ),
          // ID icon
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Chat',
            backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
            ),

          // Home icon
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
            backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
            ),

          // Map icon
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
            backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
              ),
          
          // User icon
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'User',
            backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
            ),
        ]
      ),
    );
  }
}