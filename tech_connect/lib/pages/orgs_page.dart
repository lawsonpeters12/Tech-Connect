// ignore_for_file: prefer_const_constructors

import 'dart:html';
import 'package:flutter/material.dart';

class OrgsPage extends StatefulWidget {
  const OrgsPage({super.key});

  @override
  State<OrgsPage> createState() => _OrgsPageState();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Organizations')),
    );
  }
}

class _OrgsPageState extends State<OrgsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: organizationPage());
  }
}

class organizationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
          title: Text('Organizations'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(203, 51, 59, 100)),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white),
                margin:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 190),
                height: 100,
                width: 100,
                child: Row(children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => allOrgs()));
                          },
                          child: Text("All Organizations")))
                ])),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white),
                margin:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 190),
                padding: EdgeInsets.all(25.0),
                height: 100,
                width: 150,
                child: Row(children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => myOrgs()));
                          },
                          child: Text("My Organizations")))
                ])),
            const Divider(
              height: 20.0,
              thickness: 5.0,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ),
          ]),
    );
  }
}

//Designer code for All Organizations Page
class allOrgs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(203, 51, 59, 100),
          title: Text("All Organizations"),
          centerTitle: true,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white),
                padding: EdgeInsets.all(25.0),
                margin:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 190),
                child: Column(children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => acm()));
                    },
                    child: Text("ACM"),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrgsPage()));
                      },
                      child: Text("WoSTEM")),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrgsPage()));
                      },
                      child: Text("Math Club")),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrgsPage()));
                      },
                      child: Text("LTSEC")),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrgsPage()));
                      },
                      child: Text(". . ."))
                ]),
              )
            ]));
  }
}

class myOrgs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(203, 51, 59, 100),
        title: Text("My Organizations"),
        centerTitle: true,
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white),
                margin:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 190),
                padding: EdgeInsets.all(25.0),
                height: 100,
                width: 150,
                child: Row(children: [
                  Expanded(
                      child: Center(
                          child: ListView(
                    children: [
                      Text(
                        "You have not joined any organizations",
                        textAlign: TextAlign.center,
                      )
                    ],
                  )))
                ]))
          ]),
    );
  }
}

class acm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(203, 51, 59, 100),
          title: Text("Association for Computing Machinery - ACM"),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {},
              child: Text("Request Join",
                  selectionColor: Color.fromARGB(1, 1, 1, 1)),
            )
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white),
                  margin:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 190),
                  padding: EdgeInsets.all(25.0),
                  //height: 100,
                  //width: 150,
                  child: Column(children: [
                    Text("Club Members",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("There are no members in this organization yet"),
                  ])),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white),
                margin:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 190),
                padding: EdgeInsets.all(25.0),
                //height: 100,
                //width: 150,
                child: Column(children: [
                  Text("ACM Connect",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                      "You must be a member of this organization to view and send messages.")
                ]),
              )
            ]));
  }
}
