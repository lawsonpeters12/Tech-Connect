// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(198, 218, 231, 100),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }
          ),
          title: Text('Friend Page'),
          actions: [
            Image.asset(
              "images/logo.png",
              fit: BoxFit.contain,
              height: 60,
            ),
            SizedBox(width: 600),
            Icon(Icons.search),
            SizedBox(width: 20),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Color.fromRGBO(198, 218, 231, 100),
                title: TabBar(
                  tabs: [
                    Tab(text: 'Friends'),
                    Tab(text: 'Requests'),
                  ],
                ),
                floating: true,
                pinned: true,
                snap: false,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Content for 'Friends' tab
              Center(
                child: Text('Friends Tab Content'),
              ),
              // Content for 'Requests' tab
              Center(
                child: Text('Requests Tab Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}