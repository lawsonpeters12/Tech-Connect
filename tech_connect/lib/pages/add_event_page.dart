import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEventPage extends StatefulWidget {
  final String orgName;

  AddEventPage({required this.orgName});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  TextEditingController _eventNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save event when button is pressed
                _saveEvent();
              },
              child: Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEvent() {
    String eventName = _eventNameController.text;
    // Check if eventName is not empty
    if (eventName.isNotEmpty) {
      // Save event to Firestore
      addEventToOrganization(eventName);
      // Navigate back to previous screen
      Navigator.pop(context);
    } else {
      // Show an error message or handle empty event name
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Event Name cannot be empty'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void addEventToOrganization(String eventName) {
    // Get a reference to the events collection
    CollectionReference eventsRef = FirebaseFirestore.instance
        .collection('Organizations')
        .doc(widget.orgName)
        .collection('Events');

    // Add the event to Firestore
    eventsRef.add({'eventName': eventName}).then((value) {
      print('Event added to organization successfully');
    }).catchError((error) {
      print('Failed to add event to organization: $error');
    });
  }
}
