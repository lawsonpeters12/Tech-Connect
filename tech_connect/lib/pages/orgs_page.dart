// ignore_for_file: prefer_const_constructors

import 'dart:html';

import 'package:flutter/material.dart';

class OrgsPage extends StatelessWidget {
  const OrgsPage({super.key});

  void showOrgList() {
    print("Orgs: List<>");
  }

  void showMyOrgs() {
    print("not in any organizations");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        appBar: AppBar(
          title: Text('Organizations & Events'),
          backgroundColor: Color.fromRGBO(203, 51, 59, 100),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                padding: EdgeInsets.all(25.0),
                height: 100,
                width: 150,
                color: Colors.white,
                child: Row(children: [
                  Expanded(
                      child: TextButton(
                          onPressed: showOrgList,
                          child: Text('All Organizations'))),
                ])),
            Container(
                padding: EdgeInsets.all(25.0),
                height: 100,
                width: 150,
                color: Colors.white,
                child: Row(children: [
                  Expanded(
                      child: TextButton(
                          onPressed: showMyOrgs,
                          child: Text('My Organizations'))),
                ])),
            const Divider(
              height: 20.0,
              thickness: 5.0,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            )
          ],
        ));
  }
}
