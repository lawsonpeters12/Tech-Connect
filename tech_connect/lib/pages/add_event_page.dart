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
  //text controllers for admin to add fields to an event
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  //TextEditingController _dateController = TextEditingController();
  //TextEditingController _timeController = TextEditingController();

  DateTime selected = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

//async function to select date using DatePicker widget
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context, firstDate: DateTime.now(), lastDate: DateTime(2101));
    if (picked != null && picked != selected) {
      setState(() {
        selected = picked;
      });
    }
  }

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
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Event Location'),
            ),
            SizedBox(height: 20),
            TextButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('Select date')),
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

    void _sendMessage(eventName) async {

      CollectionReference messages =
          FirebaseFirestore.instance.collection('messages');

      // Get server timestamp before adding the message
      Timestamp serverTimestamp = Timestamp.now();

      try {
        await messages.add({
          'user': widget.orgName,
          'message': eventName,
          'timestamp': serverTimestamp,
          'chat_topic': 'Campus Events',
          'type': "text",
          'sender_display_name': widget.orgName
        });

      } catch (e) {
        print('Error sending message: $e');
      }
    }
  

  void _saveEvent() {
    String eventName = _eventNameController.text;
    String location = _locationController.text;
    String date = selected.toString();
    // Check if eventName is not empty
    if (eventName.isNotEmpty) {
      // Save event to Firestore
      _sendMessage(eventName);
      addEventToOrganization(eventName, location, date);
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

  void addEventToOrganization(
      String eventName, String location, String date) async {
    // Get a reference to the events collection for EventButton
    CollectionReference orgsRef =
        FirebaseFirestore.instance.collection('Organizations');

    try {
      final orgDoc = await orgsRef.doc(widget.orgName).get();
      if (!orgDoc.exists) {
        await orgsRef.doc(widget.orgName).set({});
      }

      CollectionReference eventsRef =
          orgsRef.doc(widget.orgName).collection('Events');

      CollectionReference globalEvents =
          FirebaseFirestore.instance.collection('eventsGlobal');

      await eventsRef
          .doc(eventName)
          .set({'eventName': eventName, 'location': location, 'date': date});

      await globalEvents.doc(eventName).set({
        'orgName': widget.orgName,
        'eventName': eventName,
        'location': location,
        'date': date
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event added successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Show an error message if something goes wrong
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add event: $e'),
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
}
